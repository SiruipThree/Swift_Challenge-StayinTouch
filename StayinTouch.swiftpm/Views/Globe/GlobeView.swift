import SwiftUI
import SceneKit
import simd
import UIKit
import ImageIO

// NOTE: Swift Student Challenge requires offline operation. MapKit's globe fetches
// map tiles from the network, so we use SceneKit with bundled textures instead.
// To use MapKit: Map().mapStyle(.imagery(elevation: .realistic)) — but it won't
// work during offline judging.

struct GlobeView: UIViewRepresentable {
    enum BaseMode: Hashable {
        case pair
        case me
    }
    
    let fromCoordinate: Coordinate
    let toCoordinate: Coordinate?
    let distanceMiles: Int
    let daysApart: Int
    var showNudgeRipple: Bool = false
    var zoom: CGFloat = 1.0
    /// World-space rotation applied by the user's drag gesture (left-multiplied).
    var userRotation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    /// Accumulated auto-rotation angle (radians). Applied in Earth body-space
    /// (right-multiplied after `base`) so the spin direction correctly reverses
    /// when the globe is held upside-down.
    var autoRotAngle: Float = 0
    var baseMode: BaseMode = .pair
    var routeRevealProgress: CGFloat = 1.0
    var contactAvatar: String = "🙂"
    var showsOverview: Bool = false
    var overviewContacts: [User] = []
    
    private let defaultCameraDistance: Float = 4.4
    private let minCameraDistance: Float = 1.9
    private let maxCameraDistance: Float = 9.5
    private let minZoom: Float = 0.60
    private let maxZoom: Float = 2.60
    private let routeArcSegments = 36
    private let overviewArcSegments = 30
    private let routeProgressBucketCount: CGFloat = 28
    private let overlayScaleBucketCount: Float = 18
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator {
        var lastOverlaySignature: OverlaySignature?
        var lastCameraDistance: Float?
        private var avatarCache: [String: UIImage] = [:]

        // Nudge beam state
        var lastNudgeRipple: Bool = false
        var lastFullArcPositions: [SCNVector3] = []
        var lastOverlayScale: Float = 1.0
        
        func shouldRebuildOverlay(for signature: OverlaySignature) -> Bool {
            guard lastOverlaySignature != signature else { return false }
            lastOverlaySignature = signature
            return true
        }
        
        func avatarImage(for emoji: String, builder: (String) -> UIImage) -> UIImage {
            if let cached = avatarCache[emoji] {
                return cached
            }
            let image = builder(emoji)
            avatarCache[emoji] = image
            return image
        }
    }
    
    struct OverlaySignature: Hashable {
        let baseMode: BaseMode
        let showsOverview: Bool
        let fromLatE3: Int
        let fromLonE3: Int
        let toLatE3: Int?
        let toLonE3: Int?
        let routeProgressBucket: Int
        let overlayScaleBucket: Int
        let contactAvatar: String
        let overviewContacts: [OverviewContactSignature]
    }
    
    struct OverviewContactSignature: Hashable {
        let id: String
        let latE3: Int
        let lonE3: Int
        let avatar: String
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createScene()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling2X
        
        let camera = SCNCamera()
        camera.fieldOfView = 44
        camera.zNear = 0.1
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.name = "cameraNode"
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, defaultCameraDistance)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        
        return sceneView
    }
    
    func updateUIView(_ sceneView: SCNView, context: Context) {
        guard let scene = sceneView.scene else { return }
        guard let earthNode = scene.rootNode.childNode(withName: "earth", recursively: false) else { return }
        let cameraNode = scene.rootNode.childNode(withName: "cameraNode", recursively: false)
        var currentCameraDistance = defaultCameraDistance
        
        if let cameraNode {
            let clampedZoom = min(max(Float(zoom), minZoom), maxZoom)
            let baseDistance: Float = {
                if showsOverview {
                    return 5.8
                }
                switch baseMode {
                case .pair:
                    guard let toCoordinate else { return defaultCameraDistance }
                    return pairCameraBaseDistance(from: fromCoordinate, to: toCoordinate)
                case .me:
                    return defaultCameraDistance
                }
            }()
            let targetDistance = baseDistance / clampedZoom
            let clampedDistance = min(max(targetDistance, minCameraDistance), maxCameraDistance)
            currentCameraDistance = clampedDistance

            // Camera distance follows the already-smoothed SwiftUI zoom input directly.
            // This avoids a second easing pass that can cause stutter under gestures.
            SCNTransaction.begin()
            SCNTransaction.disableActions = true
            cameraNode.position = SCNVector3(0, 0, clampedDistance)
            SCNTransaction.commit()

            context.coordinator.lastCameraDistance = clampedDistance
        }
        let overlayScale = overlayScaleFactor(for: currentCameraDistance)
        
        let base: simd_quatf = {
            if showsOverview {
                return overviewOrientationQuaternion(at: fromCoordinate)
            }
            switch baseMode {
            case .pair:
                guard let toCoordinate else { return focusOrientationQuaternion(at: fromCoordinate) }
                return defaultOrientationQuaternion(from: fromCoordinate, to: toCoordinate)
            case .me:
                return focusOrientationQuaternion(at: fromCoordinate)
            }
        }()
        // Compose orientation: world-space user rotation  ×  base orientation  ×  body-space auto-spin.
        // Right-multiplying autoRot means it rotates around the Earth's own geographic Y axis,
        // so the spin direction naturally reverses when the globe is flipped upside-down.
        let autoRot = simd_quatf(angle: autoRotAngle, axis: SIMD3<Float>(0, 1, 0))
        earthNode.simdOrientation = simd_normalize(userRotation * base * autoRot)
        
        let nudgeJustFired = showNudgeRipple && !context.coordinator.lastNudgeRipple
        context.coordinator.lastNudgeRipple = showNudgeRipple

        let hasActiveNudgeEffects = earthNode.childNodes.contains { $0.name == "nudgeEffect" }
        if !hasActiveNudgeEffects,
           context.coordinator.shouldRebuildOverlay(for: overlaySignature(for: overlayScale)) {
            rebuildOverlayNodes(
                on: earthNode,
                sceneView: sceneView,
                overlayScale: overlayScale,
                coordinator: context.coordinator
            )
        }
        updateMarkerVisibility(on: earthNode, in: sceneView)
        if nudgeJustFired && context.coordinator.lastFullArcPositions.count >= 2 {
            triggerNudgeBeam(
                on: earthNode,
                positions: context.coordinator.lastFullArcPositions,
                overlayScale: context.coordinator.lastOverlayScale
            )
        }
    }
    
    private func overlaySignature(for overlayScale: Float) -> OverlaySignature {
        let fromPoint = quantizedCoordinate(fromCoordinate)
        let toPoint = toCoordinate.map { quantizedCoordinate($0) }
        let overviewSignature: [OverviewContactSignature] = showsOverview
            ? overviewContacts.map {
                let point = quantizedCoordinate($0.location)
                return OverviewContactSignature(
                    id: $0.id,
                    latE3: point.latE3,
                    lonE3: point.lonE3,
                    avatar: $0.avatarEmoji
                )
            }
            : []
        
        return OverlaySignature(
            baseMode: baseMode,
            showsOverview: showsOverview,
            fromLatE3: fromPoint.latE3,
            fromLonE3: fromPoint.lonE3,
            toLatE3: toPoint?.latE3,
            toLonE3: toPoint?.lonE3,
            routeProgressBucket: quantizedRouteProgress(routeRevealProgress),
            overlayScaleBucket: quantizedOverlayScale(overlayScale),
            contactAvatar: contactAvatar,
            overviewContacts: overviewSignature
        )
    }
    
    private func quantizedCoordinate(_ coordinate: Coordinate) -> (latE3: Int, lonE3: Int) {
        (
            Int((coordinate.latitude * 1_000).rounded()),
            Int((coordinate.longitude * 1_000).rounded())
        )
    }
    
    private func quantizedRouteProgress(_ progress: CGFloat) -> Int {
        Int((min(max(progress, 0), 1) * routeProgressBucketCount).rounded())
    }
    
    private func quantizedOverlayScale(_ scale: Float) -> Int {
        Int((min(max(scale, 0.34), 1.05) * overlayScaleBucketCount).rounded())
    }
    
    private func rebuildOverlayNodes(
        on earthNode: SCNNode,
        sceneView: SCNView,
        overlayScale: Float,
        coordinator: Coordinator
    ) {
        clearOverlayNodes(from: earthNode)
        let fromPos = coordinateToPosition(fromCoordinate, radius: 1.01)
        
        if showsOverview {
            addPin(
                to: earthNode,
                at: fromPos,
                color: UIColor(red: 0.22, green: 0.84, blue: 1.0, alpha: 1.0),
                overlayScale: overlayScale * 0.82
            )
            
            for contact in overviewContacts {
                let toPos = coordinateToPosition(contact.location, radius: 1.01)
                let positions = arcPositions(
                    from: fromPos,
                    to: toPos,
                    segments: overviewArcSegments,
                    lift: 0.078
                )
                
                addPin(
                    to: earthNode,
                    at: toPos,
                    color: UIColor(red: 0.14, green: 0.80, blue: 1.0, alpha: 0.95),
                    overlayScale: overlayScale * 0.72
                )
                addArc(
                    to: earthNode,
                    positions: positions,
                    showPulse: false,
                    overlayScale: overlayScale * 0.74
                )
                
                addContactMarker(
                    to: earthNode,
                    at: toPos,
                    avatarImage: coordinator.avatarImage(for: contact.avatarEmoji) { avatarBadgeImage(emoji: $0) },
                    overlayScale: overlayScale * 0.72
                )
            }
            updateMarkerVisibility(on: earthNode, in: sceneView)
            return
        }
        
        guard let toCoordinate else {
            updateMarkerVisibility(on: earthNode, in: sceneView)
            return
        }
        
        let toPos = coordinateToPosition(toCoordinate, radius: 1.01)
        let fullArcPositions = arcPositions(
            from: fromPos,
            to: toPos,
            segments: routeArcSegments,
            lift: 0.082
        )
        // Cache for nudge beam effect.
        coordinator.lastFullArcPositions = fullArcPositions
        coordinator.lastOverlayScale = overlayScale
        let revealedPositions = revealedArcPositions(
            from: fullArcPositions,
            progress: min(max(Float(routeRevealProgress), 0), 1)
        )
        
        addPin(
            to: earthNode,
            at: fromPos,
            color: UIColor(red: 0.22, green: 0.84, blue: 1.0, alpha: 1.0),
            overlayScale: overlayScale
        )
        addArc(
            to: earthNode,
            positions: revealedPositions,
            showPulse: routeRevealProgress >= 0.995,
            overlayScale: overlayScale
        )
        
        if routeRevealProgress >= 0.90 {
            addContactMarker(
                to: earthNode,
                at: toPos,
                avatarImage: coordinator.avatarImage(for: contactAvatar) { avatarBadgeImage(emoji: $0) },
                overlayScale: overlayScale
            )
        }
        updateMarkerVisibility(on: earthNode, in: sceneView)
    }
    
    private func clearOverlayNodes(from earthNode: SCNNode) {
        earthNode.childNodes
            .filter { $0.name == "connectionArc" || $0.name == "pin" || $0.name == "contactMarker" }
            .forEach { $0.removeFromParentNode() }
    }
    
    private func updateMarkerVisibility(on earthNode: SCNNode, in sceneView: SCNView) {
        for marker in earthNode.childNodes where marker.name == "contactMarker" {
            let world = earthNode.convertPosition(marker.position, to: nil)
            let projected = sceneView.projectPoint(world)
            marker.isHidden = !(projected.z > 0 && projected.z < 1)
        }
    }
    
    // MARK: - Scene Construction
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        scene.background.contents = createSpaceTexture()
        
        let earthNode = createEarth()
        scene.rootNode.addChildNode(earthNode)
        
        addLighting(to: scene.rootNode)
        addStars(to: scene.rootNode)
        
        return scene
    }
    
    private func createEarth() -> SCNNode {
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 96
        
        let material = SCNMaterial()
        let dayTexture = earthTextureImage(name: "8k_earth_daymap", ext: "jpg", maxPixelSize: 4096)
        let nightTexture = earthTextureImage(name: "8k_earth_nightmap", ext: "jpg", maxPixelSize: 2048)
        
        if dayTexture == nil {
            print("GlobeView: day texture not found, using fallback color.")
        }
        if nightTexture == nil {
            print("GlobeView: night texture not found.")
        }

        // Use explicit image loading to avoid URL-based texture decode failures in SwiftPM app bundles.
        material.diffuse.contents = dayTexture ?? createEarthGradientImage()
        material.ambient.contents = UIColor(red: 0.03, green: 0.05, blue: 0.10, alpha: 1.0)
        material.emission.contents = nightTexture
        material.emission.intensity = nightTexture == nil ? 0 : 0.10
        material.lightingModel = .blinn
        material.specular.contents = UIColor(white: 0.16, alpha: 1.0)
        material.shininess = 0.15
        material.fresnelExponent = 1.2
        
        sphere.materials = [material]
        
        let node = SCNNode(geometry: sphere)
        node.name = "earth"
        addAtmosphere(to: node)
        
        return node
    }

    private func earthTextureURL(name: String, ext: String) -> URL? {
        let preferredSubdir = "Textures/Earth"
        let filename = "\(name).\(ext)"
        
        if let path = Bundle.main.path(forResource: name, ofType: ext),
           FileManager.default.fileExists(atPath: path) {
            return URL(fileURLWithPath: path)
        }
        
        if let path = Bundle.main.path(forResource: filename, ofType: nil),
           FileManager.default.fileExists(atPath: path) {
            return URL(fileURLWithPath: path)
        }
        
        for bundle in candidateBundles {
            if let url = bundle.url(
                forResource: name,
                withExtension: ext,
                subdirectory: preferredSubdir
            ) {
                return url
            }
            
            if let url = bundle.url(forResource: name, withExtension: ext) {
                return url
            }
            
            if let candidates = bundle.urls(forResourcesWithExtension: ext, subdirectory: nil),
               let url = candidates.first(where: { $0.lastPathComponent == filename }) {
                return url
            }
        }
        
        if let rootPath = Bundle.main.resourcePath {
            let enumerator = FileManager.default.enumerator(atPath: rootPath)
            while let relative = enumerator?.nextObject() as? String {
                if relative.hasSuffix(filename) {
                    return URL(fileURLWithPath: (rootPath as NSString).appendingPathComponent(relative))
                }
            }
        }
        
        return nil
    }
    
    private func earthTextureImage(name: String, ext: String, maxPixelSize: Int) -> UIImage? {
        guard let url = earthTextureURL(name: name, ext: ext) else { return nil }
        
        if let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary) {
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true
            ]
            if let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        if let image = UIImage(contentsOfFile: url.path) {
            return image
        }
        return nil
    }
    
    private var candidateBundles: [Bundle] {
        var bundles: [Bundle] = [Bundle.main, Bundle(for: ResourceLocator.self)]
        bundles.append(contentsOf: Bundle.allFrameworks)
        bundles.append(contentsOf: Bundle.allBundles)
        
        var seen = Set<String>()
        return bundles.filter {
            let key = $0.bundlePath
            return seen.insert(key).inserted
        }
    }
    
    private final class ResourceLocator {}
    
    private func addAtmosphere(to earthNode: SCNNode) {
        let atmosphereSphere = SCNSphere(radius: 1.014)
        atmosphereSphere.segmentCount = 44
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.45, green: 0.70, blue: 1.0, alpha: 0.035)
        material.emission.contents = UIColor(red: 0.18, green: 0.35, blue: 0.75, alpha: 0.02)
        material.lightingModel = .constant
        material.isDoubleSided = true
        material.blendMode = .alpha
        atmosphereSphere.materials = [material]
        
        let atmosphereNode = SCNNode(geometry: atmosphereSphere)
        atmosphereNode.name = "atmosphere"
        earthNode.addChildNode(atmosphereNode)
    }
    
    private func createSpaceTexture() -> UIImage {
        let size = CGSize(width: 2048, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let bounds = CGRect(origin: .zero, size: size)
            
            let colors = [
                UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor,
                UIColor(red: 0.01, green: 0.01, blue: 0.015, alpha: 1.0).cgColor,
                UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0.0, 0.55, 1.0]
            
            if let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: locations
            ) {
                cg.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: size.width * 0.15, y: 0),
                    end: CGPoint(x: size.width * 0.85, y: size.height),
                    options: []
                )
            } else {
                UIColor.black.setFill()
                cg.fill(bounds)
            }
            
            // Very subtle neutral dust clouds (avoid blue cast).
            for _ in 0..<8 {
                let center = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )
                let radius = CGFloat.random(in: 120...280)
                let color = UIColor(
                    red: CGFloat.random(in: 0.10...0.16),
                    green: CGFloat.random(in: 0.10...0.16),
                    blue: CGFloat.random(in: 0.10...0.18),
                    alpha: CGFloat.random(in: 0.02...0.045)
                )
                color.setFill()
                cg.fillEllipse(
                    in: CGRect(
                        x: center.x - radius,
                        y: center.y - radius * 0.65,
                        width: radius * 2,
                        height: radius * 1.3
                    )
                )
            }
            
            // Dense star field.
            for _ in 0..<900 {
                let point = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )
                let diameter = CGFloat.random(in: 0.45...1.6)
                UIColor.white
                    .withAlphaComponent(CGFloat.random(in: 0.25...0.95))
                    .setFill()
                cg.fillEllipse(
                    in: CGRect(
                        x: point.x,
                        y: point.y,
                        width: diameter,
                        height: diameter
                    )
                )
            }
        }
    }
    
    /// Centres `focus` on screen AND corrects roll so the north–south axis is vertical.
    /// Uses `quaternionBetween` to bring the focus point to the camera's z+ direction,
    /// then applies a roll rotation around the camera axis (Z) to align the globe's Y
    /// axis (north pole) to screen-up.
    private func uprightAlignQuaternion(focus: SIMD3<Float>) -> simd_quatf {
        let f = simd_normalize(focus)
        let align = quaternionBetween(f, SIMD3<Float>(0, 0, 1))

        // Find where the globe's north pole (local Y) ends up after align.
        let northWorld = align.act(SIMD3<Float>(0, 1, 0))
        // Project onto screen plane (XY, perpendicular to camera Z).
        let proj = SIMD3<Float>(northWorld.x, northWorld.y, 0)
        guard simd_length_squared(proj) > 0.0001 else { return align }
        let projNorm  = simd_normalize(proj)
        let screenUp  = SIMD3<Float>(0, 1, 0)
        var rollAngle = acos(max(-1, min(1, simd_dot(projNorm, screenUp))))
        // Determine rotation direction via cross product.
        if simd_cross(projNorm, screenUp).z < 0 { rollAngle = -rollAngle }
        let rollQ = simd_quatf(angle: rollAngle, axis: SIMD3<Float>(0, 0, 1))
        return simd_normalize(rollQ * align)
    }

    private func defaultOrientationQuaternion(from: Coordinate, to: Coordinate) -> simd_quatf {
        let fromV = simd_normalize(toSimd(coordinateToPosition(from, radius: 1.0)))
        let toV   = simd_normalize(toSimd(coordinateToPosition(to,   radius: 1.0)))

        // Weight orientation toward the start point while keeping destination visible.
        var focus = fromV * 0.68 + toV * 0.32
        if simd_length_squared(focus) < 0.0001 { focus = fromV }

        let align = uprightAlignQuaternion(focus: focus)
        // Small downward tilt keeps the route arc centred under the top cards.
        let tilt = simd_quatf(angle: Float(-0.06), axis: SIMD3<Float>(1, 0, 0))
        return simd_normalize(tilt * align)
    }

    private func focusOrientationQuaternion(at coordinate: Coordinate) -> simd_quatf {
        let point = toSimd(coordinateToPosition(coordinate, radius: 1.0))
        let align = uprightAlignQuaternion(focus: point)
        let tilt  = simd_quatf(angle: Float(-0.06), axis: SIMD3<Float>(1, 0, 0))
        return simd_normalize(tilt * align)
    }

    private func overviewOrientationQuaternion(at coordinate: Coordinate) -> simd_quatf {
        let point = toSimd(coordinateToPosition(coordinate, radius: 1.0))
        let align = uprightAlignQuaternion(focus: point)
        // Slight westward yaw so more contacts are visible across the globe face.
        let yawOffset = simd_quatf(angle: Float(-0.14), axis: SIMD3<Float>(0, 1, 0))
        let tilt      = simd_quatf(angle: Float(-0.10), axis: SIMD3<Float>(1, 0, 0))
        return simd_normalize(tilt * yawOffset * align)
    }
    
    private func pairCameraBaseDistance(from: Coordinate, to: Coordinate) -> Float {
        let fromV = simd_normalize(toSimd(coordinateToPosition(from, radius: 1.0)))
        let toV = simd_normalize(toSimd(coordinateToPosition(to, radius: 1.0)))
        let dotValue = max(-1.0, min(1.0, simd_dot(fromV, toV)))
        let angle = acos(dotValue)
        
        // Increase distance for larger separations so both endpoints remain visible.
        let distance = defaultCameraDistance + 1.2 * max(0, angle - 0.95)
        return min(max(distance, 4.3), 6.0)
    }
    
    private func quaternionBetween(_ from: SIMD3<Float>, _ to: SIMD3<Float>) -> simd_quatf {
        let f = simd_normalize(from)
        let t = simd_normalize(to)
        let d = simd_dot(f, t)
        
        if d >= 0.9999 {
            return simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        }
        
        if d <= -0.9999 {
            let orth = simd_cross(f, SIMD3<Float>(0, 1, 0))
            let axis = simd_length_squared(orth) < 0.0001
                ? SIMD3<Float>(1, 0, 0)
                : simd_normalize(orth)
            return simd_quatf(angle: Float.pi, axis: axis)
        }
        
        let axis = simd_normalize(simd_cross(f, t))
        let angle = acos(max(min(d, Float(1.0)), Float(-1.0)))
        return simd_quatf(angle: angle, axis: axis)
    }
    
    private func toSimd(_ v: SCNVector3) -> SIMD3<Float> {
        SIMD3<Float>(v.x, v.y, v.z)
    }
    
    private func createEarthGradientImage() -> UIImage {
        let size = CGSize(width: 2048, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            // Deep ocean base
            UIColor(red: 0.05, green: 0.10, blue: 0.25, alpha: 1.0).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            // Continent-like shapes using overlapping ovals
            let landColor = UIColor(red: 0.12, green: 0.22, blue: 0.15, alpha: 0.7)
            landColor.setFill()
            
            // Approximate land masses
            let continents: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (0.15, 0.15, 0.25, 0.35), // Asia
                (0.25, 0.20, 0.12, 0.25), // Europe
                (0.10, 0.45, 0.18, 0.35), // Africa
                (0.55, 0.18, 0.20, 0.40), // North America
                (0.60, 0.50, 0.10, 0.30), // South America
                (0.82, 0.65, 0.10, 0.10), // Australia
            ]
            
            for c in continents {
                let rect = CGRect(
                    x: c.0 * size.width, y: c.1 * size.height,
                    width: c.2 * size.width, height: c.3 * size.height
                )
                ctx.cgContext.fillEllipse(in: rect)
            }
            
            // Subtle cloud wisps
            UIColor.white.withAlphaComponent(0.03).setFill()
            for _ in 0..<30 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let w = CGFloat.random(in: 60...200)
                ctx.cgContext.fillEllipse(in: CGRect(x: x, y: y, width: w, height: w * 0.3))
            }
        }
    }
    
    // MARK: - Pins & Arc
    
    private func addPin(to parent: SCNNode, at position: SCNVector3, color: UIColor, overlayScale: Float) {
        let pinSphere = SCNSphere(radius: 0.011)
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.emission.contents = color.withAlphaComponent(0.8)
        pinSphere.materials = [material]
        
        let pinNode = SCNNode(geometry: pinSphere)
        pinNode.position = position
        pinNode.name = "pin"
        pinNode.scale = SCNVector3(overlayScale, overlayScale, overlayScale)
        parent.addChildNode(pinNode)
        
        // Glow pulse
        let glowSphere = SCNSphere(radius: 0.016)
        let glowMat = SCNMaterial()
        glowMat.diffuse.contents = color.withAlphaComponent(0.22)
        glowMat.emission.contents = color.withAlphaComponent(0.16)
        glowSphere.materials = [glowMat]
        let glowNode = SCNNode(geometry: glowSphere)
        glowNode.position = position
        glowNode.name = "pin"
        glowNode.scale = SCNVector3(overlayScale, overlayScale, overlayScale)
        
        let pulse = CABasicAnimation(keyPath: "scale")
        pulse.fromValue = NSValue(scnVector3: SCNVector3(1, 1, 1))
        pulse.toValue = NSValue(scnVector3: SCNVector3(1.32, 1.32, 1.32))
        pulse.duration = 1.5
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        glowNode.addAnimation(pulse, forKey: "pulse")
        
        parent.addChildNode(glowNode)
    }
    
    private func addArc(to parent: SCNNode, positions: [SCNVector3], showPulse: Bool, overlayScale: Float) {
        guard positions.count >= 2 else { return }
        
        let arcContainer = SCNNode()
        arcContainer.name = "connectionArc"
        
        let neonBlue = UIColor(red: 0.12, green: 0.92, blue: 1.0, alpha: 1.0)
        let widthScale = CGFloat(overlayScale)
        
        // Outer glow stroke
        addArcStroke(
            to: arcContainer,
            positions: positions,
            radius: 0.0058 * widthScale,
            color: neonBlue.withAlphaComponent(0.26),
            emissionColor: neonBlue.withAlphaComponent(0.80),
            blendMode: .add
        )
        
        // Inner bright core
        addArcStroke(
            to: arcContainer,
            positions: positions,
            radius: 0.0028 * widthScale,
            color: neonBlue.withAlphaComponent(0.95),
            emissionColor: neonBlue.withAlphaComponent(1.0),
            blendMode: .alpha
        )
        
        if showPulse {
            addTravelingPulse(
                to: arcContainer,
                positions: positions,
                color: neonBlue,
                overlayScale: overlayScale
            )
        }
        parent.addChildNode(arcContainer)
    }
    
    private func arcPositions(from start: SCNVector3, to end: SCNVector3, segments: Int, lift: Float) -> [SCNVector3] {
        var positions: [SCNVector3] = []
        for i in 0...segments {
            let t = Float(i) / Float(segments)
            let interpolated = SCNVector3(
                start.x + (end.x - start.x) * t,
                start.y + (end.y - start.y) * t,
                start.z + (end.z - start.z) * t
            )
            
            let length = sqrt(
                interpolated.x * interpolated.x +
                interpolated.y * interpolated.y +
                interpolated.z * interpolated.z
            )
            let arcHeight: Float = 1.0 + lift * sin(Float.pi * t)
            let scale = arcHeight / length
            positions.append(
                SCNVector3(
                    interpolated.x * scale,
                    interpolated.y * scale,
                    interpolated.z * scale
                )
            )
        }
        return positions
    }
    
    private func revealedArcPositions(from positions: [SCNVector3], progress: Float) -> [SCNVector3] {
        guard !positions.isEmpty else { return [] }
        let clamped = min(max(progress, 0), 1)
        if clamped <= 0 { return [positions[0]] }
        if clamped >= 1 || positions.count < 2 { return positions }
        
        let segmentCount = Float(positions.count - 1)
        let revealIndex = clamped * segmentCount
        let baseIndex = Int(floor(revealIndex))
        
        var revealed = Array(positions[0...baseIndex])
        if baseIndex < positions.count - 1 {
            let localT = revealIndex - Float(baseIndex)
            let a = positions[baseIndex]
            let b = positions[baseIndex + 1]
            revealed.append(
                SCNVector3(
                    a.x + (b.x - a.x) * localT,
                    a.y + (b.y - a.y) * localT,
                    a.z + (b.z - a.z) * localT
                )
            )
        }
        return revealed
    }
    
    private func addArcStroke(
        to container: SCNNode,
        positions: [SCNVector3],
        radius: CGFloat,
        color: UIColor,
        emissionColor: UIColor,
        blendMode: SCNBlendMode
    ) {
        for i in 0..<(positions.count - 1) {
            guard let segment = makeArcSegment(
                from: positions[i],
                to: positions[i + 1],
                radius: radius,
                color: color,
                emissionColor: emissionColor,
                blendMode: blendMode
            ) else {
                continue
            }
            container.addChildNode(segment)
        }
    }
    
    private func makeArcSegment(
        from start: SCNVector3,
        to end: SCNVector3,
        radius: CGFloat,
        color: UIColor,
        emissionColor: UIColor,
        blendMode: SCNBlendMode
    ) -> SCNNode? {
        let startV = SIMD3<Float>(start.x, start.y, start.z)
        let endV = SIMD3<Float>(end.x, end.y, end.z)
        let delta = endV - startV
        let length = simd_length(delta)
        guard length > 0.0001 else { return nil }
        
        let cylinder = SCNCylinder(radius: radius, height: CGFloat(length))
        cylinder.radialSegmentCount = 8
        
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.emission.contents = emissionColor
        material.lightingModel = .constant
        material.blendMode = blendMode
        cylinder.materials = [material]
        
        let segmentNode = SCNNode(geometry: cylinder)
        let midpoint = (startV + endV) * 0.5
        segmentNode.position = SCNVector3(midpoint.x, midpoint.y, midpoint.z)
        
        let up = SIMD3<Float>(0, 1, 0)
        segmentNode.simdOrientation = simd_quatf(from: up, to: simd_normalize(delta))
        return segmentNode
    }
    
    private func addTravelingPulse(
        to container: SCNNode,
        positions: [SCNVector3],
        color: UIColor,
        overlayScale: Float
    ) {
        let pulse = SCNNode()
        pulse.name = "connectionArcPulse"
        
        let core = SCNSphere(radius: CGFloat(0.0082 * overlayScale))
        let coreMaterial = SCNMaterial()
        coreMaterial.diffuse.contents = UIColor.white
        coreMaterial.emission.contents = color.withAlphaComponent(1.0)
        coreMaterial.lightingModel = .constant
        core.materials = [coreMaterial]
        pulse.geometry = core
        
        let halo = SCNSphere(radius: CGFloat(0.017 * overlayScale))
        let haloMaterial = SCNMaterial()
        haloMaterial.diffuse.contents = color.withAlphaComponent(0.18)
        haloMaterial.emission.contents = color.withAlphaComponent(0.85)
        haloMaterial.lightingModel = .constant
        haloMaterial.blendMode = .add
        halo.materials = [haloMaterial]
        let haloNode = SCNNode(geometry: halo)
        pulse.addChildNode(haloNode)
        
        pulse.position = positions[0]
        container.addChildNode(pulse)
        
        let travel = CAKeyframeAnimation(keyPath: "position")
        travel.values = positions.map { NSValue(scnVector3: $0) }
        travel.duration = 2.2
        travel.calculationMode = .linear
        travel.repeatCount = .infinity
        travel.timingFunctions = [CAMediaTimingFunction(name: .linear)]
        pulse.addAnimation(travel, forKey: "travelPulse")
        
        let breathe = CABasicAnimation(keyPath: "scale")
        breathe.fromValue = NSValue(scnVector3: SCNVector3(0.8, 0.8, 0.8))
        breathe.toValue = NSValue(scnVector3: SCNVector3(1.25, 1.25, 1.25))
        breathe.duration = 0.45
        breathe.autoreverses = true
        breathe.repeatCount = .infinity
        pulse.addAnimation(breathe, forKey: "pulseBreath")
    }
    
    // MARK: - Nudge Beam (3-orb charging shot + SCNTorus mega burst, synced to 3 s globe rotation)

    private func triggerNudgeBeam(on earthNode: SCNNode, positions: [SCNVector3], overlayScale: Float) {
        guard positions.count >= 2 else { return }

        let neonBlue   = UIColor(red: 0.22, green: 0.84, blue: 1.0, alpha: 1.0)
        let flashWhite = UIColor(red: 0.90, green: 0.98, blue: 1.0, alpha: 1.0)

        // Timing: orbs 0/1/2 launch at 0 s, 0.25 s, 0.50 s and each travel 2.5 s
        // → last orb arrives at exactly 3.0 s, matching the globe slerp duration.
        let beamDuration: TimeInterval = 2.5
        let orbSpacing:   TimeInterval = 0.25
        let capturedPositions = positions
        let lastPos = positions.last!

        for m in earthNode.childNodes where m.name == "contactMarker" {
            m.renderingOrder = 100
        }

        // ── Destination mega-burst (called at t = 3 s) ───────────────────────
        // 5 SCNTorus rings oriented tangent to the globe surface + central flash.
        func megaBurstAt(_ pos: SCNVector3) {
            // Central white flash sphere
            let flash = SCNNode()
            flash.name = "nudgeEffect"
            let flashGeo = SCNSphere(radius: CGFloat(0.065 * overlayScale))
            let flashMat = SCNMaterial()
            flashMat.diffuse.contents  = UIColor.white
            flashMat.emission.contents = UIColor.white
            flashMat.lightingModel = .constant
            flashMat.blendMode = .add
            flashGeo.materials = [flashMat]
            flash.geometry = flashGeo
            flash.position = pos
            flash.opacity  = 0
            earthNode.addChildNode(flash)
            flash.runAction(SCNAction.sequence([
                SCNAction.group([
                    SCNAction.scale(to: 6.0, duration: 0.80),
                    SCNAction.sequence([
                        SCNAction.fadeIn(duration: 0.06),
                        SCNAction.fadeOut(duration: 0.74)
                    ])
                ]),
                SCNAction.removeFromParentNode()
            ]))

            // Orient helper: make the ring's Y-axis point outward from the globe
            // so the torus lies flat on the surface like a water ripple.
            let normal = simd_normalize(SIMD3<Float>(pos.x, pos.y, pos.z))
            let worldUp = SIMD3<Float>(0, 1, 0)
            let ringOrientation: simd_quatf = {
                let d = simd_dot(normal, worldUp)
                if d >= 0.9999 { return simd_quatf(angle: 0, axis: SIMD3<Float>(1, 0, 0)) }
                if d <= -0.9999 { return simd_quatf(angle: .pi, axis: SIMD3<Float>(1, 0, 0)) }
                return simd_quatf(from: worldUp, to: normal)
            }()

            // 5 torus rings, alternating white / neon-blue, staggered 0.40 s
            for i in 0..<5 {
                let ring = SCNNode()
                ring.name = "nudgeEffect"
                // SCNTorus: ringRadius = major radius, pipeRadius = cross-section
                let torus = SCNTorus(ringRadius: CGFloat(0.044 * overlayScale),
                                     pipeRadius: CGFloat(0.010 * overlayScale))
                let mat = SCNMaterial()
                mat.diffuse.contents  = UIColor.clear
                mat.emission.contents = (i % 2 == 0)
                    ? UIColor.white.withAlphaComponent(1.0)
                    : neonBlue.withAlphaComponent(1.0)
                mat.lightingModel = .constant
                mat.blendMode = .add
                torus.materials = [mat]
                ring.geometry = torus
                ring.position = pos
                ring.simdOrientation = ringOrientation
                ring.opacity  = 0
                earthNode.addChildNode(ring)
                ring.runAction(SCNAction.sequence([
                    SCNAction.wait(duration: TimeInterval(i) * 0.40),
                    SCNAction.group([
                        SCNAction.scale(to: 16.0, duration: 2.20),
                        SCNAction.sequence([
                            SCNAction.fadeIn(duration: 0.08),
                            SCNAction.fadeOut(duration: 2.12)
                        ])
                    ]),
                    SCNAction.removeFromParentNode()
                ]))
            }
        }

        // ── Arc flash (whole arc brightens as orbs charge up) ─────────────────
        let flashArc = SCNNode()
        flashArc.name = "nudgeEffect"
        flashArc.opacity = 0
        addArcStroke(
            to: flashArc,
            positions: positions,
            radius: 0.016 * CGFloat(overlayScale),
            color: .clear,
            emissionColor: flashWhite,
            blendMode: .add
        )
        earthNode.addChildNode(flashArc)
        flashArc.runAction(SCNAction.sequence([
            SCNAction.fadeIn(duration: 0.10),
            SCNAction.wait(duration: 0.60),
            SCNAction.fadeOut(duration: 3.00),
            SCNAction.removeFromParentNode()
        ]))

        // ── Three charging orbs ───────────────────────────────────────────────
        // Orb 0 → smallest/dimmest, orb 2 → largest/brightest (visual momentum)
        for orbIndex in 0..<3 {
            let launchDelay = orbSpacing * TimeInterval(orbIndex)
            let isLastOrb   = (orbIndex == 2)

            let orb = SCNNode()
            orb.name = "nudgeEffect"

            // Core — grows with each successive orb
            let coreRadius = CGFloat((0.028 + Float(orbIndex) * 0.006) * overlayScale)
            let coreGeo = SCNSphere(radius: coreRadius)
            let coreMat = SCNMaterial()
            coreMat.diffuse.contents  = UIColor.white
            coreMat.emission.contents = flashWhite
            coreMat.lightingModel = .constant
            coreGeo.materials = [coreMat]
            orb.geometry = coreGeo

            // Halo — grows with each successive orb
            let haloRadius = CGFloat((0.070 + Float(orbIndex) * 0.014) * overlayScale)
            let haloGeo = SCNSphere(radius: haloRadius)
            let haloMat = SCNMaterial()
            haloMat.diffuse.contents  = UIColor.clear
            haloMat.emission.contents = neonBlue.withAlphaComponent(0.92)
            haloMat.lightingModel = .constant
            haloMat.blendMode = .add
            haloGeo.materials = [haloMat]
            orb.addChildNode(SCNNode(geometry: haloGeo))

            orb.position = positions[0]
            orb.opacity  = 0
            earthNode.addChildNode(orb)

            // Pulsing breathe — faster for later orbs
            let breathePeriod: TimeInterval = 0.22 - TimeInterval(orbIndex) * 0.03
            orb.runAction(SCNAction.repeatForever(SCNAction.sequence([
                SCNAction.scale(to: 1.22, duration: breathePeriod),
                SCNAction.scale(to: 0.78, duration: breathePeriod)
            ])), forKey: "breathe")

            // Smooth arc travel (smoothstep ease-in-out)
            let travelAction = SCNAction.customAction(duration: beamDuration) { node, elapsed in
                let t     = Float(elapsed / beamDuration)
                let eased = t * t * (3 - 2 * t)
                let fIdx  = eased * Float(capturedPositions.count - 1)
                let lo    = min(Int(floor(fIdx)), capturedPositions.count - 2)
                let frac  = fIdx - Float(lo)
                let a = capturedPositions[lo], b = capturedPositions[lo + 1]
                node.position = SCNVector3(
                    a.x + (b.x - a.x) * frac,
                    a.y + (b.y - a.y) * frac,
                    a.z + (b.z - a.z) * frac
                )
            }

            var seq: [SCNAction] = [
                SCNAction.wait(duration: launchDelay),
                SCNAction.fadeIn(duration: 0.08),
                travelAction
            ]
            if isLastOrb {
                seq.append(SCNAction.run { _ in megaBurstAt(lastPos) })
                seq.append(SCNAction.fadeOut(duration: 0.35))
            } else {
                seq.append(SCNAction.fadeOut(duration: 0.14))
            }
            seq.append(SCNAction.removeFromParentNode())
            orb.runAction(SCNAction.sequence(seq))
        }
    }

    @discardableResult
    private func addContactMarker(
        to parent: SCNNode,
        at position: SCNVector3,
        avatarImage: UIImage,
        overlayScale: Float
    ) -> SCNNode {
        let plane = SCNPlane(width: 0.105, height: 0.105)
        plane.cornerRadius = 0.0525
        
        let material = SCNMaterial()
        material.diffuse.contents = avatarImage
        material.emission.contents = UIColor(red: 0.40, green: 0.86, blue: 1.0, alpha: 0.18)
        material.lightingModel = .constant
        material.isDoubleSided = false
        plane.materials = [material]
        
        let marker = SCNNode(geometry: plane)
        marker.name = "contactMarker"
        marker.renderingOrder = 100
        let surface = SIMD3<Float>(position.x, position.y, position.z)
        let normal = simd_normalize(surface)
        let lifted = surface + normal * 0.035
        marker.position = SCNVector3(lifted.x, lifted.y, lifted.z)
        marker.scale = SCNVector3(overlayScale, overlayScale, overlayScale)
        marker.constraints = [SCNBillboardConstraint()]
        parent.addChildNode(marker)
        return marker
    }
    
    // Keep overlay nodes (avatar, pins, line) visually stable in screen space while zooming.
    private func overlayScaleFactor(for cameraDistance: Float) -> Float {
        let normalized = (cameraDistance / defaultCameraDistance) * 0.72
        return min(max(normalized, 0.34), 1.05)
    }
    
    private func avatarBadgeImage(emoji: String) -> UIImage {
        let size = CGSize(width: 220, height: 220)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            
            let glowRect = CGRect(x: 14, y: 14, width: 192, height: 192)
            cg.setFillColor(UIColor(red: 0.10, green: 0.70, blue: 0.95, alpha: 0.28).cgColor)
            cg.fillEllipse(in: glowRect)
            
            let outerRect = CGRect(x: 30, y: 30, width: 160, height: 160)
            cg.setFillColor(UIColor(red: 0.08, green: 0.20, blue: 0.30, alpha: 0.94).cgColor)
            cg.fillEllipse(in: outerRect)
            cg.setStrokeColor(UIColor(red: 0.58, green: 0.92, blue: 1.0, alpha: 0.95).cgColor)
            cg.setLineWidth(7)
            cg.strokeEllipse(in: outerRect.insetBy(dx: 3.5, dy: 3.5))
            
            let avatarText = emoji.isEmpty ? "🙂" : emoji
            let emojiFont = UIFont(name: "AppleColorEmoji", size: 84) ?? UIFont.systemFont(ofSize: 84)
            let text = NSAttributedString(
                string: avatarText,
                attributes: [.font: emojiFont]
            )
            let textSize = text.size()
            let textOrigin = CGPoint(
                x: (size.width - textSize.width) * 0.5,
                y: (size.height - textSize.height) * 0.5 - 6
            )
            text.draw(at: textOrigin)
        }
    }
    
    // MARK: - Lighting
    
    private func addLighting(to parent: SCNNode) {
        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.intensity = 1600
        sunLight.temperature = 5600
        sunLight.color = UIColor(white: 1.0, alpha: 1.0)
        let sunNode = SCNNode()
        sunNode.light = sunLight
        sunNode.position = SCNVector3(2.8, 2.0, 4.8)
        sunNode.look(at: SCNVector3(0, 0, 0))
        parent.addChildNode(sunNode)
        
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 50
        ambient.color = UIColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        parent.addChildNode(ambientNode)
        
        let rim = SCNLight()
        rim.type = .directional
        rim.intensity = 170
        rim.temperature = 9000
        rim.color = UIColor(red: 0.66, green: 0.77, blue: 1.0, alpha: 1.0)
        let rimNode = SCNNode()
        rimNode.light = rim
        rimNode.position = SCNVector3(-4.4, -1.6, -3.0)
        rimNode.look(at: SCNVector3(0, 0, 0))
        parent.addChildNode(rimNode)
    }
    
    private func addStars(to parent: SCNNode) {
        let starCount = 90
        for _ in 0..<starCount {
            let theta = Float.random(in: 0...(Float.pi * 2))
            let phi = Float.random(in: 0...Float.pi)
            let r: Float = Float.random(in: 18...34)
            
            let x = r * sin(phi) * cos(theta)
            let y = r * sin(phi) * sin(theta)
            let z = r * cos(phi)
            
            let starSphere = SCNSphere(radius: CGFloat(Float.random(in: 0.008...0.03)))
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.white
            mat.emission.contents = UIColor.white.withAlphaComponent(CGFloat(Float.random(in: 0.25...0.8)))
            mat.lightingModel = .constant
            starSphere.materials = [mat]
            
            let starNode = SCNNode(geometry: starSphere)
            starNode.position = SCNVector3(x, y, z)
            parent.addChildNode(starNode)
        }
    }
    
    // MARK: - Coordinate Conversion
    
    private func coordinateToPosition(_ coord: Coordinate, radius: Double) -> SCNVector3 {
        let lat = coord.latitude * .pi / 180
        let lon = coord.longitude * .pi / 180
        
        // Match this texture's longitude orientation: 0° at front, +90°E to the right.
        let x = Float(radius * cos(lat) * sin(lon))
        let y = Float(radius * sin(lat))
        let z = Float(radius * cos(lat) * cos(lon))
        
        return SCNVector3(x, y, z)
    }
}

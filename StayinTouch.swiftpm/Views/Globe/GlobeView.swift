import SwiftUI
import SceneKit

struct GlobeView: UIViewRepresentable {
    let fromCoordinate: Coordinate
    let toCoordinate: Coordinate
    let distanceMiles: Int
    let daysApart: Int
    var showNudgeRipple: Bool = false
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createScene()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X
        
        let camera = SCNCamera()
        camera.fieldOfView = 45
        camera.zNear = 0.1
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 4.5)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        
        return sceneView
    }
    
    func updateUIView(_ sceneView: SCNView, context: Context) {
        guard let scene = sceneView.scene else { return }
        
        scene.rootNode.childNodes.filter { $0.name == "connectionArc" || $0.name == "pin" }.forEach { $0.removeFromParentNode() }
        
        let fromPos = coordinateToPosition(fromCoordinate, radius: 1.01)
        let toPos = coordinateToPosition(toCoordinate, radius: 1.01)
        
        addPin(to: scene.rootNode, at: fromPos, color: .cyan)
        addPin(to: scene.rootNode, at: toPos, color: .cyan)
        addArc(to: scene.rootNode, from: fromPos, to: toPos)
    }
    
    // MARK: - Scene Construction
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        let earthNode = createEarth()
        scene.rootNode.addChildNode(earthNode)
        
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotation.duration = 120
        rotation.repeatCount = .infinity
        earthNode.addAnimation(rotation, forKey: "slowRotation")
        
        addLighting(to: scene.rootNode)
        addStars(to: scene.rootNode)
        
        return scene
    }
    
    private func createEarth() -> SCNNode {
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 96
        
        let material = SCNMaterial()
        
        // Procedural earth-like appearance (will be replaced with texture later)
        material.diffuse.contents = createEarthGradientImage()
        material.specular.contents = UIColor.white.withAlphaComponent(0.3)
        material.shininess = 0.3
        material.fresnelExponent = 2.0
        
        sphere.materials = [material]
        
        let node = SCNNode(geometry: sphere)
        node.name = "earth"
        
        // Atmosphere glow
        let atmoSphere = SCNSphere(radius: 1.03)
        atmoSphere.segmentCount = 64
        let atmoMaterial = SCNMaterial()
        atmoMaterial.diffuse.contents = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.08)
        atmoMaterial.isDoubleSided = true
        atmoMaterial.transparent.contents = UIColor.white.withAlphaComponent(0.1)
        atmoSphere.materials = [atmoMaterial]
        let atmoNode = SCNNode(geometry: atmoSphere)
        atmoNode.name = "atmosphere"
        node.addChildNode(atmoNode)
        
        return node
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
    
    private func addPin(to parent: SCNNode, at position: SCNVector3, color: UIColor) {
        let pinSphere = SCNSphere(radius: 0.025)
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.emission.contents = color.withAlphaComponent(0.8)
        pinSphere.materials = [material]
        
        let pinNode = SCNNode(geometry: pinSphere)
        pinNode.position = position
        pinNode.name = "pin"
        parent.addChildNode(pinNode)
        
        // Glow pulse
        let glowSphere = SCNSphere(radius: 0.04)
        let glowMat = SCNMaterial()
        glowMat.diffuse.contents = color.withAlphaComponent(0.3)
        glowMat.emission.contents = color.withAlphaComponent(0.2)
        glowSphere.materials = [glowMat]
        let glowNode = SCNNode(geometry: glowSphere)
        glowNode.position = position
        glowNode.name = "pin"
        
        let pulse = CABasicAnimation(keyPath: "scale")
        pulse.fromValue = NSValue(scnVector3: SCNVector3(1, 1, 1))
        pulse.toValue = NSValue(scnVector3: SCNVector3(1.8, 1.8, 1.8))
        pulse.duration = 1.5
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        glowNode.addAnimation(pulse, forKey: "pulse")
        
        parent.addChildNode(glowNode)
    }
    
    private func addArc(to parent: SCNNode, from start: SCNVector3, to end: SCNVector3) {
        let segments = 64
        var positions: [SCNVector3] = []
        
        for i in 0...segments {
            let t = Float(i) / Float(segments)
            let interpolated = SCNVector3(
                start.x + (end.x - start.x) * t,
                start.y + (end.y - start.y) * t,
                start.z + (end.z - start.z) * t
            )
            
            let length = sqrt(interpolated.x * interpolated.x + interpolated.y * interpolated.y + interpolated.z * interpolated.z)
            let arcHeight: Float = 1.0 + 0.25 * sin(Float.pi * t) // lift above surface
            let scale = arcHeight / length
            
            positions.append(SCNVector3(interpolated.x * scale, interpolated.y * scale, interpolated.z * scale))
        }
        
        let indices: [UInt16] = (0..<UInt16(segments)).flatMap { [$0, $0 + 1] }
        
        let positionSource = SCNGeometrySource(vertices: positions)
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let geometry = SCNGeometry(sources: [positionSource], elements: [element])
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.35, green: 0.78, blue: 0.98, alpha: 0.7)
        material.emission.contents = UIColor(red: 0.35, green: 0.78, blue: 0.98, alpha: 0.5)
        geometry.materials = [material]
        
        let arcNode = SCNNode(geometry: geometry)
        arcNode.name = "connectionArc"
        parent.addChildNode(arcNode)
    }
    
    // MARK: - Lighting
    
    private func addLighting(to parent: SCNNode) {
        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.intensity = 800
        sunLight.color = UIColor(white: 0.95, alpha: 1.0)
        let sunNode = SCNNode()
        sunNode.light = sunLight
        sunNode.position = SCNVector3(5, 3, 5)
        sunNode.look(at: SCNVector3(0, 0, 0))
        parent.addChildNode(sunNode)
        
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 150
        ambient.color = UIColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        parent.addChildNode(ambientNode)
    }
    
    private func addStars(to parent: SCNNode) {
        let starCount = 200
        for _ in 0..<starCount {
            let theta = Float.random(in: 0...(Float.pi * 2))
            let phi = Float.random(in: 0...Float.pi)
            let r: Float = Float.random(in: 15...25)
            
            let x = r * sin(phi) * cos(theta)
            let y = r * sin(phi) * sin(theta)
            let z = r * cos(phi)
            
            let starSphere = SCNSphere(radius: CGFloat(Float.random(in: 0.02...0.06)))
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.white
            mat.emission.contents = UIColor.white.withAlphaComponent(CGFloat(Float.random(in: 0.3...1.0)))
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
        
        let x = Float(radius * cos(lat) * cos(lon))
        let y = Float(radius * sin(lat))
        let z = Float(-radius * cos(lat) * sin(lon))
        
        return SCNVector3(x, y, z)
    }
}

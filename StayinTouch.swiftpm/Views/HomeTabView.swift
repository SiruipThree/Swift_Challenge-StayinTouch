import SwiftUI
import simd

/// Home tab: Dashboard with user selector, widgets, and globe.
struct HomeTabView: View {
    @Bindable var viewModel: AppViewModel
    /// Incremented by RootTabView each time the Home tab is tapped while already active.
    var homeRetapID: Int = 0
    
    private let minGlobeZoom: CGFloat = 0.60
    private let maxGlobeZoom: CGFloat = 2.60
    private let buttonZoomLogStep: CGFloat = 0.105
    private let mapControlButtonSize: CGFloat = 44
    private let mapControlNudgeButtonSize: CGFloat = 64
    private let mapControlSpacing: CGFloat = 10
    private let mapControlTrailingInset: CGFloat = 34
    private let mapControlVerticalRatio: CGFloat = 0.44
    
    @State private var persistentGlobeZoom: CGFloat = 1.0
    @State private var pinchStartZoom: CGFloat?
    /// Accumulated user rotation on top of the base orientation — fully unconstrained.
    @State private var persistentUserRotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    @State private var globeBaseMode: GlobeView.BaseMode = .pair
    @State private var isGlobeDragging = false
    /// Snapshot of user rotation captured at the START of each drag gesture.
    @State private var dragStartUserRotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    /// Tracks the startLocation of the most recent drag gesture to detect new gesture starts
    /// even when isGlobeDragging is stuck true (e.g. interrupted by tab switch or system alert).
    @State private var lastDragStartLocation: CGPoint = .zero
    /// Accumulated auto-rotation angle (radians). Applied in Earth body-space so
    /// the spin direction correctly flips when the globe is held upside-down.
    @State private var autoRotAngle: Float = 0
    @State private var routeRevealProgress: CGFloat = 0
    @State private var routeAnimationVersion: Int = 0
    @State private var isContactSelectorExpanded = false
    @State private var hasSelectedContact = false
    @State private var isGlobePinching = false
    /// Snapshot of user rotation at the START of a two-finger twist gesture.
    @State private var twistStartUserRotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
    @State private var isGlobeTwisting = false
    /// Tracks the screen-space center of the Nudge button placeholder so the real button
    /// can be rendered at zIndex 30 (above globeInteractionLayer at zIndex 10).
    @State private var nudgeButtonCenter: CGPoint = .zero
    /// Frame of MY editable MoodWidget (Your People) — used for the transparent edit button.
    @State private var moodWidgetFrame: CGRect = .zero
    /// Controls the mood-edit sheet (Your People mode).
    @State private var showMyMoodEditor = false
    /// Frame of the visible RingsWidget — used for the transparent tap overlay.
    @State private var ringsWidgetFrame: CGRect = .zero
    /// Controls the Activity Detail sheet.
    @State private var showActivityDetail = false
    /// Full frame of the contact MoodWidget — used for the reaction button overlay & burst.
    @State private var contactMoodWidgetFrame: CGRect = .zero
    private var contactMoodCenter: CGPoint {
        CGPoint(x: contactMoodWidgetFrame.midX, y: contactMoodWidgetFrame.midY)
    }
    /// Whether the reaction emoji picker is shown.
    @State private var showReactionPicker = false
    /// Emoji currently bursting; nil when no animation is running.
    @State private var burstEmoji: String? = nil
    /// Persisted reaction per contact (key = contact ID). Never reset on contact switch.
    @State private var contactReactions: [String: String] = [:]

    private var currentContactReaction: String? {
        contactReactions[viewModel.selectedContact.id]
    }

    private let reactionEmojis = ["❤️", "😊", "💪", "🫂", "🔥", "😢"]

    private struct MoodReaction {
        let name: String
        let emoji: String
        let avatar: String
    }
    /// Mock incoming reactions on MY mood. Mom + Hayden share ❤️ to demo multi-user grouping.
    /// Cleared whenever the user updates their mood (old reactions no longer apply).
    @State private var myMoodReactions: [MoodReaction] = [
        MoodReaction(name: "Mom",     emoji: "❤️", avatar: "👩‍🦱"),
        MoodReaction(name: "Hayden",  emoji: "❤️", avatar: "👨‍💻"),
        MoodReaction(name: "Tommy",   emoji: "💪", avatar: "👨‍🦱"),
        MoodReaction(name: "Grandma", emoji: "🫂", avatar: "👵"),
    ]
    /// Reactions grouped by emoji, preserving first-seen order.
    private var groupedMoodReactions: [(emoji: String, reactions: [MoodReaction])] {
        var seen: [String] = []
        var map:  [String: [MoodReaction]] = [:]
        for r in myMoodReactions {
            if map[r.emoji] == nil { seen.append(r.emoji) }
            map[r.emoji, default: []].append(r)
        }
        return seen.compactMap { emoji in
            map[emoji].map { (emoji: emoji, reactions: $0) }
        }
    }
    /// Whether the "reactions received" sheet is shown.
    @State private var showMyMoodReactions = false
    /// Controls the My Today edit sheet.
    @State private var showTodayEditor = false
    /// Frame of the visible HeartWidget — used for the transparent tap overlay.
    @State private var heartWidgetFrame: CGRect = .zero
    /// Controls the Health Detail sheet.
    @State private var showHealthDetail = false
    /// Frame of the visible TodayWidget — used for the two tap overlays.
    @State private var todayWidgetFrame: CGRect = .zero
    /// Post to show in the detail sheet. Non-nil = sheet is presented; nil = dismissed.
    /// Using sheet(item:) ensures the sheet only ever opens with valid post data.
    @State private var todayDetailPost: TodayPost? = nil

    var body: some View {
        GeometryReader { proxy in
            let bottomPanelLift = max(CGFloat(4), proxy.safeAreaInsets.bottom - 18)
            let globeGap = max(CGFloat(62), min(CGFloat(140), proxy.size.height * 0.16 - 10))
            
            ZStack {
                LinearGradient(
                    colors: [Color.stBackgroundGradientTop, Color.stBackgroundGradientBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Fixed background layer: space + earth stay in place while widgets scroll above.
                GlobeView(
                    fromCoordinate: viewModel.currentUser.location,
                    toCoordinate: hasSelectedContact ? viewModel.selectedContact.location : nil,
                    distanceMiles: viewModel.distanceMiles,
                    daysApart: viewModel.selectedContact.daysApart,
                    showNudgeRipple: viewModel.activeNudgeAnimation,
                    zoom: effectiveGlobeZoom,
                    userRotation: persistentUserRotation,
                    autoRotAngle: autoRotAngle,
                    baseMode: globeBaseMode,
                    routeRevealProgress: routeRevealProgress,
                    contactAvatar: viewModel.selectedContact.avatarEmoji,
                    showsOverview: !hasSelectedContact,
                    overviewContacts: hasSelectedContact ? [] : viewModel.contacts
                )
                .ignoresSafeArea()
                
                LinearGradient(
                    colors: [Color.clear, Color.stBackground.opacity(0.35), Color.stBackground.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
                
                GlassEffectContainer(spacing: 18) {
                    VStack(spacing: 14) {
                        UserSelectorBar(
                            contacts: viewModel.contacts,
                            selectedContact: hasSelectedContact ? viewModel.selectedContact : nil,
                            myAvatarEmoji: viewModel.currentUser.avatarEmoji,
                            onSelect: { selectContactAndReplayRoute($0) },
                            onDeselect: {
                                withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
                                    hasSelectedContact = false
                                }
                            },
                            onExpansionChanged: { expanded in
                                isContactSelectorExpanded = expanded
                            }
                        )
                        
                        if hasSelectedContact {
                            HStack(spacing: 14) {
                                MoodWidget(
                                    mood: viewModel.selectedMood,
                                    contactName: viewModel.selectedContact.name,
                                    isEditable: false,
                                    reactionEmoji: currentContactReaction,
                                    onSetMood: { _ in }
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(GeometryReader { geo in
                                    Color.clear.onAppear {
                                        DispatchQueue.main.async {
                                            contactMoodWidgetFrame = geo.frame(in: .named("home_root"))
                                        }
                                    }
                                })

                                HeartWidget(
                                    health: viewModel.selectedHealth,
                                    contactName: viewModel.selectedContact.name
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(GeometryReader { geo in
                                    Color.clear.onAppear {
                                        DispatchQueue.main.async {
                                            heartWidgetFrame = geo.frame(in: .named("home_root"))
                                        }
                                    }
                                })
                            }
                            .frame(height: 130)
                        } else {
                            // Overview: show MY own data widgets — editable
                            HStack(spacing: 14) {
                                MoodWidget(
                                    mood: viewModel.myMood,
                                    contactName: viewModel.currentUser.name,
                                    isEditable: true,
                                    onSetMood: { viewModel.setMyMoodEntry($0) }
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                // Capture this widget's frame so the tap button can be
                                // positioned above the glass layer in the outer ZStack.
                                .background(GeometryReader { geo in
                                    Color.clear.onAppear {
                                        DispatchQueue.main.async {
                                            moodWidgetFrame = geo.frame(in: .named("home_root"))
                                        }
                                    }
                                })

                                HeartWidget(
                                    health: viewModel.myHealth,
                                    contactName: viewModel.currentUser.name
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(GeometryReader { geo in
                                    Color.clear.onAppear {
                                        DispatchQueue.main.async {
                                            heartWidgetFrame = geo.frame(in: .named("home_root"))
                                        }
                                    }
                                })
                            }
                            .frame(height: 130)
                        }
                        
                        Spacer(minLength: globeGap)
                        
                        if hasSelectedContact {
                            VStack(alignment: .leading, spacing: 0) {
                                // Capsule + Nudge in a ZStack so each can be offset independently.
                                ZStack(alignment: .topLeading) {
                                    // Capsule: left-aligned, offset down 20 from the shared base.
                                    HStack(spacing: 6) {
                                        Image(systemName: "location.fill")
                                            .font(.caption2)
                                            .foregroundStyle(Color.stAccent)
                                        Text("\(formattedDistance) • \(viewModel.selectedContact.daysApart) days apart")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.white.opacity(0.92))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .glassEffect(.regular, in: Capsule())
                                    .fixedSize()
                                    .offset(y: 60)
                                    
                                    // Layout anchor only — real Nudge button renders at zIndex 30
                                    // in the outer ZStack so it sits above globeInteractionLayer.
                                    HStack {
                                        Spacer(minLength: 0)
                                        Color.clear
                                            .frame(width: mapControlNudgeButtonSize, height: mapControlNudgeButtonSize)
                                            .overlay(GeometryReader { geo in
                                                Color.clear.onAppear {
                                                    DispatchQueue.main.async {
                                                        nudgeButtonCenter = CGPoint(
                                                            x: geo.frame(in: .named("home_root")).midX,
                                                            y: geo.frame(in: .named("home_root")).midY
                                                        )
                                                    }
                                                }
                                            })
                                    }
                                    .offset(y: 25)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 84)
                                .padding(.top, 5)
                                
                                // Rings + Today row — clearly below the capsule row.
                                HStack(alignment: .top, spacing: 14) {
                                    RingsWidget(
                                        activity: viewModel.selectedActivity
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(GeometryReader { geo in
                                        Color.clear.onAppear {
                                            DispatchQueue.main.async {
                                                ringsWidgetFrame = geo.frame(in: .named("home_root"))
                                            }
                                        }
                                    })
                                    
                                    TodayWidget(
                                        posts: viewModel.selectedTodayPosts,
                                        shareButtonLabel: nil  // no CTA on contact pages
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(GeometryReader { geo in
                                        Color.clear.onAppear {
                                            DispatchQueue.main.async {
                                                todayWidgetFrame = geo.frame(in: .named("home_root"))
                                            }
                                        }
                                    })
                                }
                                .frame(height: 148)
                                .padding(.top, 61)
                            }
                        } else {
                            // Overview: Rings + Today mirroring contact mode layout exactly.
                            VStack(alignment: .leading, spacing: 0) {
                                // Placeholder matching the height the capsule+nudge row occupies
                                // in contact mode (ZStack height 84 + padding.top 5 = 89 pt).
                                Color.clear
                                    .frame(height: 84)
                                    .padding(.top, 5)
                                
                                HStack(alignment: .top, spacing: 14) {
                                    RingsWidget(
                                        activity: viewModel.myActivity
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(GeometryReader { geo in
                                        Color.clear.onAppear {
                                            DispatchQueue.main.async {
                                                ringsWidgetFrame = geo.frame(in: .named("home_root"))
                                            }
                                        }
                                    })
                                    
                                    TodayWidget(
                                        posts: viewModel.myTodayPosts,
                                        shareButtonLabel: "Edit My Today"  // CTA only on home/overview
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(GeometryReader { geo in
                                        Color.clear.onAppear {
                                            DispatchQueue.main.async {
                                                todayWidgetFrame = geo.frame(in: .named("home_root"))
                                            }
                                        }
                                    })
                                }
                                .frame(height: 148)
                                .padding(.top, 61)
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, bottomPanelLift + 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                // Cards sit above globeInteractionLayer (zIndex 10) so all card taps register.
                // Transparent Spacer areas between cards pass through to the globe layer.
                .zIndex(15)
                
                globeInteractionLayer(in: proxy.size)
                    .zIndex(10)
                mapControlsLayer(in: proxy.size)
                    .zIndex(20)

                // Nudge button rendered above globeInteractionLayer (zIndex 10) so taps reach it.
                if hasSelectedContact {
                    mapNudgeControlButton {
                        viewModel.sendNudge()
                    }
                    .position(nudgeButtonCenter)
                    .zIndex(30)
                }

                // ── My mood edit button (Your People) ────────────────────
                // Guard: hide when selector is expanded (contact cards overlap this area).
                if !hasSelectedContact && !isContactSelectorExpanded && moodWidgetFrame != .zero {
                    Button { showMyMoodEditor = true } label: {
                        Color.white.opacity(0.001)
                            .frame(width: moodWidgetFrame.width,
                                   height: moodWidgetFrame.height)
                    }
                    .buttonStyle(.plain)
                    .position(x: moodWidgetFrame.midX, y: moodWidgetFrame.midY)
                    .zIndex(25)
                }

                // ── Reaction badge on my MoodWidget (hidden when no reactions) ──
                if !hasSelectedContact && !isContactSelectorExpanded
                    && moodWidgetFrame != .zero && !myMoodReactions.isEmpty {
                    Button { showMyMoodReactions = true } label: {
                        ZStack {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.27, blue: 0.38))
                                .frame(width: 22, height: 22)
                                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                            Text("\(myMoodReactions.count)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: moodWidgetFrame.maxX - 6,
                        y: moodWidgetFrame.minY + 6
                    )
                    .zIndex(26)
                }

                // ── Heart widget tap overlay (lifted above glass layer) ──────
                if !isContactSelectorExpanded && heartWidgetFrame != .zero {
                    Button { showHealthDetail = true } label: {
                        Color.white.opacity(0.001)
                            .frame(width: heartWidgetFrame.width,
                                   height: heartWidgetFrame.height)
                    }
                    .buttonStyle(.plain)
                    .position(x: heartWidgetFrame.midX, y: heartWidgetFrame.midY)
                    .zIndex(25)
                }

                // ── Daily Activity tap overlay (lifted above glass layer) ──
                if !isContactSelectorExpanded && ringsWidgetFrame != .zero {
                    Button { showActivityDetail = true } label: {
                        Color.white.opacity(0.001)
                            .frame(width: ringsWidgetFrame.width,
                                   height: ringsWidgetFrame.height)
                    }
                    .buttonStyle(.plain)
                    .position(x: ringsWidgetFrame.midX, y: ringsWidgetFrame.midY)
                    .zIndex(25)
                }

                // ── Today widget overlays (lifted above glass layer) ──────────
                if !isContactSelectorExpanded && todayWidgetFrame != .zero {
                    // Contact mode: entire widget opens the contact's post detail.
                    // Overview mode: upper portion opens MY post detail, lower
                    //   portion (CTA area) opens TodayEditSheet — home page only.
                    if hasSelectedContact {
                        // Contact: full widget → view detail
                        Button {
                            todayDetailPost = viewModel.selectedTodayPosts.first
                        } label: {
                            Color.white.opacity(0.001)
                                .frame(width: todayWidgetFrame.width,
                                       height: todayWidgetFrame.height)
                        }
                        .buttonStyle(.plain)
                        .position(x: todayWidgetFrame.midX, y: todayWidgetFrame.midY)
                        .zIndex(25)
                    } else if viewModel.myTodayPosts.isEmpty {
                        // No posts yet: entire widget → open editor to create first post
                        Button { showTodayEditor = true } label: {
                            Color.white.opacity(0.001)
                                .frame(width: todayWidgetFrame.width,
                                       height: todayWidgetFrame.height)
                        }
                        .buttonStyle(.plain)
                        .position(x: todayWidgetFrame.midX, y: todayWidgetFrame.midY)
                        .zIndex(25)
                    } else {
                        let btnH: CGFloat = 36
                        let upperH = todayWidgetFrame.height - btnH

                        // Overview upper: tap to view MY Today post detail
                        Button {
                            todayDetailPost = viewModel.myTodayPosts.first
                        } label: {
                            Color.white.opacity(0.001)
                                .frame(width: todayWidgetFrame.width, height: upperH)
                        }
                        .buttonStyle(.plain)
                        .position(
                            x: todayWidgetFrame.midX,
                            y: todayWidgetFrame.minY + upperH / 2
                        )
                        .zIndex(25)

                        // Overview lower (CTA area): open TodayEditSheet — home only
                        Button { showTodayEditor = true } label: {
                            Color.white.opacity(0.001)
                                .frame(width: todayWidgetFrame.width, height: btnH)
                        }
                        .buttonStyle(.plain)
                        .position(
                            x: todayWidgetFrame.midX,
                            y: todayWidgetFrame.maxY - btnH / 2
                        )
                        .zIndex(25)
                    }
                }

                // ── Contact reaction button (lifted above glass layer) ────
                // A small hit area over the ❤️ reaction icon on the right-center
                // of the contact MoodWidget — same pattern as the edit button.
                if hasSelectedContact && !isContactSelectorExpanded
                    && contactMoodWidgetFrame != .zero {
                    Button { showReactionPicker = true } label: {
                        Color.white.opacity(0.001)
                            .frame(width: 52, height: 52)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    // Position at right-center of the widget (where the ❤️ icon sits)
                    .position(
                        x: contactMoodWidgetFrame.maxX - 30,
                        y: contactMoodWidgetFrame.midY
                    )
                    .zIndex(25)
                }

                // ── Reaction picker overlay (contact mode) ────────────────
                if showReactionPicker {
                    // Transparent dismiss layer behind the picker
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                                showReactionPicker = false
                            }
                        }
                        .zIndex(39)

                    reactionPickerOverlay
                        // Center the ring on the ❤️ icon position (right-center of widget)
                        .position(x: contactMoodWidgetFrame.maxX - 30,
                                  y: contactMoodWidgetFrame.midY)
                        .zIndex(40)
                }

                // ── Emoji burst animation ─────────────────────────────────
                if let emoji = burstEmoji {
                    ReactionBurstView(emoji: emoji, origin: contactMoodCenter) {
                        burstEmoji = nil
                    }
                    .zIndex(50)
                }
            }
            .coordinateSpace(name: "home_root")
            .sheet(isPresented: $showMyMoodEditor) {
                MoodEditSheet(
                    isPresented: $showMyMoodEditor,
                    onSave: {
                        viewModel.setMyMoodEntry($0)
                        myMoodReactions = []
                    }
                )
            }
            .sheet(isPresented: $showActivityDetail) {
                ActivityDetailSheet(
                    activity: hasSelectedContact ? viewModel.selectedActivity : viewModel.myActivity
                )
            }
            .sheet(isPresented: $showHealthDetail) {
                HealthDetailSheet(
                    health: hasSelectedContact ? viewModel.selectedHealth : viewModel.myHealth,
                    contactName: hasSelectedContact
                        ? viewModel.selectedContact.name
                        : viewModel.currentUser.name
                )
            }
            .sheet(isPresented: $showMyMoodReactions) {
                myMoodReactionsSheet
            }
            .sheet(isPresented: $showTodayEditor) {
                TodayEditSheet(isPresented: $showTodayEditor) { post in
                    viewModel.addMyTodayPost(post)
                }
            }
            .sheet(item: $todayDetailPost) { post in
                TodayDetailView(
                    post: post,
                    onReaction: { viewModel.addReaction($0, to: $1) },
                    isMyPost: post.userId == "me",
                    initialSentNotes: viewModel.notes(for: post),
                    onNoteSent: { viewModel.addNote($0, to: post) },
                    onDelete: post.userId == "me" ? {
                        viewModel.deleteMyTodayPost(post)
                    } : nil
                )
                .presentationDetents([.medium, .large])
                .presentationBackground(.ultraThinMaterial)
                .presentationCornerRadius(28)
            }
            .onChange(of: viewModel.selectedContact.id) { _, _ in
                guard hasSelectedContact else { return }
                showReactionPicker = false   // close picker, but keep reactions dict intact
                resetGlobeViewport(for: viewModel.selectedContact, animated: true)
                restartRouteRevealAnimation()
            }
            .onAppear {
                hasSelectedContact = false
                resetGlobeViewport(for: nil)
                routeAnimationVersion += 1
                routeRevealProgress = 1
            }
            .onChange(of: homeRetapID) { _, _ in
                guard hasSelectedContact else { return }
                withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
                    hasSelectedContact = false
                }
                resetGlobeViewport(for: nil, animated: true)
                routeAnimationVersion += 1
                routeRevealProgress = 1
            }
            .onDisappear {
                isGlobePinching = false
                isGlobeDragging = false
                isGlobeTwisting = false
                lastDragStartLocation = .zero
            }
            // Auto-rotate globe in Earth BODY space (+Y axis of the globe itself).
            // Because the rotation is applied as `base * autoRot` (right-multiply in
            // GlobeView), the spin always follows the geographic north-south axis:
            //   • Globe upright  → surface drifts left-to-right (realistic west-east)
            //   • Globe flipped  → surface drifts right-to-left (correctly reversed)
            // Pauses whenever the user is dragging or pinching.
            .task(id: hasSelectedContact) {
                guard !hasSelectedContact else { return }
                while !Task.isCancelled {
                    if !isGlobeDragging && !isGlobePinching {
                        autoRotAngle += 0.0007
                    }
                    try? await Task.sleep(nanoseconds: 33_333_333) // ~30 fps
                }
            }
        }
    }
    
    private var formattedDistance: String {
        "\(viewModel.distanceMiles.formatted(.number.grouping(.automatic))) miles"
    }
    
    private var effectiveGlobeZoom: CGFloat {
        clampedZoom(persistentGlobeZoom)
    }
    
    private func resetGlobeViewport(for contact: User?, animated: Bool = false) {
        let targetZoom = contact.map(autoViewportZoom(for:)) ?? 1.0
        // When focusing on a contact, reset the accumulated auto-rotation so their
        // location is perfectly centred (auto-rotation is paused while a contact
        // is selected, so the angle stays at 0 until overview resumes).
        if contact != nil { autoRotAngle = 0 }
        let updates = {
            persistentGlobeZoom = targetZoom
            persistentUserRotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
            globeBaseMode = .pair
        }
        
        if animated {
            withAnimation(.interactiveSpring(response: 0.36, dampingFraction: 0.92)) {
                updates()
            }
        } else {
            updates()
        }
    }
    
    private func selectContactAndReplayRoute(_ contact: User) {
        hasSelectedContact = true
        let isSameContact = contact.id == viewModel.selectedContact.id
        
        // Cancel current route immediately so old line does not linger.
        routeAnimationVersion += 1
        routeRevealProgress = 0
        
        viewModel.selectContact(contact)
        
        // Same-contact selection does not trigger onChange, so replay here.
        if isSameContact {
            resetGlobeViewport(for: contact, animated: true)
            restartRouteRevealAnimation()
        }
    }
    
    private func restartRouteRevealAnimation() {
        routeAnimationVersion += 1
        let version = routeAnimationVersion
        routeRevealProgress = 0
        
        let startDelay: Double = 0.18
        let duration: Double = 1.82
        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            guard version == routeAnimationVersion else { return }
            withAnimation(.linear(duration: duration)) {
                routeRevealProgress = 1
            }
        }
    }
    
    @ViewBuilder
    private func globeInteractionLayer(in size: CGSize) -> some View {
        let zone = globeInteractionZone(in: size)
        
        // Rectangle covers corners better than an Ellipse, giving users
        // the full zone width to swipe through when rotating to far-away contacts.
        Rectangle()
            .fill(Color.white.opacity(0.001))
            .frame(width: zone.width, height: zone.height)
            .position(x: zone.midX, y: zone.midY)
            .contentShape(Rectangle())
            .highPriorityGesture(globeRotateGesture(in: size, zone: zone))
            .simultaneousGesture(globeMagnifyGesture())
            .simultaneousGesture(globeTwistGesture())
            .allowsHitTesting(!isContactSelectorExpanded)
    }
    
    private func globeInteractionZone(in size: CGSize) -> CGRect {
        // Zone must start below the UserSelectorBar card (~top 35% of screen)
        // to avoid the highPriorityGesture eating card taps.
        let zoneWidth = size.width * 0.90
        let zoneHeight = size.height * 0.62
        let x = size.width * 0.00
        let y = size.height * 0.36
        return CGRect(x: x, y: y, width: zoneWidth, height: zoneHeight)
    }
    
    private func globeRotateGesture(in size: CGSize, zone: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .named("home_root"))
            .onChanged { value in
                // Detect a genuinely new gesture by comparing startLocation.
                // If the touch-down point differs from the last recorded one,
                // this is a fresh gesture — reset any stuck isGlobeDragging state
                // that can occur when a previous gesture was interrupted by a tab
                // switch or system alert without firing onEnded.
                if value.startLocation != lastDragStartLocation {
                    lastDragStartLocation = value.startLocation
                    isGlobeDragging = false
                }

                if !isGlobeDragging {
                    guard zone.contains(value.startLocation) else { return }
                    guard !isInsideControlColumn(value.startLocation, in: size) else { return }
                    isGlobeDragging = true
                    // Snapshot the current rotation once at gesture start.
                    // All subsequent events compute the full rotation from total
                    // translation × this snapshot — no stale-delta issues.
                    dragStartUserRotation = persistentUserRotation
                }

                guard isGlobeDragging else { return }

                // Use TOTAL translation from gesture origin (not delta) so the
                // final orientation is always deterministic regardless of SwiftUI
                // render-cycle batching.
                let dx = Float(value.translation.width)
                let dy = Float(value.translation.height)

                let sensitivity: Float = 0.011
                let rotY = simd_quatf(angle:  dx * sensitivity, axis: SIMD3<Float>(0, 1, 0))
                let rotX = simd_quatf(angle:  dy * sensitivity, axis: SIMD3<Float>(1, 0, 0))
                persistentUserRotation = simd_normalize(rotX * rotY * dragStartUserRotation)
            }
            .onEnded { _ in
                isGlobeDragging = false
                lastDragStartLocation = .zero
            }
    }
    
    private func globeMagnifyGesture() -> some Gesture {
        MagnifyGesture(minimumScaleDelta: 0.001)
            .onChanged { value in
                if !isGlobePinching {
                    isGlobePinching = true
                }
                if pinchStartZoom == nil {
                    pinchStartZoom = persistentGlobeZoom
                }
                let base = pinchStartZoom ?? persistentGlobeZoom
                let targetZoom = clampedZoom(base * value.magnification)
                
                // Log-domain smoothing keeps the perceived zoom speed consistent.
                let currentLog = log(max(persistentGlobeZoom, minGlobeZoom))
                let targetLog = log(max(targetZoom, minGlobeZoom))
                let nextLog = currentLog + (targetLog - currentLog) * 0.26
                persistentGlobeZoom = clampedZoom(exp(nextLog))
            }
            .onEnded { value in
                let base = pinchStartZoom ?? persistentGlobeZoom
                pinchStartZoom = nil
                let next = clampedZoom(base * value.magnification)
                withAnimation(.interactiveSpring(response: 0.24, dampingFraction: 0.9)) {
                    persistentGlobeZoom = next
                }
                if isGlobePinching {
                    isGlobePinching = false
                }
            }
    }
    
    private func globeTwistGesture() -> some Gesture {
        RotationGesture(minimumAngleDelta: .degrees(1))
            .onChanged { value in
                if !isGlobeTwisting {
                    isGlobeTwisting = true
                    twistStartUserRotation = persistentUserRotation
                }
                // Rotate around the camera's Z axis (axis pointing out of screen).
                // Negate so the globe surface moves with the fingers (natural direction).
                let angle = Float(-value.radians)
                let rotZ = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 0, 1))
                persistentUserRotation = simd_normalize(rotZ * twistStartUserRotation)
            }
            .onEnded { _ in
                isGlobeTwisting = false
            }
    }

    @ViewBuilder
    private func mapControlsLayer(in size: CGSize) -> some View {
        VStack(spacing: mapControlSpacing) {
            mapControlButton(icon: "location.fill") {
                performMapControlInteraction {
                    autoRotAngle = 0
                    withAnimation(.interactiveSpring(response: 0.30, dampingFraction: 0.92)) {
                        globeBaseMode = .me
                        persistentUserRotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
                        persistentGlobeZoom = 1.05
                    }
                }
            }
            
            mapControlButton(icon: "plus") {
                performMapControlInteraction {
                    let nextZoom = steppedZoom(persistentGlobeZoom, direction: 1)
                    withAnimation(.interactiveSpring(response: 0.24, dampingFraction: 0.88)) {
                        persistentGlobeZoom = nextZoom
                    }
                }
            }
            
            mapControlButton(icon: "minus") {
                performMapControlInteraction {
                    let nextZoom = steppedZoom(persistentGlobeZoom, direction: -1)
                    withAnimation(.interactiveSpring(response: 0.24, dampingFraction: 0.88)) {
                        persistentGlobeZoom = nextZoom
                    }
                }
            }
        }
        .position(
            x: size.width - mapControlTrailingInset,
            y: size.height * mapControlVerticalRatio + 24
        )
    }
    
    private func mapControlButton(icon: String, action: @escaping () -> Void) -> some View {
        Image(systemName: icon)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white.opacity(0.95))
            .frame(width: mapControlButtonSize, height: mapControlButtonSize)
            .glassEffect(.regular.interactive(), in: Circle())
            .contentShape(Circle())
            .highPriorityGesture(
                TapGesture().onEnded { action() }
            )
            .accessibilityAddTraits(.isButton)
    }
    
    private func mapNudgeControlButton(action: @escaping () -> Void) -> some View {
        VStack(spacing: 3) {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 22, weight: .semibold))
            Text("Nudge")
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(Color.stAccent)
        .frame(width: mapControlNudgeButtonSize, height: mapControlNudgeButtonSize)
        .glassEffect(.regular.tint(Color.stAccent.opacity(0.28)), in: Circle())
        .contentShape(Circle())
        .highPriorityGesture(TapGesture().onEnded { action() })
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Nudge")
    }
    
    private func isInsideControlColumn(_ point: CGPoint, in size: CGSize) -> Bool {
        let centerX = size.width - mapControlTrailingInset
        let centerY = size.height * mapControlVerticalRatio + 24
        let columnHeight = mapControlButtonSize * 3 + mapControlSpacing * 2
        let frame = CGRect(
            x: centerX - mapControlButtonSize * 0.5 - 20,
            y: centerY - columnHeight * 0.5 - 20,
            width: mapControlButtonSize + 40,
            height: columnHeight + 40
        )
        return frame.contains(point)
    }
    
    
    private func clampedZoom(_ value: CGFloat) -> CGFloat {
        min(max(value, minGlobeZoom), maxGlobeZoom)
    }
    
    private func steppedZoom(_ currentZoom: CGFloat, direction: CGFloat) -> CGFloat {
        let currentLog = log(max(currentZoom, minGlobeZoom))
        let target = exp(currentLog + direction * buttonZoomLogStep)
        return clampedZoom(target)
    }
    
    private func autoViewportZoom(for contact: User) -> CGFloat {
        let miles = Double(viewModel.currentUser.location.distanceInMiles(to: contact.location))
        let clampedMiles = min(max(miles, 150), 9_000)
        let normalized = (clampedMiles - 150) / (9_000 - 150)
        let eased = pow(normalized, 0.68)
        
        let nearZoom: CGFloat = 1.62
        let farZoom: CGFloat = 0.84
        let zoom = nearZoom - CGFloat(eased) * (nearZoom - farZoom)
        return clampedZoom(zoom)
    }
    
    private func performMapControlInteraction(_ updates: () -> Void) {
        updates()
    }

    // ── Reaction picker ───────────────────────────────────────────────────────
    @ViewBuilder
    /// Ring picker: 6 reaction emojis + 1 trash (clear) button arranged in a circle.
    /// Center ✕ = dismiss picker only (no change to reaction).
    /// Positioned in HomeTabView at the reaction icon's screen location.
    private var reactionPickerOverlay: some View {
        let radius: CGFloat = 64
        // 7 items evenly spaced: 6 emojis + trash icon (clear reaction)
        // Start from top (−90°) going clockwise
        let itemCount = 7
        let startAngle = -90.0   // top
        let stepAngle  = 360.0 / Double(itemCount)

        return ZStack {
            // Frosted background circle
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: radius * 2 + 56, height: radius * 2 + 56)
                .shadow(color: .black.opacity(0.30), radius: 16, y: 5)

            // 6 reaction emojis (indices 0–5)
            ForEach(0..<6) { i in
                let angleDeg = startAngle + stepAngle * Double(i)
                let rad = angleDeg * Double.pi / 180
                let emoji = reactionEmojis[i]
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                        showReactionPicker = false
                    }
                    contactReactions[viewModel.selectedContact.id] = emoji
                    burstEmoji = emoji
                } label: {
                    Text(emoji)
                        .font(.system(size: 26))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.white.opacity(0.10)))
                }
                .buttonStyle(.plain)
                .offset(x: CGFloat(cos(rad)) * radius,
                        y: CGFloat(sin(rad)) * radius)
            }

            // 7th item: trash icon = clear/remove current reaction
            let clearAngleDeg = startAngle + stepAngle * 6
            let clearRad = clearAngleDeg * Double.pi / 180
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                    showReactionPicker = false
                }
                contactReactions.removeValue(forKey: viewModel.selectedContact.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.red.opacity(0.85))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.red.opacity(0.12)))
            }
            .buttonStyle(.plain)
            .offset(x: CGFloat(cos(clearRad)) * radius,
                    y: CGFloat(sin(clearRad)) * radius)

            // Center ✕ = dismiss picker only (does NOT change reaction)
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                    showReactionPicker = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.70))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.white.opacity(0.14)))
            }
            .buttonStyle(.plain)
        }
        .transition(.scale(scale: 0.3).combined(with: .opacity))
    }

    // MARK: - My Mood Reactions Sheet

    private var myMoodReactionsSheet: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ───────────────────────────────────────────────────────
            HStack(alignment: .firstTextBaseline) {
                Text("Reactions")
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
                Text("to your mood")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 20)

            // ── Current mood summary ─────────────────────────────────────────
            HStack(spacing: 12) {
                Text(viewModel.myMood.emoji)
                    .font(.system(size: 36))
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.myMood.label)
                        .font(.headline).fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(viewModel.myMood.activity)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            Divider()
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

            // ── Grouped reaction rows ────────────────────────────────────────
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(groupedMoodReactions.enumerated()), id: \.offset) { idx, group in
                        reactionGroupRow(group)

                        if idx < groupedMoodReactions.count - 1 {
                            Divider()
                                .padding(.leading, 82)
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .presentationDetents([.medium])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(28)
    }

    /// Single grouped row: overlapping avatar circles + names + reaction emoji.
    @ViewBuilder
    private func reactionGroupRow(_ group: (emoji: String, reactions: [MoodReaction])) -> some View {
        HStack(spacing: 14) {

            // Overlapping avatar circles
            let avatars = group.reactions.prefix(3)
            ZStack(alignment: .leading) {
                ForEach(Array(avatars.enumerated()), id: \.offset) { idx, r in
                    Circle()
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 42, height: 42)
                        .overlay(
                            Text(r.avatar)
                                .font(.system(size: 22))
                        )
                        .overlay(Circle().stroke(Color(red: 0.09, green: 0.09, blue: 0.15), lineWidth: 2))
                        .offset(x: CGFloat(idx) * 24)
                }
            }
            .frame(
                width: avatars.count > 1
                    ? 42 + 24 * CGFloat(avatars.count - 1)
                    : 42,
                height: 42
            )

            // Names + subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedNames(group.reactions))
                    .font(.body).fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text("reacted to your mood")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Reaction emoji badge
            Text(group.emoji)
                .font(.system(size: 28))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }

    private func formattedNames(_ reactions: [MoodReaction]) -> String {
        let names = reactions.map(\.name)
        switch names.count {
        case 1:  return names[0]
        case 2:  return "\(names[0]) & \(names[1])"
        default: return "\(names[0]), \(names[1]) & \(names.count - 2) more"
        }
    }

}

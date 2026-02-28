# StayinTouch — Swift Student Challenge 2026

A gentle way to stay connected across distances. See their mood, know they're healthy, share moments — and send a nudge that says "I'm thinking of you."

## Why SceneKit Instead of MapKit?

**Swift Student Challenge requires completely offline operation.** Submissions are judged offline; no network connection is allowed. MapKit's globe view fetches map tiles from the network, so it would not work during judging.

We use **SceneKit** with bundled earth textures instead — fully offline, no network required.

## Tech Stack

- **SwiftUI** + **iOS 26** Liquid Glass design
- **SceneKit** for 3D globe (offline)
- **@Observable** for state management
- **Solar System Scope 8K Earth textures** (bundled local assets)

## Project Structure

- `StayinTouchApp.swift` — App entry, Onboarding flow
- `RootTabView.swift` — Tab navigation: Home | Today | Settings
- `Views/` — Home, Today feed, Settings, Widgets, Globe
- `Models/` — User, Mood, Health, Activity, TodayPost
- `ViewModels/AppViewModel.swift` — Central state

## Build

Open `StayinTouch.swiftpm` in Xcode 26. Requires iOS 26+ for Liquid Glass APIs.

## Earth Texture Attribution

Earth texture assets are sourced from Solar System Scope textures (CC BY 4.0):

- https://www.solarsystemscope.com/textures/

Bundled files live in `Resources/Textures/Earth/`.

# StayinTouch — Swift Student Challenge 2026

A gentle way to stay connected across distances. See their mood, know they're healthy, share moments — and send a nudge that says "I'm thinking of you."

## The Story

### English

I'm an international student in the US and have been studying here for four years. For students like us, separation is something we can't avoid. These past few years, with the world the way it is, going home has been rare — in four years I've only been back once. Even so far from family and friends, I still care about them and want to know how they're doing. And it's not just us: parents of students abroad worry about their kids all the time and fear for their safety. But everyone is busy with class and work, and there isn't much time to talk. That's why I wanted to build this app: to get a quick sense of how someone is doing through a few widgets — mood, health, activity, and what they're up to today.

One feature I'm especially proud of is location sharing. Besides simple on/off, I added a third option: turn off live location but show your *current* position to others for a few days. Location can be a way we show we care, but it can also feel like a leash. Student life is stressful; sometimes you need to let go — a spontaneous trip, driving hundreds of miles at night to watch the sunrise by the ocean. If your parents see that on the map... well. But you can't just turn location off, or the phone will ring right away. So I designed this middle ground: a little bit of privacy when you need it.

I also didn't add per-person location toggles. My assumption is that the people in this app are the ones closest to you, and they're all equal — no need to restrict one person and not another. If there's something you don't want someone to see, maybe they shouldn't be in this app at all.

### 中文

我是一名在美留学生，已经在美国学习四年了。作为一名留学生，离别是绕不开的话题。这几年，世界局势不稳定，回家的次数屈指可数，四年留学生涯只回去了一次，虽与亲朋好友远隔万里，仍然关心他们关注他们。当然不仅仅是我们，作为留学生的父母，也无时无刻的在关心他们的孩子们，为他们的安全担惊受怕。但是大家平时上课工作都忙，也没有多少时间可以去交流，因此我想到了制作这么一个app，目标是通过几个widgets快速了解一个人的状态。设想是有这些widgets，心情，健康，运动还有今日趣事。

这里面有个非常有意思的功能，就是我设计了定位模式除了关闭和开启，额外还有一个关闭但是对其他用户显示你当前的位置几天。因为定位服务既是我们相互之间的关心，偶尔也会成为一个枷锁。留学生活压力大，总需要放纵几下，比如说走就走的旅行，深夜开车几百公里去海边看日出等等。但这个时候如果父母通过定位看到了你的位置...嘿嘿，但是我们又不能直接关闭定位，因为这样父母的电话马上就会打过来了。所以我特别设计了一个这个功能，就是给大家一点点的隐私空间。

此外定位服务我没有针对单个用户进行开关设置，因为我默认能进入你世界的人一定是你最亲密的人，他们之间是没有高低的，也不需要单独对某个人设限制。如果你有什么东西不想给ta看的话，那我认为ta其实就不应该出现在这个app中。

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

# StayinTouch — Swift Student Challenge 2026

A gentle way to stay connected across distances. See their mood, know they're healthy, share moments — and send a nudge that says "I'm thinking of you."

## The Story

### English

As an international student in the US for the past four years, saying goodbye has basically become my daily routine. With everything going on in the world lately, trips back home have been exceptionally difficult. In fact, I have only made it back once in my entire college life. Even though my family and friends are thousands of miles away, we are always thinking about each other. It is not just us students either. Our parents are constantly worrying about our safety and well being. But let us be real. Between classes, assignments, and work, finding the time for a long catch up call is tough. That is why I came up with the idea for this app. I wanted to create a way to instantly feel connected through a few simple widgets. The goal is to let you check in on someone at a glance with widgets for mood, health, daily activities, and fun little moments.

There is one really fun feature I just have to share. Location sharing is a beautiful way to show you care, but it can also feel like a bit of a leash. College life is stressful and sometimes you just need to let loose. Maybe that means a spontaneous road trip or driving hundreds of miles in the middle of the night to watch the sunrise at the beach. If my parents saw my little dot zooming down the highway at 3 AM, my phone would absolutely blow up. But if I just turn off my location, they would panic and call anyway. So I designed a special stealth mode. Instead of just toggling your location on or off, you can freeze it to show your last safe spot for a few days. It gives everyone that much needed breathing room and privacy without giving your parents a sudden fright.

You will also notice there are no individual toggles to hide your location from specific people. My philosophy here is simple. The people you invite into this app are your absolute closest inner circle. In a genuine relationship like that, there is no hierarchy and there should be no need for individual boundaries. If there is something you really do not want someone to see, then honestly, they probably do not belong in your app in the first place.

### 中文

我是一名在美留学生，已经在美国学习四年了。作为一名留学生，离别是绕不开的话题。这几年，世界局势不稳定，回家的次数屈指可数，四年留学生涯只回去了一次，虽与亲朋好友远隔万里，仍然关心他们关注他们。当然不仅仅是我们，作为留学生的父母，也无时无刻的在关心他们的孩子们，为他们的安全担惊受怕。但是大家平时上课工作都忙，也没有多少时间可以去交流，因此我想到了制作这么一个app，目标是通过几个widgets快速了解一个人的状态。设想是有这些widgets，心情，健康，运动还有今日趣事。

有一个非常有趣的功能我必须跟你们分享一下。位置共享是一种很好的表达关心的方式，但有时也会让人感觉有点像被束缚住了。大学生活压力很大，有时候真的需要放松下。也许这意味着一次突然的公路旅行，或者在半夜驱车几百公里去海滩看日出。但如果你的父母看到你那个小小的标记在凌晨 3 点沿着高速公路疾驰...嘿嘿 但如果只是关闭位置信息，他们还是会惊慌失措地打电话过来。所以我设计了一个特殊的隐身模式。它不是简单地打开或关闭你的位置信息，而是可以将位置信息冻结，显示你最近的安全地点，持续几天。这为每个人提供了急需的喘息空间和隐私，又不会让父母突然感到惊慌。

你还会注意到，这里没有专门的开关来隐藏你的位置信息给特定的人。我的理念很简单。邀请加入这个应用程序的人，就是最亲密的核心圈子成员。在这样的真实关系中，不存在等级之分，也就无需设置个人界限。如果有什么东西真的不想让某人看到，那么坦率地说，他们可能根本就不应该出现在你的联系人中。

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

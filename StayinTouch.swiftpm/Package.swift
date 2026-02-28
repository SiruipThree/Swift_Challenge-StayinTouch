// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "StayinTouch",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .iOSApplication(
            name: "StayinTouch",
            targets: ["AppModule"],
            bundleIdentifier: "com.threesiruipeng.stayintouch",
            teamIdentifier: "C87GBAC2UJ",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .heart),
            accentColor: .asset("AccentColor"),
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [.portrait],
            appCategory: .socialNetworking
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            exclude: [
                "Package.swift",
                ".swiftpm",
                ".build",
                "DerivedData"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)

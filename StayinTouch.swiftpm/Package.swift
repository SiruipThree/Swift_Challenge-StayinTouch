// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "StayinTouch",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "StayinTouch",
            targets: ["AppModule"],
            bundleIdentifier: "com.stayintouch.app",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .heart),
            accentColor: .presetColor(.cyan),
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [.portrait],
            appCategory: .socialNetworking
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            exclude: ["Package.swift"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)

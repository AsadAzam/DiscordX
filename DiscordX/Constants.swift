//
//  Constants.swift
//  DiscordX
//
//  Created by Asad Azam on 28/9/20.
//  Copyright © 2021 Asad Azam. All rights reserved.
//

import Foundation

// used to register for notifs when Xcode opens/closes
let xcodeBundleId = "com.apple.dt.Xcode"

// how often we check Xcode for a status update
let refreshInterval = 5 // seconds

// if you switch out of Xcode the timer stops
/// true: timer will stop
/// false: timer will not stop
let strictMode = true

// it will never stop the timer regardless of anything except if you kill DiscordX
/// true: timer will not stop
/// false: timer will stop
let flauntMode = false

// some other window names of Xcode
let xcodeWindowNames = [
    "Simulator",
    "Instruments",
    "Accessibility Inspector",
    "FileMerge",
    "Create ML",
    "RealityComposer",
    //doc://com.apple.documentation -> Process name -> Xcode Documentation
    //unable to find organiser
]

// The following constants are for use with the Discord App
// if you're using your own Discord App, update this as needed

let discordClientId = "759699771689795615"

// Chaniging the below list of files won't do anything as they are hardcoded
// on the discord application. To add images you need to create your own application

// discord image keys of supported file types
let discordRPImageKeys = [
    "swift",
    "playground",
    "storyboard",
    "xcodeproj",
    "h",
    "m",
    "cpp",
    "c",
    "sdef",
    "plist",
    "md",
    "appex",
    "rcproject",
    "rtf",
    "rtfd",
    "pch",
    "mm",
    "xcassets",
    "iig",
    "metal",
    "xib",
    "arobject",
    "entitlements",
]

// default for unsupported file types
let discordRPImageKeyDefault = "xcode"

// Xcode application icon
let discordRPImageKeyXcode = "xcode"


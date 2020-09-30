//
//  AppDelegate.swift
//  DiscordX
//
//  Created by Asad Azam on 28/9/20.
//  Copyright © 2020 Asad Azam. All rights reserved.
//

import Cocoa

import SwordRPC

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

//    var window: NSWindow!
    var timer: Timer?
    var rpc: SwordRPC?
    var startDate: Date?
    var lastWindow: String?

    func beginTimer() {
        timer = Timer(timeInterval: TimeInterval(refreshInterval), repeats: true, block: { _ in
            self.updateStatus()
//            print(Date())
        })
        RunLoop.main.add(timer!, forMode: .common)
        timer!.fire()
    }

    func clearTimer() {
        timer?.invalidate()
    }

    func updateStatus() {
        var p = RichPresence()
        
        let an = getActiveWindow() // an -> Application Name
        
        let fn = getActiveFilename() //fn -> File Name
        let ws = getActiveWorkspace() //ws -> Workspace

        // determine file type
        if fn != nil && an == "Xcode" {
            p.details = "Editing \(fn!)"

            if let fileExt = getFileExt(fn!), discordRPImageKeys.contains(fileExt) {
                p.assets.largeImage = fileExt
                p.assets.smallImage = discordRPImageKeyXcode
            } else {
                p.assets.largeImage = discordRPImageKeyDefault
            }
        } else {
            if let appName = an, xcodeWindowNames.contains(appName) {
                p.details = "Using \(appName)"
                p.assets.largeImage = appName.replacingOccurrences(of: "\\s", with: "", options: .regularExpression).lowercased()
                p.assets.smallImage = discordRPImageKeyXcode
            }
        }

        // determine workspace type
        if ws != nil {
            if an == "Xcode"{
                if ws != "Untitled" {
                    p.state = "in \(withoutFileExt(ws!))"
                    lastWindow = ws!
                }
            } else {
                p.state = "on \(withoutFileExt(lastWindow ?? "?" ))"
            }
        }

        // Xcode was just launched?
        if fn == nil && ws == nil {
            p.assets.largeImage = discordRPImageKeyXcode
            p.details = "No file open"
        }

        p.timestamps.start = startDate!
        p.timestamps.end = nil
        rpc!.setPresence(p)
//        print("updating RP")
    }

    func initRPC() {
        // init discord stuff
        rpc = SwordRPC.init(appId: discordClientId)
        rpc!.delegate = self
        rpc!.connect()
    }

    func deinitRPC() {
        self.rpc!.setPresence(RichPresence())
        self.rpc!.disconnect()
        self.rpc = nil
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        print("app launched")

        for app in NSWorkspace.shared.runningApplications {
            // check if xcode is running
            if app.bundleIdentifier == xcodeBundleId {
//                print("xcode running, connecting...")
                initRPC()
            }
        }

        let notifCenter = NSWorkspace.shared.notificationCenter

        // run on Xcode launch
        notifCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil, using: { notif in
            if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == xcodeBundleId {
//                    print("xcode launched, connecting...")
                    self.initRPC()
                }
            }
        })

        // run on Xcode close
        notifCenter.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: nil, using: { notif in
            if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == xcodeBundleId {
//                    print("xcode closed, disconnecting...")
                    self.deinitRPC()
                }
            }
        })


    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
//        print("app closing")
        deinitRPC()
        clearTimer()
    }


}

extension AppDelegate: SwordRPCDelegate {
    func swordRPCDidConnect(_ rpc: SwordRPC) {
//        print("connected")
        startDate = Date()
        beginTimer()
    }

    func swordRPCDidDisconnect(_ rpc: SwordRPC, code: Int?, message msg: String?) {
//        print("disconnected")
        clearTimer()
    }

    func swordRPCDidReceiveError(_ rpc: SwordRPC, code: Int, message msg: String) {
    
    }
}

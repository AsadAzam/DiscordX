//
//  AppDelegate.swift
//  DiscordX
//
//  Created by Asad Azam on 28/9/20.
//  Copyright © 2021 Asad Azam. All rights reserved.
//

import Cocoa
import SwordRPC
import SwiftUI

class AppViewModel: ObservableObject {
  @Published var showPopover = false
}

//@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var timer: Timer?
    var rpc: SwordRPC?
    var startDate: Date?
    var inactiveDate: Date?
    var lastWindow: String?
    var notifCenter = NSWorkspace.shared.notificationCenter
    
    var statusItem: NSStatusItem!
    
    var isRelaunch: Bool = false
    
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
        
//        print("Application Name: \(an ?? "")\nFile Name: \(fn ?? "")\nWorkspace: \(ws ?? "")\n")
        
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
                p.assets.smallImage = discordRPImageKeyXcode
                p.assets.largeImage = discordRPImageKeyDefault
                p.state = "Working on \(withoutFileExt((lastWindow ?? ws) ?? "?" ))"
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
        launchApplication()
        
        let contentView = VStack {
            VStack {
                Spacer()
                Button("Start DiscordX") {
                    if self.rpc == nil {
                        self.isRelaunch = true
                        self.launchApplication()
                    } else {
                        print("DiscordX is already running")
                    }
                }
                Spacer()
                Button("Stop DiscordX") {
                    if let rpc = self.rpc {
                        rpc.setPresence(RichPresence())
                        rpc.disconnect()
                        self.rpc = nil
                        self.clearTimer()
                    } else {
                        print("DiscordX is not running")
                    }
                }
                Spacer()
                Button("Quit DiscordX") {
                    exit(-1)
                }
                .padding(.top)
                .foregroundColor(.red)
                Spacer()
            }
        }
        
        let view = NSHostingView(rootView: contentView)

        view.frame = NSRect(x: 0, y: 0, width: 150, height: 130)
                
        let menuItem = NSMenuItem()
        menuItem.view = view
                
        let menu = NSMenu()
        menu.addItem(menuItem)
                
        // StatusItem is stored as a class property.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.menu = menu
        let image = NSImage(named: "AppIcon")
        image?.size = NSMakeSize(24.0, 24.0)
        statusItem.button!.image = image
        statusItem.isVisible = true
        
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
    }
    
    private lazy var addAllObservers: () = {
        // run on Xcode launch
        self.notifCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil, using: { notif in
            if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == xcodeBundleId {
//                    print("xcode launched, connecting...")
                    self.initRPC()
                }
            }
        })
        
        // run on Xcode close
        self.notifCenter.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: nil, using: { notif in
            if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == xcodeBundleId {
//                    print("xcode closed, disconnecting...")
                    self.deinitRPC()
                }
            }
        })
        
        if strictMode {
            self.notifCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: nil, using: { notif in
                if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                    if app.bundleIdentifier == xcodeBundleId {
                        //Xcode became active again (Frontmost)
                        if !self.isRelaunch {
                            if let inactiveDate = self.inactiveDate {
                                let newDate: Date? = self.startDate?.addingTimeInterval(-inactiveDate.timeIntervalSinceNow)
//                                print(self.startDate, newDate)
//                                print(self.startDate!.distance(to: newDate!))
                                self.startDate = newDate
                            }
                        } else {
                            self.startDate = Date()
                            self.inactiveDate = nil
                            self.isRelaunch = false
                        }
                        // User can now start or stop DiscordX have to check if rpc is connected
                        if self.rpc != nil {
                            self.updateStatus()
                        }
                    }
                }
            })
            
            self.notifCenter.addObserver(forName: NSWorkspace.didDeactivateApplicationNotification, object: nil, queue: nil, using: { notif in
                if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                    if app.bundleIdentifier == xcodeBundleId {
                        //Xcode is inactive (Not frontmost)
                        self.inactiveDate = Date()
                        if self.rpc != nil {
                            self.updateStatus()
                        }
                    }
                }
            })
        }
        
        if !flauntMode {
            self.notifCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil, using: { notif in
                if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                    if app.bundleIdentifier == xcodeBundleId {
                        //Xcode is going to become inactive (Sleep)
                        self.inactiveDate = Date()
                        if self.rpc != nil {
                            self.updateStatus()
                        }
                    }
                }
            })
            
            self.notifCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil, using: { notif in
                if let app = notif.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                    if app.bundleIdentifier == xcodeBundleId {
                        //Xcode woke up from sleep
                        if let inactiveDate = self.inactiveDate {
                            let newDate: Date? = self.startDate?.addingTimeInterval(-inactiveDate.timeIntervalSinceNow)
//                            print(self.startDate, newDate)
                            self.startDate = newDate
                        }
                        if self.rpc != nil {
                            self.updateStatus()
                        }
                    }
                }
            })
        }
    }()
    
    func launchApplication() {
//        print("app launched")
        
        for app in NSWorkspace.shared.runningApplications {
            // check if xcode is running
            if app.bundleIdentifier == xcodeBundleId {
//                print("xcode running, connecting...")
                initRPC()
            }
        }
        
        _ = addAllObservers
        
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

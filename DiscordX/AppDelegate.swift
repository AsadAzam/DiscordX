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

enum RefreshConfigurable: Int {
    case strict = 0
    case flaunt
    
    var message: String {
        switch self {
        case .strict:
            return "Timer will only keep the time you were active on Xcode"
        case .flaunt:
            return "Timer will not stop on Sleep and Wakeup of MacOS"
        }
    }
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
    
    var lastFileName: String?
    
    var smallImage = discordRPImageKeyXcode
    var largeImage = discordRPImageKeyDefault
    var upperText = "null"
    var lowerText = "null"
    
    
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
        
        p.assets.largeText = "By SkillCode"
        p.assets.smallText = "Xcode"
        
        if an != "Xcode" {
            return
        }
        

        
        if ws != nil {
            upperText = withoutFileExt(ws!)
        } 
        
        if fn != nil {
            lowerText = "Editing \(fn!)"
            
            if let fileExt = getFileExt(fn!), discordRPImageKeys.contains(fileExt) {
                largeImage = fileExt
            }
        }
        
        p.assets.smallImage = smallImage
        p.assets.largeImage = largeImage
        p.state = lowerText
        p.details = upperText
        
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
    
    struct ContentView: View {
        @State var refreshConfigurable: RefreshConfigurable
        var appDelegate: AppDelegate
        
        init(_ appDelegate: AppDelegate) {
            self.appDelegate = appDelegate
            if strictMode {
                refreshConfigurable = .strict
            } else if flauntMode {
                refreshConfigurable = .flaunt
            } else {
                fatalError("Unspecified refresh type")
            }
        }
        
        var body: some View {
            VStack {
                VStack {
                    Spacer()
                    Button("Start DiscordX") {
                        if self.appDelegate.rpc == nil {
                            self.appDelegate.isRelaunch = true
                            self.appDelegate.launchApplication()
                        } else {
                            print("DiscordX is already running")
                        }
                    }
                    Spacer()
                    Button("Stop DiscordX") {
                        if let rpc = self.appDelegate.rpc {
                            rpc.setPresence(RichPresence())
                            rpc.disconnect()
                            self.appDelegate.rpc = nil
                            self.appDelegate.clearTimer()
                        } else {
                            print("DiscordX is not running")
                        }
                    }
                    
                    Spacer()
                    Picker(selection: $refreshConfigurable, label: Text("Select Mode :")) {
                        Text("Strict").tag(RefreshConfigurable.strict)
                            .help(RefreshConfigurable.strict.message)
                        Text("Flaunt").tag(RefreshConfigurable.flaunt)
                            .help(RefreshConfigurable.flaunt.message)
                    }
                    .pickerStyle(RadioGroupPickerStyle())
                    
                    Spacer()
                    Button("Quit DiscordX") {
                        exit(-1)
                    }
                    .padding(.top)
                    .foregroundColor(.red)
                    Spacer()
                }
            }
            .onChange(of: refreshConfigurable) { newValue in
                switch newValue {
                case .strict:
                    strictMode = true
                    flauntMode = false
                case .flaunt:
                    strictMode = false
                    flauntMode = true
                }
            }
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        launchApplication()
        
        let contentView = ContentView(self)
        let view = NSHostingView(rootView: contentView)
        print("strictMode=\(strictMode) flauntMode=\(flauntMode)")
        
        view.frame = NSRect(x: 0, y: 0, width: 200, height: 160)
                
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

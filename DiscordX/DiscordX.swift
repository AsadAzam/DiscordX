//
//  DiscordX.swift
//  DiscordX
//
//  Created by Asad Azam on 22/03/22.
//  Copyright © 2022 Asad Azam. All rights reserved.
//

import SwiftUI

@main
struct DiscordX: App {
    let persistenceController = PersistenceController.shared

    init() {
        UserDefaults.standard.register(defaults: ["strictMode": true, "flauntMode": false])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

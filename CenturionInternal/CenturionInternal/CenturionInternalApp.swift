//
//  CenturionInternalApp.swift
//  CenturionInternal
//
//  Created by Collin Jensen on 12/3/24.
//

import SwiftUI

@main
struct CenturionInternalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

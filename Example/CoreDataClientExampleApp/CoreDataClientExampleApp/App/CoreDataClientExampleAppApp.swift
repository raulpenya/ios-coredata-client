//
//  CoreDataClientExampleAppApp.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 9/2/26.
//

import SwiftUI

/// Application entry point.
/// Declares the main SwiftUI scene and loads RootView as the initial UI container. It does not perform bootstrapping itself; it delegates that responsibility to the root view layer.

@main
struct CoreDataClientExampleAppApp: App {

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

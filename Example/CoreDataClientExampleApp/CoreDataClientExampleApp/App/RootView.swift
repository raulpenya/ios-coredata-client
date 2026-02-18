//
//  ContentView.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

import SwiftUI

/// Bootstrap and flow renderer.
/// Acts as the composition root for the UI.
/// Responsibilities:
/// - Asynchronously bootstraps the Core Data stack
/// - Instantiates AppFactory
/// - Instantiates FakeAuthController
/// - Creates and starts RootCoordinator
/// - Switches UI based on coordinator.root
/// - Hosts the NavigationStack for feature flows
/// It owns the async boundary of the app.

struct RootView: View {
    
    @State private var coordinator: RootCoordinator?
    
    var body: some View {
        Group {
            if let coordinator {
                switch coordinator.root {
                case .loading:
                    ProgressView()
                case .example:
                    NavigationStack {
                        ExampleView(
                            coordinator: coordinator.makeExampleCoordinator()
                        )
                    }
                case .login:
                    Text("Login")
                }
            } else {
                ProgressView()
            }
        }
        .task {
            await bootstrap()
        }
    }
    
    private func bootstrap() async {
        let dataSource = await AppFactory.makeCoreDataClient()
        do {
            try await dataSource.addDefaultPersons()
        } catch {
            print("addDefaultPersons :: error :: ", error)
        }
        let factory = AppFactory(dataSource: dataSource)
        let authController = FakeAuthController()
        let root = RootCoordinator(
            appFactory: factory,
            authController: authController
        )
        root.start()
        coordinator = root
    }
}

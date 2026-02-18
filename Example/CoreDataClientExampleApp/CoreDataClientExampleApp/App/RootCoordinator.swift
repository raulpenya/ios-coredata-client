//
//  RootCoordinator.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

import Foundation

/// Application flow controller.
/// Responsible for deciding which top-level flow the app should display (example, login, or loading).
///  Key responsibilities:
/// - Holds references to core dependencies (AppFactory, FakeAuthController)
/// - Derives the current root state from authController.authState
/// - Triggers authentication initialization via start()
/// - Creates feature coordinators (e.g., ExampleCoordinator)
/// It contains navigation decision logic, not UI.

@MainActor
@Observable
final class RootCoordinator {
    
    enum Root {
        case loading
        case example
        case login
    }
    
    var root: Root {
        switch authController.authState {
        case .loggedIn: return .example
        case .loggedOut: return .login
        case .tokenFailed: return .login
        }
    }
    
    private let appFactory: AppFactory
    private let authController: FakeAuthController
    
    init(
        appFactory: AppFactory,
        authController: FakeAuthController
    ) {
        self.appFactory = appFactory
        self.authController = authController
    }
    
    func start() {
        authController.start()
    }
    
    func makeExampleCoordinator() -> ExampleCoordinator {
        ExampleCoordinator(appFactory: appFactory)
    }
}

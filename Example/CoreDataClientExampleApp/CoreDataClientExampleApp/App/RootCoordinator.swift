//
//  RootCoordinator.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

import Foundation
import SwiftUI

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
    
    private let authController: FakeAuthController
    /// RootCoordinator owns child coordinators to stabilize feature lifecycles.
    let exampleCoordinator: ExampleCoordinator // why?
    
    init(
        appFactory: AppFactory,
        authController: FakeAuthController
    ) {
        self.authController = authController
        self.exampleCoordinator = ExampleCoordinator(appFactory: appFactory)
    }
    
    func start() {
        authController.start()
    }
    
    func makeExampleView() -> ExampleView {
        exampleCoordinator.makeExampleView()
    }
}

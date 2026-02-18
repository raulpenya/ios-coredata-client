//
//  AuthController.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

import Observation

enum AuthState {
    case loggedIn
    case loggedOut
    case tokenFailed
}

@MainActor
@Observable
final class FakeAuthController {

    private(set) var authState: AuthState = .loggedOut

    func start() {
        // Simulate boot resolution
        authState = .loggedIn
    }
}

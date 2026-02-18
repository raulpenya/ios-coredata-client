//
//  AppFactory.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

import SwiftUI
import CoreDataClient

/// Dependency container.
/// Provides shared application-level services (currently CoreDataDataSource).
/// Responsibilities:
/// - Stores shared dependencies
/// - Creates infrastructure objects (via extensions)
/// - Centralizes dependency wiring
/// It prevents direct coupling between features and infrastructure.

final class AppFactory {
    let dataSource: CoreDataDataSource
    
    init(dataSource: CoreDataDataSource) {
        self.dataSource = dataSource
    }
}

private struct AppFactoryKey: EnvironmentKey {
    static var defaultValue: AppFactory {
        fatalError("AppFactory not injected")
    }
}

extension EnvironmentValues {
    var factory: AppFactory {
        get { self[AppFactoryKey.self] }
        set { self[AppFactoryKey.self] = newValue }
    }
}

//
//  ExampleCoordinator.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

import Foundation

/// Feature coordinator.
/// Responsible for constructing objects needed by the Example feature.
/// Responsibilities:
/// - Holds reference to AppFactory
/// - Creates ExampleViewModel
/// - Encapsulates feature-level dependency injection
/// It does not manage root navigation—only feature composition.

@MainActor
@Observable
final class ExampleCoordinator {

    private let appFactory: AppFactory

    init(appFactory: AppFactory) {
        self.appFactory = appFactory
    }

    func makeViewModel() -> ExampleViewModel {
        ExampleViewModel(dataSource: appFactory.dataSource)
    }
}

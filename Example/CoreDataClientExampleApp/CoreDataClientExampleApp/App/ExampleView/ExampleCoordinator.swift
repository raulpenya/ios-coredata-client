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
/// If the feature has its own navigation graph, it gets a coordinator.

@MainActor
@Observable
final class ExampleCoordinator {
    
    enum Route: Hashable {
        case addPerson
    }
    
    var path: [Route] = []
    
    private let repository: PersonRepository
    /// Coordinators own ViewModels for root feature screens.
    private let viewModel: ExampleViewModel
    
    init(appFactory: AppFactory) {
        let repository = PersonDataRepository(
            dataSource: appFactory.dataSource
        )
        self.repository = repository
        self.viewModel = ExampleViewModel(
            repository: repository
        )
    }
    
    func makeExampleView() -> ExampleView {
        ExampleView(
            viewModel: viewModel, coordinator: self
        )
    }
    
    func makeAddPersonView() -> AddPersonView {
        AddPersonView(
            viewModel: AddPersonViewModel(
                addPerson: AddPerson(personRepository: repository)
            )
        )
    }
    
    func goToAddPerson() {
        path.append(.addPerson)
    }
}

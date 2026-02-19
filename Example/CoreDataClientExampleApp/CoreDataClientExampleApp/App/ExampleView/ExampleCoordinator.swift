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
    
    enum Route: Hashable {
        case addPerson
    }
    
    var path: [Route] = []
    
    private let appFactory: AppFactory
    
    init(appFactory: AppFactory) {
        self.appFactory = appFactory
    }
    
    func goToAddPerson() {
        path.append(.addPerson)
    }
    
    func makeViewModel() -> ExampleViewModel {
        let repository = PersonDataRepository(
            dataSource: appFactory.dataSource
        )
        
        let addPerson = AddPerson(personRepository: repository)
        let getAllPersons = GetAllPersons(personRepository: repository)
        let removePerson = RemovePerson(personRepository: repository)
        let removePersons = RemovePersons(personRepository: repository)
        
        return ExampleViewModel(
            addPerson: addPerson,
            getAllPersons: getAllPersons,
            removePerson: removePerson,
            removePersons: removePersons
        )
    }
    
    func makeAddPersonView() -> AddPersonView {
        AddPersonView(coordinator: self)
    }
}

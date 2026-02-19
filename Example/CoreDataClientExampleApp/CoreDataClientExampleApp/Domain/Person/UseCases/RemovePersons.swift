//
//  RemovePersonsUseCase.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

class RemovePersons: UseCase {
    typealias T = Void
    typealias Q = RemovePersonsRequestValues
    let personRepository: PersonRepository
    
    init(personRepository: PersonRepository) {
        self.personRepository = personRepository
    }
    
    func execute(_ requestValues: RemovePersonsRequestValues) async throws {
        try await personRepository.remove(emails: requestValues.emails)
    }
}

class RemovePersonsRequestValues: RequestValues {
    let emails: [String]
    
    init(emails: [String]) {
        self.emails = emails
    }
}

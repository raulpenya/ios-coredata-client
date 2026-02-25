//
//  RemovePersonUseCase.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

class RemovePerson: UseCase {
    typealias T = Void
    typealias Q = RemovePersonRequestValues
    let personRepository: PersonRepository
    
    init(personRepository: PersonRepository) {
        self.personRepository = personRepository
    }
    
    func execute(_ requestValues: RemovePersonRequestValues) async throws {
        try await personRepository.remove(byEmail: requestValues.email)
    }
}

class RemovePersonRequestValues: RequestValues {
    let email: String
    
    init(email: String) {
        self.email = email
    }
}

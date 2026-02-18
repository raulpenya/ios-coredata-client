//
//  GetPersonByEmailUseCase.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

class GetPersonByEmail: UseCase {
    typealias T = Person?
    typealias Q = GetPersonByEmailRequestValues
    let personRepository: PersonRepository
    
    init(personRepository: PersonRepository) {
        self.personRepository = personRepository
    }
    
    func execute(_ requestValues: GetPersonByEmailRequestValues) async throws -> Person? {
        try await personRepository.getPerson(requestValues)
    }
}

class GetPersonByEmailRequestValues: RequestValues {
    let email: String
    
    init(email: String) {
        self.email = email
    }
}

//
//  GetAllPersonsUseCase.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

class GetAllPersons: UseCase {
    typealias T = [Person]
    typealias Q = GetAllPersonsRequestValues
    let personRepository: PersonRepository
    
    init(personRepository: PersonRepository) {
        self.personRepository = personRepository
    }
    
    func execute(_ request: GetAllPersonsRequestValues) async throws -> [Person] {
        try await personRepository.getAll()
    }
}

class GetAllPersonsRequestValues: RequestValues {}

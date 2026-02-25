//
//  AddPersonUseCase.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

class AddPerson: UseCase {
    typealias T = Person
    typealias Q = AddPersonRequestValues
    let personRepository: PersonRepository
    
    init(personRepository: PersonRepository) {
        self.personRepository = personRepository
    }
    
    func execute(_ requestValues: AddPersonRequestValues) async throws -> Person {
        return try await personRepository.add(person: requestValues.person)
    }
}

class AddPersonRequestValues: RequestValues {
    let person: Person
    
    init(person: Person) {
        self.person = person
    }
}

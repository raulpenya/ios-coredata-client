//
//  PersonDataRepository.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

import CoreData
import CoreDataClient

class PersonDataRepository: PersonRepository {
    private let dataSource: CoreDataDataSource
    
    init(dataSource: CoreDataDataSource) {
        self.dataSource = dataSource
    }
    
    func addPerson(_ requestValues: AddPersonRequestValues) async throws -> Person {
        let person = requestValues.person
        let request = InsertRequest<Person> { context in
            try person.insert(into: context)
        }
        return try await dataSource.performBackground(request)
    }
    
    func getAllPersons(_ requestValues: GetAllPersonsRequestValues) async throws -> [Person] {
        let request = FetchRequest<PersonLocalEntity, [Person]>(
            request: PersonLocalEntity.fetchRequest()
        ) { result in
            try result.map { try $0.transformToDomain() }
        }
        return try await dataSource.performBackground(request)
    }
    
    func getPerson(_ requestValues: GetPersonByEmailRequestValues) async throws -> Person? {
        let email = requestValues.email
        let request = FetchRequest<PersonLocalEntity, Person?>(request: PersonLocalEntity.fetchRequest(with: email)) { result in
            try result.compactMap { try $0.transformToDomain() }.first ?? nil
        }
        return try await dataSource.performBackground(request)
    }
    
    func removePerson(_ requestValues: RemovePersonRequestValues) async throws {
        <#code#>
    }
    
    func removePersons(_ requestValues: RemovePersonsRequestValues) async throws {
        let emails = requestValues.emails
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonLocalEntity")
        fetchRequest.predicate = NSPredicate(format: "email IN %@", emails)
        let request = BatchDeleteRequest(request: fetchRequest)
        return try await dataSource.performBackground(request)
    }
}

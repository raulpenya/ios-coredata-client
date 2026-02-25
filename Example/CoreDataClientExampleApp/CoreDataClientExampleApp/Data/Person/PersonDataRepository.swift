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
    
    private var continuation: AsyncStream<[Person]>.Continuation?
    private(set) lazy var personsStream: AsyncStream<[Person]> = {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }()
    
    init(dataSource: CoreDataDataSource) {
        self.dataSource = dataSource
    }
    
    private func publishPersons() async {
        do {
            let persons = try await getAll()
            continuation?.yield(persons)
        } catch {
            continuation?.yield([])
        }
    }
    
    func add(person: Person) async throws -> Person {
        let request = InsertRequest<Person> { context in
            try person.insert(into: context)
        }
        let result = try await dataSource.performBackground(request)
        await publishPersons()
        return result
    }
    
    func getAll() async throws -> [Person] {
        let request = FetchRequest<PersonLocalEntity, [Person]>(
            request: PersonLocalEntity.fetchRequest()
        ) { result in
            try result.map { try $0.transformToDomain() }
        }
        return try await dataSource.performBackground(request)
    }
    
    func get(byEmail email: String) async throws -> Person? {
        let request = FetchRequest<PersonLocalEntity, Person?>(request: PersonLocalEntity.fetchRequest(with: email)) { result in
            try result.compactMap { try $0.transformToDomain() }.first ?? nil
        }
        return try await dataSource.performBackground(request)
    }
    
    func remove(byEmail email: String) async throws {
        let request = DeletePersonByEmailRequest(email: email)
        try await dataSource.performBackground(request)
        await publishPersons()
    }
    
    func remove(emails: [String]) async throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonLocalEntity")
        fetchRequest.predicate = NSPredicate(format: "email IN %@", emails)
        let request = BatchDeleteRequest(request: fetchRequest)
        try await dataSource.performBackground(request)
        await publishPersons()
    }
}

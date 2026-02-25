//
//  PersonRepository.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

/// In strict Clean Architecture:
/// - UseCases depend on repositories
/// - Repositories should not depend on use case request objects

protocol PersonRepository {
    var personsStream: AsyncStream<[Person]> { get }
    
    func add(person: Person) async throws -> Person
    func getAll() async throws -> [Person]
    func get(byEmail email: String) async throws -> Person?
    func remove(byEmail email: String) async throws
    func remove(emails: [String]) async throws
}

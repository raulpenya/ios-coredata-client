//
//  Untitled.swift
//  CoreDataClient
//
//  Created by Raul Peña on 13/2/26.
//

import XCTest
@testable import CoreDataClient

final class BatchDeleteRequestTests: XCTestCase {

    func test_deleterequest_success() async throws {
        // Given
        let mock = MockPersistentStore(sqlite: true) // NSBatchDeleteRequest is only supported by NSSQLiteStoreType
        _ = mock.insertPersons(persons: Person.persons)
        let datasource = CoreDataDataSource(persistentStore: mock)
        let emails = Person.persons.compactMap { $0.email }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonLocalEntity")
        fetchRequest.predicate = NSPredicate(format: "email IN %@", emails)
        let request = BatchDeleteRequest(request: fetchRequest)
        
        // When
        try await datasource.performBackground(request)
        
        // Then
        let verifyRequest = FetchRequest<PersonLocalEntity, [Person]>(request: PersonLocalEntity.fetchRequest(with: emails)) { result in
            try result.compactMap { try $0.transformToDomain() }
        }
        let result = try await datasource.performBackground(verifyRequest)
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_deleterequest_partialdelete() async throws {
        // Given
        let mock = MockPersistentStore(sqlite: true) // NSBatchDeleteRequest is only supported by NSSQLiteStoreType
        let existingPersons = Array(Person.persons.prefix(2))
        _ = mock.insertPersons(persons: existingPersons)
        let datasource = CoreDataDataSource(persistentStore: mock)
        let emailsToDelete = Person.persons.prefix(4).map { $0.email }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonLocalEntity")
        fetchRequest.predicate = NSPredicate(format: "email IN %@", emailsToDelete)
        let deleteRequest = BatchDeleteRequest(request: fetchRequest)
        
        // When
        try await datasource.performBackground(deleteRequest)
        
        // Then
        // Verify that the originally inserted 2 are deleted
        let verifyDeleted = FetchRequest<PersonLocalEntity, [Person]>(
            request: PersonLocalEntity.fetchRequest(with: existingPersons.map { $0.email })
        ) { result in
            try result.map { try $0.transformToDomain() }
        }
        let deletedResult = try await datasource.performBackground(verifyDeleted)
        XCTAssertTrue(deletedResult.isEmpty)
        
        // Verify store is empty (since only 2 were inserted)
        let verifyAll = FetchRequest<PersonLocalEntity, [Person]>(
            request: PersonLocalEntity.fetchRequest()
        ) { result in
            try result.map { try $0.transformToDomain() }
        }
        let remaining = try await datasource.performBackground(verifyAll)
        XCTAssertTrue(remaining.isEmpty)
    }
}

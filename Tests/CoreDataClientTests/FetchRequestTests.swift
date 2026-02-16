//
//  FetchRequestTests.swift
//  CoreDataClient
//
//  Created by Raul Peña on 13/2/26.
//

import XCTest
@testable import CoreDataClient

final class FetchRequestTests: XCTestCase {

    func test_fetchrequest_success() async throws {
        // Given
        let mock = MockPersistentStore()
        let person = Person.persons.first!
        mock.insertPerson(person: person)
        let datasource = CoreDataDataSource(persistentStore: mock)
        let request = FetchRequest<PersonLocalEntity, Person?>(request: PersonLocalEntity.fetchRequest(with: person.email)) { result in
            try result.compactMap { try $0.transformToDomain() }.first ?? nil
        }
        
        // When
        let result = try await datasource.performBackground(request)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.email, person.email)
    }
    
    func test_fetchrequest_empty() async throws {
        // Given
        let mock = MockPersistentStore()
        let datasource = CoreDataDataSource(persistentStore: mock)
        let email = Person.persons.first!.email
        let request = FetchRequest<PersonLocalEntity, Person?>(request: PersonLocalEntity.fetchRequest(with: email)) { result in
            try result.compactMap { try $0.transformToDomain() }.first ?? nil
        }
        
        // When
        let result = try await datasource.performBackground(request)
        
        // Then
        XCTAssertNil(result)
    }
    
    func test_fetchrequest_transform_error() async throws {
        // Given
        let mock = MockPersistentStore()
        let person = Person.persons.first!
        mock.insertPersonWithNilName(person: person)
        let datasource = CoreDataDataSource(persistentStore: mock)
        let request = FetchRequest<PersonLocalEntity, Person?>(request: PersonLocalEntity.fetchRequest(with: person.email)) { result in
            try result.compactMap { try $0.transformToDomain() }.first ?? nil
        }
        
        // When
        await XCTAssertThrowsErrorAsync {
            _ = try await datasource.performBackground(request)
        }
    }
    
    func XCTAssertThrowsErrorAsync(
        _ expression: @escaping () async throws -> Void
    ) async {
        do {
            try await expression()
            XCTFail("Expected error")
        } catch {
            // success
        }
    }
}

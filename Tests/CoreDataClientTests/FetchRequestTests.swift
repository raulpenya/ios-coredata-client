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
        // POPULATE
        let datasource = CoreDataDataSource(persistentStore: mock)
        let email = Person.persons.first!.email
        let request = FetchRequest<PersonLocalEntity, Person?>(request: PersonLocalEntity.fetchRequest(with: email)) { result in
            try result.compactMap { try $0.transformToDomain() }.first ?? nil
        }
        
        // When
        let result = try await datasource.performBackground(request)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.email, email)
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
        // POPULATE wrong
        let datasource = CoreDataDataSource(persistentStore: mock)
        let email = Person.persons.first!.email
        let request = FetchRequest<PersonLocalEntity, Person?>(request: PersonLocalEntity.fetchRequest(with: email)) { result in
            try result.compactMap { try $0.transformToDomain() }.first ?? nil
        }
        
        // When
        do {
            _ = try await datasource.performBackground(request)
            XCTFail("Expected error")
        } catch {
            // Then
            XCTAssertNotNil(error)
            // "Person already exists"
        }
    }
}

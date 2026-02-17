//
//  InsertRequestTests.swift
//  CoreDataClient
//
//  Created by Raul Peña on 13/2/26.
//

import XCTest
@testable import CoreDataClient

final class InsertRequestTests: XCTestCase {

    func test_insertrequest_success() async throws {
        // Given
        let mock = MockPersistentStore()
        let datasource = CoreDataDataSource(persistentStore: mock)
        let person = Person.persons.first!
        let request = InsertRequest<Person> { context in
            try person.insert(into: context)
        }
        
        // When
        let result = try await datasource.performBackground(request)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, person)
    }
    
    func test_insertrequest_exists_error() async throws {
        // Given
        let mock = MockPersistentStore()
        let person = Person.persons.first!
        _ = mock.insertPerson(person: person)
        let datasource = CoreDataDataSource(persistentStore: mock)
        let request = InsertRequest<Person> { context in
            try person.insert(into: context)
        }
        
        // When
        do {
            _ = try await datasource.performBackground(request)
            XCTFail("Expected error")
        } catch CoreDataError.insertFailed {
            // Then
//            XCTAssertNotNil(error)
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}

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
        let mock = MockPersistentStore()
        // POPULATE
        let datasource = CoreDataDataSource(persistentStore: mock)
        let emails = Person.persons.compactMap { $0.email }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonLocalEntity")
        fetchRequest.predicate = NSPredicate(format: "email IN %@", emails)
        let request = BatchDeleteRequest(request: fetchRequest)
        
        // When
        try await datasource.performBackground(request)
        
        // Then
        // what to check ??
//        XCTAssertNotNil(result)
//        XCTAssertEqual(result!.email, email)
    }
    
    func test_deleterequest_notfound() async throws {
//        // Given
//        let mock = MockPersistentStore()
//        let datasource = CoreDataDataSource(persistentStore: mock)
//        let email = Person.persons.first!.email
//        let request = FetchRequest<PersonLocalEntity, Person?>(request: PersonLocalEntity.fetchRequest(with: email)) { result in
//            try result.compactMap { try $0.transformToDomain() }.first ?? nil
//        }
//
//        // When
//        let result = try await datasource.performBackground(request)
//
//        // Then
//        XCTAssertNil(result)
    }
}

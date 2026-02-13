//
//  Untitled.swift
//  CoreDataClient
//
//  Created by Raul Peña on 13/2/26.
//

import XCTest
@testable import CoreDataClient

final class DeleteRequestTests: XCTestCase {

    func test_deleterequest_success() async throws {
        // Given
        let mock = MockPersistentStore()
        // POPULATE
        let datasource = CoreDataDataSource(persistentStore: mock)
        let email = Person.persons.first!.email
        
        // fetch object without transform it, just for getting the NSManagedObjectID
        
        let requestObjectID = FetchRequest<PersonLocalEntity, NSManagedObjectID>(request: PersonLocalEntity.fetchRequest(with: email)) { result in
            result.first!.objectID
        }
        let result = try await datasource.performBackground(requestObjectID)
        let deleteRequest = DeleteRequest(objectID: result)
        
        // When
        try await datasource.performBackground(deleteRequest)
        
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

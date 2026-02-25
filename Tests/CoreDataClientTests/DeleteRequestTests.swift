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
        let person = Person.persons.first!
        let objectID = mock.insertPersonForObjectID(person: person)
        let datasource = CoreDataDataSource(persistentStore: mock)
        let request = DeleteRequest(objectID: objectID)
        
        // When
        try await datasource.performBackground(request)
        
        // Then
        let verifyRequest = FetchRequest<PersonLocalEntity, Person?>(request: PersonLocalEntity.fetchRequest(with: person.email)) { result in
            try result.compactMap { try $0.transformToDomain() }.first ?? nil
        }
        let result = try await datasource.performBackground(verifyRequest)
        XCTAssertNil(result)
    }
}

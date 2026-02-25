//
//  MockPerson.swift
//  CoreDataClient
//
//  Created by Raul Peña on 13/2/26.
//

import CoreData

final class PersonLocalEntity: NSManagedObject { }

extension PersonLocalEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonLocalEntity> {
        return NSFetchRequest<PersonLocalEntity>(entityName: "PersonLocalEntity")
    }
    
    @nonobjc public class func fetchRequest(with email: String) -> NSFetchRequest<PersonLocalEntity> {
        let fetchRequest: NSFetchRequest<PersonLocalEntity> = PersonLocalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        return fetchRequest
    }
    
    @nonobjc public class func fetchRequest(with emails: [String]) -> NSFetchRequest<PersonLocalEntity> {
        let fetchRequest: NSFetchRequest<PersonLocalEntity> = PersonLocalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email IN %@", emails)
        return fetchRequest
    }

    @NSManaged public var name: String?
    @NSManaged public var email: String?
}

extension PersonLocalEntity {
    func transformToDomain() throws -> Person {
        guard let name, let email else {
            throw NSError(domain: "PersonLocalEntity.transformToDomain error", code: 0, userInfo: nil)
        }
        return Person(name: name, email: email)
    }
}

extension Person {
    func insert(into context: NSManagedObjectContext) throws -> Person {
        let fetchRequest: NSFetchRequest<PersonLocalEntity> = PersonLocalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        let result = try context.fetch(fetchRequest)
        if result.isEmpty {
            let entity = PersonLocalEntity(context: context)
            entity.name = name
            entity.email = email
            return try entity.transformToDomain()
        } else {
            throw NSError(domain: "Person already exists error", code: 0, userInfo: nil)
        }
    }
}

struct Person: Equatable {
    let name: String
    let email: String
}

extension Person {
    static let persons: [Person] = [
        Person(name: "Shyam", email: "shyamjaiswal@gmail.com"),
        Person(name: "Bob", email: "bob32@gmail.com"),
        Person(name: "Jai", email: "jai87@gmail.com")
    ]
}

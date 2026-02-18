//
//  PersonLocalEntity.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

import CoreData

extension PersonLocalEntity {
    static func fetchRequest(with email: String) -> NSFetchRequest<PersonLocalEntity> {
        let request = PersonLocalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        return request
    }
    
    static func fetchRequest(with emails: [String]) -> NSFetchRequest<PersonLocalEntity> {
        let request = PersonLocalEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email IN %@", emails)
        return request
    }
    
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

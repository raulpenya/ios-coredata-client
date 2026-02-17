//
//  MockPersistentStore.swift
//  CoreDataClient
//
//  Created by Raul Peña on 13/2/26.
//

import CoreDataClient
import CoreData

final class MockPersistentStore: PersistentStoreProtocol {
    let container: NSPersistentContainer
    
    init(sqlite: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(
            name: "TestModel",
            managedObjectModel: model
        )
        let description = NSPersistentStoreDescription()
        description.type = sqlite ? NSSQLiteStoreType : NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
    
    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let entity = NSEntityDescription()
        entity.name = "PersonLocalEntity"
        entity.managedObjectClassName = NSStringFromClass(PersonLocalEntity.self)
        
        let name = NSAttributeDescription()
        name.name = "name"
        name.attributeType = .stringAttributeType
        name.isOptional = true
        
        let email = NSAttributeDescription()
        email.name = "email"
        email.attributeType = .stringAttributeType
        email.isOptional = true
        
        entity.properties = [name, email]
        model.entities = [entity]
        
        return model
    }
    
    func insertPerson(person: Person) -> Person {
        let context = container.viewContext
        let result = try! Person.persons.first!.insert(into: context)
        try! context.save()
        return result
    }
    
    func insertPersonForObjectID(person: Person) -> NSManagedObjectID {
        let context = container.viewContext
        let entity = PersonLocalEntity(context: context)
        entity.name = nil
        entity.email = person.email
        try! context.save()
        return entity.objectID
    }
    
    func insertPersons(persons: [Person]) -> [Person] {
        let context = container.viewContext
        let result = persons.compactMap {
            try! $0.insert(into: context)
        }
        try! context.save()
        return result
    }
    
    func insertPersonWithNilName(person: Person) {
        let context = container.viewContext
        let entity = PersonLocalEntity(context: context)
        entity.name = nil
        entity.email = person.email
        try! context.save()
    }
}

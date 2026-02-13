//
//  MockPersistentStore.swift
//  CoreDataClient
//
//  Created by Raul Peña on 13/2/26.
//

import CoreDataClient
import CoreData

final class MockPersistentStore: PersistentStoreProtocol {
    var container: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        let container = NSPersistentContainer(name: "your_model_name")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}

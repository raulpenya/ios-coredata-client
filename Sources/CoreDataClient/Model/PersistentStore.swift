//
//  PersistentStore.swift
//  CoreDataClient
//
//  Created by Raul Peña on 11/2/26.
//

import CoreData

public protocol PersistentStoreProtocol {
    var container: NSPersistentContainer { get }
}

public final class PersistentStore: PersistentStoreProtocol {

    public let container: NSPersistentContainer

    public init(configuration: CoreDataConfiguration) async throws {
        
        let container = NSPersistentContainer(
            name: configuration.modelName,
            managedObjectModel: configuration.managedObjectModel
        )
        
        container.persistentStoreDescriptions = [
            configuration.storeDescription
        ]
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.loadPersistentStores { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
        
        self.container = container
        configureContexts()
    }

    private func configureContexts() {
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(
            merge: .mergeByPropertyObjectTrumpMergePolicyType
        )
    }
}

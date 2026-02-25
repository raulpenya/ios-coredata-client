//
//  AppFactory+CoreData.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

import CoreData
import CoreDataClient

/// Dependency container.
/// Provides shared application-level services (currently CoreDataDataSource).
/// Responsibilities:
/// - Stores shared dependencies
/// - Creates infrastructure objects (via extensions)
/// - Centralizes dependency wiring
/// It prevents direct coupling between features and infrastructure.

extension AppFactory {
    static func makeCoreDataClient() async -> CoreDataDataSource {
        guard let modelURL = Bundle.main.url(
            forResource: "ExampleAppModel",
            withExtension: "momd"
        ),
              let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("Failed to load Core Data model")
        }
        
        let storeURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("ExampleAppModel.sqlite")
        
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSSQLiteStoreType
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        
        let configuration = CoreDataConfiguration(
            modelName: "ExampleAppModel",
            managedObjectModel: model,
            storeDescription: description
        )
        
        do {
            let persistentStore = try await PersistentStore(configuration: configuration)
            return CoreDataDataSource(persistentStore: persistentStore)
        } catch {
            fatalError("Failed to initialize Core Data stack: \(error)")
        }
    }
}

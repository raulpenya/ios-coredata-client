//
//  CoreDataConfiguration.swift
//  CoreDataClient
//
//  Created by Raul Peña on 11/2/26.
//

import CoreData

public struct CoreDataConfiguration {

    public let modelName: String
    public let managedObjectModel: NSManagedObjectModel
    public let storeDescription: NSPersistentStoreDescription

    public init(
        modelName: String,
        managedObjectModel: NSManagedObjectModel,
        storeDescription: NSPersistentStoreDescription
    ) {
        self.modelName = modelName
        self.managedObjectModel = managedObjectModel
        self.storeDescription = storeDescription
    }
}

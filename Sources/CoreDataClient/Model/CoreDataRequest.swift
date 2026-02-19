//
//  CoreDataRequest.swift
//  CoreDataClient
//
//  Created by Raul Peña on 11/2/26.
//

import CoreData

public protocol CoreDataRequestProtocol: Sendable {
    associatedtype Response
    func execute(in context: NSManagedObjectContext) throws -> Response
    func mapError(_ error: Error) -> CoreDataError
}

/// FetchRequest takes both an NSFetchRequest and a transform because it cleanly separates persistence-level query specification (what to fetch and how Core Data executes it) from mapping logic (how raw NSManagedObject instances are projected into the caller’s desired return type), preserving query reusability and keeping data transformation outside the persistence infrastructure.
public struct FetchRequest<T: NSManagedObject, Q>: CoreDataRequestProtocol, @unchecked Sendable {
    public let request: NSFetchRequest<T>
    public let transform: ([T]) throws -> Q
    
    public init(request: NSFetchRequest<T>, transform: @escaping ([T]) throws -> Q) {
        self.request = request
        self.transform = transform
    }

    public func execute(in context: NSManagedObjectContext) throws -> Q {
        let objects = try context.fetch(request)
        return try transform(objects)
    }
    
    public func mapError(_ error: Error) -> CoreDataError {
        .fetchFailed(error)
    }
}

/// InsertRequest takes only an insert closure because insertion logic is inherently context-bound and entity-specific, so the most flexible and type-safe abstraction is to let the caller define the exact mutation against the provided NSManagedObjectContext, while the request itself remains responsible only for transaction management (save semantics).
/// InsertRequest uses a closure because mutations are inherently imperative and workflow-driven, whereas FetchRequest preserves a declarative NSFetchRequest to maintain query composability, inspectability, and strict separation between read and write semantics.
public struct InsertRequest<Q>: CoreDataRequestProtocol, @unchecked Sendable {

    public let insert: (NSManagedObjectContext) throws -> Q
    
    public init(insert: @escaping (NSManagedObjectContext) throws -> Q) {
        self.insert = insert
    }

    public func execute(in context: NSManagedObjectContext) throws -> Q {
        let result = try insert(context)
        if context.hasChanges {
            try context.save()
        }
        return result
    }
    
    public func mapError(_ error: Error) -> CoreDataError {
        .insertFailed(error)
    }
}

/// DeleteRequest takes only an NSManagedObjectID because deletion is an identity-based command, and NSManagedObjectID is the only thread-safe, context-independent, stable reference that uniquely identifies a Core Data object across contexts.
public struct DeleteRequest: CoreDataRequestProtocol, @unchecked Sendable {
    
    public typealias Response = Void
    public let objectID: NSManagedObjectID
    
    public init(objectID: NSManagedObjectID) {
        self.objectID = objectID
    }
    
    public func execute(in context: NSManagedObjectContext) throws {
        let object = try context.existingObject(with: objectID)
        context.delete(object)
        try context.save()
    }
    
    public func mapError(_ error: Error) -> CoreDataError {
        .deleteFailed(error)
    }
}

public struct BatchDeleteRequest: CoreDataRequestProtocol, @unchecked Sendable {
    
    public typealias Response = Void
    public let request: NSFetchRequest<NSFetchRequestResult>
    
    public init(request: NSFetchRequest<NSFetchRequestResult>) {
        self.request = request
    }

    public func execute(in context: NSManagedObjectContext) throws {
        guard
            let store = context.persistentStoreCoordinator?
                .persistentStores
                .first,
            store.type == NSSQLiteStoreType
        else {
            // Fallback for non-SQLite stores (e.g. in-memory)
            guard let fetchRequest = request as? NSFetchRequest<NSManagedObject> else {
                throw CoreDataError.batchDeleteFailed(
                    NSError(
                        domain: "BatchDeleteRequest",
                        code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Invalid fetch request type for fallback delete."
                        ]
                    )
                )
            }
            
            let objects = try context.fetch(fetchRequest)
            objects.forEach { context.delete($0) }
            
            if context.hasChanges {
                try context.save()
            }
            
            return
        }
        
        // SQLite optimized batch delete
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        guard let result = try context.execute(deleteRequest) as? NSBatchDeleteResult else {
            throw CoreDataError.batchDeleteFailed(
                NSError(
                    domain: "BatchDeleteRequest",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Failed to execute NSBatchDeleteRequest."
                    ]
                )
            )
        }
        
        if let objectIDs = result.result as? [NSManagedObjectID] {
            let changes: [AnyHashable: Any] = [
                NSDeletedObjectsKey: objectIDs
            ]
            
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [context]
            )
        }
    }
    
    public func mapError(_ error: Error) -> CoreDataError {
        .batchDeleteFailed(error)
    }
}

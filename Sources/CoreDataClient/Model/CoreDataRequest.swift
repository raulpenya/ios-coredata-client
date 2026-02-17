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
    let request: NSFetchRequest<T>
    let transform: ([T]) throws -> Q

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

    let insert: (NSManagedObjectContext) throws -> Q

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
    
    let objectID: NSManagedObjectID
    
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

    let request: NSFetchRequest<NSFetchRequestResult>

    public func execute(in context: NSManagedObjectContext) throws {
        guard
            context.persistentStoreCoordinator?
                .persistentStores
                .first?
                .type == NSSQLiteStoreType
        else {
            // Fallback delete
            let objects = try context.fetch(request as! NSFetchRequest<NSManagedObject>)
            objects.forEach { context.delete($0) }
            try context.save()
            return
        }
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        
        if let objectIDs = result?.result as? [NSManagedObjectID] {
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

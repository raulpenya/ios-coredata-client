//
//  CoreDataRequest.swift
//  CoreDataClient
//
//  Created by Raul Peña on 11/2/26.
//

import CoreData

public protocol CoreDataRequestProtocol {
    associatedtype Response
    func execute(in context: NSManagedObjectContext) throws -> Response
}

public struct FetchRequest<R>: CoreDataRequestProtocol {
    let request: NSFetchRequest<NSManagedObject>
    let transform: ([NSManagedObject]) throws -> R

    public func execute(in context: NSManagedObjectContext) throws -> R {
        let objects = try context.fetch(request)
        return try transform(objects)
    }
}

public struct InsertRequest<R>: CoreDataRequestProtocol {

    let work: (NSManagedObjectContext) throws -> R

    public func execute(in context: NSManagedObjectContext) throws -> R {
        let result = try work(context)
        if context.hasChanges {
            try context.save()
        }
        return result
    }
}

public struct DeleteRequest: CoreDataRequestProtocol {
    public typealias Response = Void
    
    let objectID: NSManagedObjectID
    
    public func execute(in context: NSManagedObjectContext) throws {
        let object = try context.existingObject(with: objectID)
        context.delete(object)
        try context.save()
    }
}

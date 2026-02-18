//
//  PersistentStore.swift
//  CoreDataClient
//
//  Created by Raul Peña on 11/2/26.
//

import CoreData

public protocol CoreDataProtocol {
    func perform<Request: CoreDataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response
    
    func performBackground<Request: CoreDataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response
}

public final class CoreDataDataSource: CoreDataProtocol {
    public let persistentStore: PersistentStoreProtocol
    
    public init(persistentStore: PersistentStoreProtocol) {
        self.persistentStore = persistentStore
    }
    
    public func perform<Request: CoreDataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response {
        let context = persistentStore.container.viewContext
        do {
            return try await context.perform {
                try request.execute(in: context)
            }
        } catch {
            throw request.mapError(error)
        }
    }
    
    public func performBackground<Request: CoreDataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response {
        let container = persistentStore.container
        return try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                do {
                    let result = try request.execute(in: context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(
                        throwing: request.mapError(error)
                    )
                }
            }
        }
    }
}

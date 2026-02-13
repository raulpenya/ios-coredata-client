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
    private let persistentStore: PersistentStoreProtocol
    
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
            throw mapError(error, for: request)
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
                        throwing: self.mapError(error, for: request)
                    )
                }
            }
        }
    }
}

extension CoreDataDataSource {
    private func mapError<Request: CoreDataRequestProtocol>(
        _ error: Error,
        for request: Request
    ) -> CoreDataError {
        
        switch request {
        case is FetchRequest<Request.Response>:
            return .fetchFailed(error)
        case is InsertRequest<Request.Response>:
            return .insertFailed(error)
        case is DeleteRequest:
            return .deleteFailed(error)
        default:
            return .unknown(error)
        }
    }
}

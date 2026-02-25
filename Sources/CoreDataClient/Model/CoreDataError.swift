//
//  CoreDataClientError.swift
//  CoreDataClient
//
//  Created by Raul Peña on 11/2/26.
//

public enum CoreDataError: Error, Equatable {
    case fetchFailed(Error)
    case insertFailed(Error)
    case deleteFailed(Error)
    case batchDeleteFailed(Error)
    case unknown(Error)
    
    public static func == (lhs: CoreDataError, rhs: CoreDataError) -> Bool {
        switch (lhs, rhs) {
        case (.fetchFailed, .fetchFailed),
            (.insertFailed, .insertFailed),
            (.deleteFailed, .deleteFailed),
            (.batchDeleteFailed, .batchDeleteFailed),
            (.unknown, .unknown):
            return true
            
        default:
            return false
        }
    }
}

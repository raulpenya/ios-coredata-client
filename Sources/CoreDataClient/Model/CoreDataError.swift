//
//  CoreDataClientError.swift
//  CoreDataClient
//
//  Created by Raul Peña on 11/2/26.
//

public enum CoreDataError: Error {
    case fetchFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)
    case unknown(Error)
}

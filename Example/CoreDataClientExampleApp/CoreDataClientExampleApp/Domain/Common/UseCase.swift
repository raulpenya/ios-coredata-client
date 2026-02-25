//
//  UseCase.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

import Foundation

protocol UseCase {
    associatedtype T
    associatedtype Q: RequestValues
    func execute(_ requestValues: Q) async throws -> T
}

public protocol RequestValues {}

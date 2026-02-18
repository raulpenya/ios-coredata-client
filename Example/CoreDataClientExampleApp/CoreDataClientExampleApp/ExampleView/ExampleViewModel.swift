//
//  ExampleViewModel.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 11/2/26.
//

import Foundation
import CoreDataClient

@MainActor
@Observable
final class ExampleViewModel {

    private let dataSource: CoreDataDataSource

    init(dataSource: CoreDataDataSource) {
        self.dataSource = dataSource
    }
}

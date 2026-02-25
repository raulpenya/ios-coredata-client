//
//  Untitled.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 19/2/26.
//

import CoreData
import CoreDataClient

struct DeletePersonByEmailRequest: CoreDataRequestProtocol {
    typealias Response = Void

    let email: String

    func execute(in context: NSManagedObjectContext) throws {
        let request = PersonLocalEntity.fetchRequest(with: email)
        let result = try context.fetch(request)

        guard let person = result.first else { return }

        context.delete(person)
        try context.save()
    }

    func mapError(_ error: Error) -> CoreDataClient.CoreDataError {
        .deleteFailed(error)
    }
}

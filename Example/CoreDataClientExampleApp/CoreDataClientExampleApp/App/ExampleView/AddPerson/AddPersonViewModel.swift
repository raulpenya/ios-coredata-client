//
//  Untitled.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 20/2/26.
//

import SwiftUI

@MainActor
@Observable
final class AddPersonViewModel {

    var name = ""
    var email = ""
    var isSaving = false
    var errorMessage: String?

    private let addPerson: AddPerson

    init(addPerson: AddPerson) {
        self.addPerson = addPerson
    }
    
    func save() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        
        do {
            let person = Person(name: name, email: email)
            _ = try await addPerson.execute(
                AddPersonRequestValues(person: person)
            )
            return true
        } catch {
            errorMessage = mapError(error)
            return false
        }
    }
    
    private func mapError(_ error: Error) -> String {
        error.localizedDescription
    }
}

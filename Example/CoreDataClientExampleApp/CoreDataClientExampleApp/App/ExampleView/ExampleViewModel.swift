//
//  ExampleViewModel.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 11/2/26.
//

import Foundation

@MainActor
@Observable
final class ExampleViewModel {
    
    private let addPerson: AddPerson
    private let getAllPersons: GetAllPersons
    private let removePerson: RemovePerson
    private let removePersons: RemovePersons
    
    var persons: [Person] = []
    var isLoading = false
    var errorMessage: String?
    
    init(addPerson: AddPerson, getAllPersons: GetAllPersons, removePerson: RemovePerson, removePersons: RemovePersons) {
        self.addPerson = addPerson
        self.getAllPersons = getAllPersons
        self.removePerson = removePerson
        self.removePersons = removePersons
    }
    
    func loadPersons() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            persons = try await getAllPersons.execute(
                GetAllPersonsRequestValues()
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deletePerson(email: String) async {
        do {
            try await removePerson.execute(
                RemovePersonRequestValues(email: email)
            )
            await loadPersons()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAll() async {
        do {
            let emails = persons.map { $0.email }
            try await removePersons.execute(
                RemovePersonsRequestValues(emails: emails)
            )
            persons.removeAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

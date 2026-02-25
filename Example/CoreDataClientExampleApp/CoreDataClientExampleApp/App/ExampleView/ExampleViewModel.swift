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
    private let repository: PersonRepository
    private var streamTask: Task<Void, Never>?
    
    var persons: [Person] = []
    var isLoading = false
    var errorMessage: String?
    
    init(repository: PersonRepository) {
        self.repository = repository
        subscribe()
    }
    
    private func subscribe() {
        streamTask = Task { [weak self] in
            guard let self else { return }
            // Even though the class is @MainActor, the Task body is not guaranteed to execute on main actor unless you hop back explicitly.
            for await persons in self.repository.personsStream {
                await MainActor.run {
                    self.persons = persons
                }
            }
        }
    }
    
    func initialLoad() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            persons = try await repository.getAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deletePerson(email: String) async {
        do {
            try await repository.remove(byEmail: email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAll() async {
        do {
            try await repository.remove(
                emails: persons.map(\.email)
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    deinit {
        streamTask?.cancel()
    }
}

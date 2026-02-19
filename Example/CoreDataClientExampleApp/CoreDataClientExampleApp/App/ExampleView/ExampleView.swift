//
//  ExampleView.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 9/2/26.
//

import SwiftUI

struct ExampleView: View {

    @State private var viewModel: ExampleViewModel
    @Bindable var coordinator: ExampleCoordinator

    init(coordinator: ExampleCoordinator) {
        self.coordinator = coordinator
        _viewModel = State(
            wrappedValue: coordinator.makeViewModel()
        )
    }

    var body: some View {
        List {
            ForEach(viewModel.persons, id: \.email) { person in
                VStack(alignment: .leading) {
                    Text(person.name)
                    Text(person.email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete { indexSet in
                Task {
                    for index in indexSet {
                        let person = viewModel.persons[index]
                        await viewModel.deletePerson(email: person.email)
                    }
                }
            }
        }
        .navigationTitle("Persons")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Delete All") {
                    Task {
                        await viewModel.deleteAll()
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    coordinator.goToAddPerson()
                }
            }
        }
        .navigationDestination(for: ExampleCoordinator.Route.self) { route in
            switch route {
            case .addPerson:
                coordinator.makeAddPersonView()
            }
        }
        .task {
            await viewModel.loadPersons()
        }
    }
}

//#Preview {
//    ExampleView()
//}

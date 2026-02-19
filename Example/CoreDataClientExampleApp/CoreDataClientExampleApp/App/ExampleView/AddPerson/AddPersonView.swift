//
//  AddPersonView.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 20/2/26.
//

import SwiftUI

struct AddPersonView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""

    let coordinator: ExampleCoordinator

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Email", text: $email)

            Button("Save") {
                Task {
                    await save()
                }
            }
        }
        .navigationTitle("Add Person")
    }

    private func save() async {
        let viewModel = coordinator.makeViewModel()

        let person = Person(name: name, email: email)

//        try? await viewModel.addPerson.execute(
//            AddPersonRequestValues(person: person)
//        )

        dismiss()
    }
}

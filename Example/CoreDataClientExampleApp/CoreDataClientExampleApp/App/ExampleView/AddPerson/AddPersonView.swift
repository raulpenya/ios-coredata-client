//
//  AddPersonView.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 20/2/26.
//

import SwiftUI

struct AddPersonView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddPersonViewModel

    init(viewModel: AddPersonViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            TextField("Name", text: $viewModel.name)
            TextField("Email", text: $viewModel.email)

            Button("Save") {
                Task {
                    if await viewModel.save() {
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("Add Person")
    }
}

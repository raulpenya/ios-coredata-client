//
//  ExampleView.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 9/2/26.
//

import SwiftUI

struct ExampleView: View {

    let coordinator: ExampleCoordinator
    @State private var viewModel: ExampleViewModel

    init(coordinator: ExampleCoordinator) {
        self.coordinator = coordinator
        _viewModel = State(
            wrappedValue: coordinator.makeViewModel()
        )
    }

    var body: some View {
        Text("Example Screen")
    }
}

//#Preview {
//    ExampleView()
//}

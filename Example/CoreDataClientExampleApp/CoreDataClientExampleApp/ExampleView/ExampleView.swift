//
//  ContentView.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 9/2/26.
//

import SwiftUI

struct ExampleView: View {
        
    @Environment(\.factory) private var factory
    @StateObject private var viewModel: ExampleViewModel
    
    init(factory: AppFactory) {
        _viewModel = StateObject(
            wrappedValue: factory.makeRootViewModel()
        )
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ExampleView()
}

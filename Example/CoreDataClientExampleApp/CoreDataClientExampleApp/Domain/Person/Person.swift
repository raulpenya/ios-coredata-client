//
//  Person.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

struct Person: Equatable {
    let name: String
    let email: String
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}

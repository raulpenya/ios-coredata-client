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

extension Person {
    static let persons: [Person] = [
        Person(name: "Shyam", email: "shyamjaiswal@gmail.com"),
        Person(name: "Bob", email: "bob32@gmail.com"),
        Person(name: "Jai", email: "jai87@gmail.com")
    ]
}

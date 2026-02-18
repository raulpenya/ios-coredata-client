//
//  PersonRepository.swift
//  CoreDataClientExampleApp
//
//  Created by Raul Peña on 18/2/26.
//

protocol PersonRepository {
    func addPerson(_ requestValues: AddPersonRequestValues) async throws -> Person
    func getAllPersons(_ requestValues: GetAllPersonsRequestValues) async throws -> [Person]
    func getPerson(_ requestValues: GetPersonByEmailRequestValues) async throws -> Person?
    func removePerson(_ requestValues: RemovePersonRequestValues) async throws
    func removePersons(_ requestValues: RemovePersonsRequestValues) async throws
}

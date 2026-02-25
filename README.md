# CoreDataClient

A lightweight, testable Core Data abstraction for iOS and macOS, built around async/await and request-based execution.

## Installation

```swift
.package(url: "https://github.com/raulpenya/ios-coredata-client.git", from: "X.X.X")
```

## Overview

CoreDataClient provides a simple and flexible abstraction for executing Core Data operations while keeping:
- Persistence logic isolated
- Read and write semantics clearly separated
- Mapping between managed objects and domain models explicit
- The codebase highly testable

Instead of exposing NSManagedObjectContext directly, the client executes strongly typed requests that encapsulate both behavior and error mapping.

### CoreDataProtocol

CoreDataProtocol defines the public API of the client and supports both main-context and background execution:
```swift
public protocol CoreDataProtocol {
    func perform<Request: CoreDataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response
    
    func performBackground<Request: CoreDataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response
}
```

Both methods execute a request object that defines:
- The operation to perform
- The expected response type
- How errors should be mapped

This ensures that persistence logic remains encapsulated and strongly typed.

### CoreDataRequestProtocol

Every Core Data operation is modeled as a request conforming to:
```swift
public protocol CoreDataRequestProtocol: Sendable {
    associatedtype Response
    
    func execute(in context: NSManagedObjectContext) throws -> Response
    func mapError(_ error: Error) -> CoreDataError
}
```

This pattern:
- Encapsulates transaction logic
- Preserves context boundaries
- Centralizes error mapping
- Keeps the client infrastructure minimal

## Built-in Requests
### FetchRequest

Encapsulates a fetch operation and a transformation layer:
```swift
public struct FetchRequest<T: NSManagedObject, Q>: CoreDataRequestProtocol {
    public let request: NSFetchRequest<T>
    public let transform: ([T]) throws -> Q
}
```

Generic parameters:
- `T`: The `NSManagedObject` type being fetched
- `Q`: The final return type

The `transform` closure cleanly separates persistence-layer query specification from domain mapping.

### InsertRequest

Encapsulates insertion logic via a context-bound closure:
```swift
public struct InsertRequest<Q>: CoreDataRequestProtocol {
    public let insert: (NSManagedObjectContext) throws -> Q
}
```

The request:
- Executes the mutation
- Automatically saves if the context has changes
- Returns the desired response type

### DeleteRequest

Deletes a single object using its `NSManagedObjectID`:
```swift
public struct DeleteRequest: CoreDataRequestProtocol {
    public let objectID: NSManagedObjectID
}
```

Using `NSManagedObjectID` ensures:
- Thread safety
- Context independence
- Stable identity across contexts

### BatchDeleteRequest

Performs optimized batch deletion for SQLite stores and gracefully falls back for in-memory stores.
```swift
public struct BatchDeleteRequest: CoreDataRequestProtocol {
    public let request: NSFetchRequest<NSFetchRequestResult>
}
``` 

For SQLite stores, it uses `NSBatchDeleteRequest and merges object ID changes back into the context.

## CoreDataDataSource

`CoreDataDataSource` is the default implementation of `CoreDataProtocol`.

It receives a `PersistentStoreProtocol` via dependency injection:
```swift
public final class CoreDataDataSource: CoreDataProtocol {
    private let persistentStore: PersistentStoreProtocol
}
```

Execution behavior:
- `perform` → Executes on `viewContext`
- `performBackground` → Executes inside `performBackgroundTask`

All operations:
- Respect context boundaries
- Preserve thread safety
- Map errors through the request

## PersistentStore

`PersistentStore` encapsulates `NSPersistentContainer` initialization:
```swift
public protocol PersistentStoreProtocol {
    var container: NSPersistentContainer { get }
}
public final class PersistentStore: PersistentStoreProtocol {
    public let container: NSPersistentContainer
}
```

Initialization is asynchronous and ensures:
- Proper persistent store loading
- Automatic merging from parent contexts
- Explicit merge policy configuration

## CoreDataConfiguration

Configuration is fully injectable:
```swift
public struct CoreDataConfiguration {
    public let modelName: String
    public let managedObjectModel: NSManagedObjectModel
    public let storeDescription: NSPersistentStoreDescription
}
```

This allows:
- Custom store locations
- In-memory testing stores
- Controlled environment setup

## Usage
### Async/Await Example
```swift
import CoreDataClient

final class PersonRepository {

    private let client: CoreDataProtocol

    init(client: CoreDataProtocol) {
        self.client = client
    }

    func getAll() async throws -> [Person] {
        let request = FetchRequest<PersonEntity, [Person]>(
            request: PersonEntity.fetchRequest()
        ) { entities in
            entities.map { $0.toDomain() }
        }

        return try await client.perform(request)
    }
}
```
### Insert Example
```swift
func insert(name: String, email: String) async throws {
    let request = InsertRequest<Void> { context in
        let entity = PersonEntity(context: context)
        entity.name = name
        entity.email = email
    }

    try await client.performBackground(request)
}
```
## Error Handling

All errors are mapped to a strongly typed `CoreDataError`:
```swift
public enum CoreDataError: Error, Equatable {
    case fetchFailed(Error)
    case insertFailed(Error)
    case deleteFailed(Error)
    case batchDeleteFailed(Error)
    case unknown(Error)
}
```

This makes failure cases explicit and easy to assert in unit tests.

## Testing

The client is fully testable thanks to:
- `PersistentStoreProtocol`
- Injectable configurations
- In-memory store support

Example:
```swift
let description = NSPersistentStoreDescription()
description.type = NSInMemoryStoreType

let configuration = CoreDataConfiguration(
    modelName: "Model",
    managedObjectModel: model,
    storeDescription: description
)

let store = try await PersistentStore(configuration: configuration)
let client = CoreDataDataSource(persistentStore: store)
```

This allows deterministic, isolated persistence testing.

## Demo

For a complete integration example, see the demo application included in the repository.
It showcases:
- Fetch, insert, delete, and batch delete requests
- Background execution
- Clean Architecture repository integration
- Swift Concurrency usage
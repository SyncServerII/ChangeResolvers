
import Foundation

// Enabling the application of changes to a single file. The file must be read in its entirety from storage, some series of changes applied, and then the updates written back to storage. It is called `WholeFileReplacer` due to this mode of full read/full write to make changes.

// The intent is that, while the method in a object conforming to this protocol may throw errors due to some internal problem or general problem with the data they receive, they will never throw errors purely due to merge conflicts. They will always be able to resolve merge conflicts.
public protocol WholeFileReplacer: ChangeResolver {
    // Reconstitute the file from Data.
    init(with data: Data) throws
    
    // This must not throw an error due to adding the same record more than once.
    mutating func add(newRecord: Data) throws
    
    // Convert the entire file into a Data object
    func getData() throws -> Data
}

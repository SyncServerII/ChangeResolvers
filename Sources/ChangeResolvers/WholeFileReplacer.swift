
import Foundation
import ServerAccount
import ServerShared
import LoggerAPI

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

private enum Errors: Swift.Error {
    case downloadError(DownloadResult)
    case failedInitializing
    case noContentsForChange
    case failedAddingChange(Swift.Error)
    case failedGettingReplacerData
    case failedUploadingNewFileVersion
}

public extension WholeFileReplacer {
    static func apply(changes: [ChangeResolverContents], toFileUUID fileUUID: String, currentFileVersion: FileVersionInt, deviceUUID: String, cloudStorage: CloudStorage, options: CloudStorageFileNameOptions, completion: ((Swift.Result<ApplyResult, Error>) -> ())? = nil) {
        
        // We're applying changes and creating the next version of the file
        let nextVersion = currentFileVersion + 1
        
        let currentCloudFileName = Filename.inCloud(deviceUUID:deviceUUID, fileUUID: fileUUID, mimeType:options.mimeType, fileVersion: currentFileVersion)
        
        Log.debug("downloadFile: \(currentCloudFileName)")
        cloudStorage.downloadFile(cloudFileName: currentCloudFileName, options: options) { downloadResult in
            guard case .success(data: let fileContents, checkSum: _) = downloadResult else {
                completion?(.failure(Errors.downloadError(downloadResult)))
                return
            }
            
            guard var replacer = try? Self.init(with: fileContents) else {
                completion?(.failure(Errors.failedInitializing))
                return
            }
            
            for change in changes {
                guard let changeData = change.uploadContents else {
                    completion?(.failure(Errors.noContentsForChange))
                    return
                }
                
                do {
                    try replacer.add(newRecord: changeData)
                } catch let error {
                    completion?(.failure(Errors.failedAddingChange(error)))
                    return
                }
            }
            
            guard let replacementFileContents = try? replacer.getData() else {
                completion?(.failure(Errors.failedGettingReplacerData))
                return
            }
            
            let nextCloudFileName = Filename.inCloud(deviceUUID:deviceUUID, fileUUID: fileUUID, mimeType:options.mimeType, fileVersion: nextVersion)

            Log.debug("uploadFile: \(nextCloudFileName)")

            cloudStorage.uploadFile(cloudFileName: nextCloudFileName, data: replacementFileContents, options: options) { uploadResult in
                guard case .success(let checkSum) = uploadResult else {
                    completion?(.failure(Errors.failedUploadingNewFileVersion))
                    return
                }
                
                let result = ApplyResult(newFileVersion: nextVersion, checkSum: checkSum)
                completion?(.success(result))
            }
        }
    }
}

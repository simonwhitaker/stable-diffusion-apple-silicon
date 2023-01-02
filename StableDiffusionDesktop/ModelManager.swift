//
//  ModelManager.swift
//  StableDiffusionDemo
//
//  Created by Simon on 21/12/2022.
//

import AppleArchive
import Combine
import Foundation
import System
import ZIPFoundation

let requiredFiles = [
//    "SafetyChecker.mlmodelc",
    "TextEncoder.mlmodelc",
    "Unet.mlmodelc",
    "VAEDecoder.mlmodelc",
    "merges.txt",
    "vocab.json"
]

enum ModelDownloadStatus {
    case none, downloading, unpacking
}

final class ModelData: ObservableObject {
    @Published var hasCachedModels: Bool = false
    let localModelDirectoryUrl: URL = URL.libraryDirectory.appending(component: "models", directoryHint: .isDirectory)
    let remoteModelsUrl: URL

    init() {
        remoteModelsUrl = URL.init(string: "http://127.0.0.1:8080/models.zip")!
        hasCachedModels = getHasCachedModels()
        
        do {
            print("Creating local model directory...")
            try FileManager.default.createDirectory(at: localModelDirectoryUrl, withIntermediateDirectories: true)
        } catch {
            print("On attempting to create local model directory: \(error.localizedDescription)")
        }

        print("Local models URL: \(localModelDirectoryUrl)")
        print("Remote models URL: \(remoteModelsUrl)")
    }

    private func getHasCachedModels() -> Bool {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: localModelDirectoryUrl,
                includingPropertiesForKeys: nil
            )

            let filenames = directoryContents.map { $0.lastPathComponent }
            for f in requiredFiles {
                if (filenames.firstIndex(of: f) == nil) {
                    print("\(f) is missing from the cache, need to download the models")
                    return false
                }
            }
        } catch {
            print("On checking for models: \(error)")
            return false
        }
        return true
    }

    func downloadModels(completion: @escaping (URL?, Error?) -> Void, progress: @escaping (Double, ModelDownloadStatus) -> Void) -> Void {
        print("Downloading \(remoteModelsUrl.lastPathComponent)")
        let request = URLRequest(url: remoteModelsUrl)
        var observation: NSKeyValueObservation? = nil
        let downloadTask = URLSession.shared.downloadTask(with: request) { localURL, _, error in
            if error != nil {
                completion(nil, error)
                return
            }
            guard let localURL = localURL else {
                // TODO: call completion with an error here
                print("🤷‍♂️ URLSessionDownloadTask didn't return an error, but didn't return a local URL either")
                return
            }
            print("Unpacking \(localURL.lastPathComponent)")
            do {
                observation?.invalidate()
                progress(1.0, .unpacking)
                let _ = try FileManager.default.unzipItem(at: localURL, to: self.localModelDirectoryUrl)
                completion(localURL, nil)
            }
            catch {
                print("On unpacking archive:", error)
                completion(nil, error)
            }
        }
        observation = downloadTask.progress.observe(\.fractionCompleted) { observationProgress, _ in
            progress(observationProgress.fractionCompleted, .downloading)
        }
        downloadTask.resume()
    }

    private func unarchiveModels(aarFile: FilePath) throws -> Void {
        // See https://developer.apple.com/documentation/accelerate/decompressing_and_extracting_an_archived_directory

        // Create the File Stream to Read the Source Archive
        guard let readFileStream = ArchiveByteStream.fileStream(
            path: aarFile,
            mode: .readOnly,
            options: [],
            permissions: FilePermissions(rawValue: 0o644)) else {
            print("Call to ArchiveByteStream.fileStream failed")
            return
        }
        defer {
            try? readFileStream.close()
        }

        // Create the Decompression Stream
        guard let decompressStream = ArchiveByteStream.decompressionStream(readingFrom: readFileStream) else {
            print("Call to ArchiveByteStream.decompressionStream failed")
            return
        }
        defer {
            try? decompressStream.close()
        }

        // Create the Decoding Stream
        guard let decodeStream = ArchiveStream.decodeStream(readingFrom: decompressStream) else {
            print("Call to ArchiveStream.decodeStream failed")
            return
        }
        defer {
            try? decodeStream.close()
        }

        // Specify the Destination
        let decompressDestination = FilePath(localModelDirectoryUrl.path())

        // Create the destination, if needed
        do {
            try FileManager.default.createDirectory(at: localModelDirectoryUrl, withIntermediateDirectories: true)
        } catch {
            print("On creating cached model directory: \(error)")
        }

        // Create the extract stream
        guard let extractStream = ArchiveStream.extractStream(extractingTo: decompressDestination, flags: [.ignoreOperationNotPermitted]) else {
            print("Call to ArchiveStream.extractStream failed")
            return
        }
        defer {
            try? extractStream.close()
        }

        // Decompress and Extract the Archived Directory
        do {
            _ = try ArchiveStream.process(readingFrom: decodeStream, writingTo: extractStream)
        } catch {
            print("Call to ArchiveStream.process failed")
            throw error
        }
    }
}




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

final class ModelData: ObservableObject {
    @Published var hasLocalModels: Bool = hasCachedModels()
}

var cachedModelsUrl: URL = URL.cachesDirectory
let requiredFiles = [
    "SafetyChecker.mlmodelc",
    "TextEncoder.mlmodelc",
    "UnetChunk1.mlmodelc",
    "UnetChunk2.mlmodelc",
    "VAEDecoder.mlmodelc",
    "merges.txt",
    "vocab.json"
]

#if targetEnvironment(simulator)
let remoteModelsUrl = URL.init(filePath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appending(path: "models/models.aar")
#else
let remoteModelsUrl = URL.init(string: "http://192.168.1.51:8080/models.aar")!
#endif

private func hasCachedModels() -> Bool {
    do {
        print("Cached models path: \(cachedModelsUrl.absoluteString)")
        print("Remote models path: \(remoteModelsUrl.absoluteString)")
        let directoryContents = try FileManager.default.contentsOfDirectory(
            at: cachedModelsUrl,
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

func downloadModels() async throws -> Void {
    let modelsRequest = URLRequest(url: remoteModelsUrl)
    print("Downloading \(remoteModelsUrl.lastPathComponent)")
    let (localURL, _) = try await URLSession.shared.download(for: modelsRequest)
    print("Unpacking \(remoteModelsUrl.lastPathComponent)")
    let _ = try unarchiveModels(aarFile: FilePath(localURL.path()))
}

func unarchiveModels(aarFile: FilePath) throws -> Void {
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
    let decompressDestination = FilePath(cachedModelsUrl.path())

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

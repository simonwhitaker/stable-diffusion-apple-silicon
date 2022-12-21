//
//  ModelManager.swift
//  StableDiffusionDemo
//
//  Created by Simon on 21/12/2022.
//

import Foundation

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
let remoteModelsUrl = URL.init(filePath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appending(path: "models/models.tar")

func hasModels() -> Bool {
    do {
        print("Cached models path: \(cachedModelsUrl.path())")
        print("Remote models path: \(remoteModelsUrl.path())")
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
    let (data, _) = try await URLSession.shared.data(for: modelsRequest)
    print("Untarring \(remoteModelsUrl.lastPathComponent)")
    try FileManager.default.createFilesAndDirectories(
        url: cachedModelsUrl,
        tarData: data,
        progress: nil
    )
}

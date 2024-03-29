//
//  ModelManager.swift
//  StableDiffusionDemo
//
//  Created by Simon on 21/12/2022.
//

import Foundation

let coreRequiredFiles = [
//    "SafetyChecker.mlmodelc",
    "TextEncoder.mlmodelc",
    "VAEDecoder.mlmodelc",
    "merges.txt",
    "vocab.json"
]

let requiredFilesIOs = coreRequiredFiles + ["UnetChunk1.mlmodelc", "UnetChunk2.mlmodelc"]
let requiredFilesMacOS = coreRequiredFiles + ["Unet.mlmodelc"]

enum ModelDownloadStatus {
    case none, downloading, unpacking
}

#if os(iOS) || targetEnvironment(simulator)
let isRunningOnMac = false
#else
let isRunningOnMac = true
#endif

final class ModelData: ObservableObject {
    @Published var hasCachedModels: Bool = false
    let localModelDirectoryUrl: URL = URL.libraryDirectory.appending(component: "models", directoryHint: .isDirectory)
    let remoteModelsUrl: URL

    init() {
#if os(iOS) && !targetEnvironment(simulator)
        // TODO: replace this with a legit URL, rather than just an ephemeral HTTP server running on my laptop.
        remoteModelsUrl = URL.init(string: "http://192.168.1.3/~simon/models/sd20_split_einsum.aar")!
#else
        remoteModelsUrl = URL.init(string: "http://127.0.0.1:8080/models.aar")!
#endif
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
            let requiredFiles = isRunningOnMac ? requiredFilesMacOS : requiredFilesIOs
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

    func localModelMetadata() -> ModelMetadata? {
        let decoder = JSONDecoder()
        let path = self.localModelDirectoryUrl.appending(path: "TextEncoder.mlmodelc/metadata.json")

        do {
            let metadata = try Data(contentsOf: path)
            let d = try decoder.decode([ModelMetadata].self, from: metadata)
            if !d.isEmpty {
                return d[0]
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
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
                let _ = try FileManager.default.unarchiveItems(at: localURL, to: self.localModelDirectoryUrl)
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
}

struct ModelMetadata: Codable {
    var version: String
}

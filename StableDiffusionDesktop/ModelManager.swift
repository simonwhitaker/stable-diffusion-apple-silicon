//
//  ModelManager.swift
//  StableDiffusionDemo
//
//  Created by Simon on 21/12/2022.
//

import Foundation

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
        remoteModelsUrl = URL.init(string: "http://127.0.0.1:8080/models.aar")!
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




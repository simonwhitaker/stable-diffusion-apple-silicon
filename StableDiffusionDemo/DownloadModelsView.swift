//
//  DownloadModelsView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 20/12/2022.
//

import SwiftUI
import Light_Swift_Untar

struct DownloadModelsView: View {
    @State private var shouldDownloadModels = false
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

    var body: some View {
        return HStack {
            if shouldDownloadModels {
                Button {
                    let session = URLSession(configuration: .default)
                    let request = URLRequest(url: remoteModelsUrl)
                    session.downloadTask(with: request, completionHandler: { tempLocalUrl, request, error in
                        do {
                            if let tempLocalUrl = tempLocalUrl, error == nil {
                                try FileManager.default.createFilesAndDirectories(
                                    url: cachedModelsUrl,
                                    tarData: Data(contentsOf: tempLocalUrl),
                                    progress: nil
                                )
                                shouldDownloadModels = false
                            }
                        } catch {
                            print(error)
                        }
                    }).resume()
                } label: {
                    Text("Download models")
                }
            } else {
                Text("The models are downloaded, you're good to go")
            }
        }.onAppear {
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
                        shouldDownloadModels = true
                    } else {
                        print("\(f) is in the cache")
                    }
                }
            } catch {
                print("Couldn't find cache dir? \(error)")
            }
        }
    }
}

struct DownloadModelsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadModelsView()
    }
}

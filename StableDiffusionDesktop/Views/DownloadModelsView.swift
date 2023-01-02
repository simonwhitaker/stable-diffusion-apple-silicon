//
//  DownloadModelsView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 20/12/2022.
//

import SwiftUI

struct DownloadModelsView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var isDownloading: Bool = false
    @State private var downloadProgress: Double = 0
    @State private var downloadStatus: ModelDownloadStatus = .none

    var body: some View {
        return VStack(spacing: 20.0) {
            Text("To start, you need to download the AI models. They're large (2.3GB), so do this over Wifi. You will only need to do this once.")
            ZStack {
                Button {
                    isDownloading = true
                    modelData.downloadModels { _, error in
                        DispatchQueue.main.async {
                            if error != nil {
                                print("Error: \(error!)")
                            } else {
                                modelData.hasCachedModels = true
                            }
                            isDownloading = false
                        }
                    } progress: { progress, status in
                        DispatchQueue.main.async {
                            self.downloadProgress = progress
                            self.downloadStatus = status
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                        Text("Download models")
                    }
                }.opacity(isDownloading ? 0.0 : 1.0)
                    .disabled(isDownloading)

                ProgressView(value: downloadProgress) {
                    Text(progressLabelText())
                }.opacity(isDownloading ? 1.0 : 0.0)
            }
        }
    }

    func progressLabelText() -> String {
        switch downloadStatus {
        case .none:
            return ""
        case .downloading:
            return "Downloading models..."
        case .unpacking:
            return "Unpacking models..."
        }
    }
}

struct DownloadModelsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadModelsView()
    }
}

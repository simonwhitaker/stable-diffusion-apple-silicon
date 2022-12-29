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
    @State private var progress: Double = 0

    var body: some View {
        return VStack(spacing: 20.0) {
            Text("To start, you need to download the AI models. They're large (2.3GB), so do this over Wifi. You will only need to do this once.")
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
                } progress: { progress in
                    DispatchQueue.main.async {
                        self.progress = progress
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.down.circle")
                    Text("Download models")
                }
            }.disabled(isDownloading)

            ProgressView(value: progress, label: {
                Text("Downloading models...")
            }).opacity(isDownloading ? 1.0 : 0.0)
        }.padding()
    }
}

struct DownloadModelsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadModelsView()
    }
}

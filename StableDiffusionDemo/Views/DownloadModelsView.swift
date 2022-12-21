//
//  DownloadModelsView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 20/12/2022.
//

import SwiftUI

struct DownloadModelsView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var isDownloading = false

    var body: some View {
        return HStack {
            Button {
                Task {
                    do {
                        isDownloading = true
                        try await downloadModels()
                        isDownloading = false
                        modelData.hasLocalModels = true
                    } catch {
                        print(error.localizedDescription)
                        isDownloading = false
                    }
                }
            } label: {
                Text("Download models")
            }.disabled(isDownloading)
        }.padding()
    }
}

struct DownloadModelsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadModelsView()
    }
}

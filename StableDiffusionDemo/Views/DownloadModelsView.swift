//
//  DownloadModelsView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 20/12/2022.
//

import SwiftUI
import Light_Swift_Untar

struct DownloadModelsView: View {
    @State private var shouldDownloadModels = !hasModels()

    var body: some View {
        return HStack {
            if shouldDownloadModels {
                Button {
                    Task {
                        do {
                            try await downloadModels()
                            shouldDownloadModels = false
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Download models")
                }
            }
        }
    }
}

struct DownloadModelsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadModelsView()
    }
}

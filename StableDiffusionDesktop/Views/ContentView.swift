//
//  ContentView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 14/12/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var imageGenerator: ImageGenerator? = nil
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        VStack(spacing:10.0) {
            if !modelData.hasCachedModels {
                DownloadModelsView()
            } else if imageGenerator == nil {
                LoadingModelsView().onAppear {
                    Task {
                        do {
                            imageGenerator = try await getPipeline(resourceURL: modelData.localModelDirectoryUrl)
                        } catch {
                            print("Error loading pipeline: \(error)")
                        }
                    }
                }
            } else {
                ImageGeneratorView(imageGenerator: imageGenerator!)
            }

            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ModelData())
    }
}

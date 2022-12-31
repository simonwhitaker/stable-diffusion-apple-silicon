//
//  ContentView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 14/12/2022.
//

import SwiftUI
import StableDiffusion

struct ContentView: View {
    @State private var imageGenerator: ImageGenerator? = nil
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        VStack(spacing:10.0) {
            Text("Stable Diffusion Demo").font(.title)

            if !modelData.hasCachedModels {
                DownloadModelsView()
            } else if imageGenerator == nil {
                LoadingModelsView().onAppear {
                    var _pipeline: StableDiffusionPipeline? = nil
                    DispatchQueue.global().async {
                        do {
                            print("Loading pipeline...")
                            _pipeline = try StableDiffusionPipeline(resourcesAt: modelData.localModelDirectoryUrl, disableSafety: true)
                            DispatchQueue.main.async {
                                imageGenerator = _pipeline
                            }
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

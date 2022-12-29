//
//  ContentView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 14/12/2022.
//

import SwiftUI
import StableDiffusion

struct ContentView: View {
    @State private var pipeline: StableDiffusionPipeline? = nil
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        VStack {
            Text("Stable Diffusion Demo").font(.title)

            if !modelData.hasCachedModels {
                DownloadModelsView()
            } else if pipeline == nil {
                LoadingModelsView().onAppear {
                    var _pipeline: StableDiffusionPipeline? = nil
                    DispatchQueue.global().async {
                        do {
                            print("Loading pipeline...")
                            _pipeline = try StableDiffusionPipeline(resourcesAt: modelData.cachedModelsUrl, disableSafety: true)
                            DispatchQueue.main.async {
                                pipeline = _pipeline
                            }
                        } catch {
                            print("Error loading pipeline: \(error)")
                        }
                    }
                }
            } else {
                ImageGeneratorView(pipeline: pipeline!)
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

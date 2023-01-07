//
//  ContentView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 14/12/2022.
//

import SwiftUI
import StableDiffusion
import CoreML

struct ContentView: View {
    @State private var imageGenerator: ImageGenerator? = nil
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        VStack(spacing:10.0) {
            if !modelData.hasCachedModels {
                DownloadModelsView()
            } else if imageGenerator == nil {
                LoadingModelsView().onAppear {
                    var _pipeline: StableDiffusionPipeline? = nil
                    DispatchQueue.global().async {
                        do {
                            print("Loading pipeline...")

                            // I'm seeing random errors on instantiating the pipeline and/or generating images that mention ANE. ANE is Apple Neural Engine. Setting a configuration with computeUnits of .cpuAndGPU prevents this code from running on the neural engine.
                            let configuration = MLModelConfiguration()
                            configuration.computeUnits = .cpuAndGPU

                            _pipeline = try StableDiffusionPipeline(resourcesAt: modelData.localModelDirectoryUrl, configuration: configuration, disableSafety: true)
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

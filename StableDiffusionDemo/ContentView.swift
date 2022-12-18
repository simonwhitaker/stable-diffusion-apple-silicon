//
//  ContentView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 14/12/2022.
//

import SwiftUI
import StableDiffusion

struct ContentView: View {
    @State private var prompt: String = "A photo of a kitten on the moon"
    @State private var image: CGImage? = nil
    @State private var isLoading = false

    var body: some View {
        VStack {
            Text("Stable Diffusion Demo").font(.title)
            HStack {
                TextField("Prompt:", text: $prompt)
                Button(
                    action: {
                        print("Calling stable diffusion with prompt: \"\(prompt)\"")

                        guard let modelsUrl = Bundle.main.url(forResource: "merges", withExtension: "txt")?.deletingLastPathComponent() else {
                            print("Models URL can't be determined")
                            return
                        }

                        isLoading = true
                        DispatchQueue.global(qos:.background).async {
                            var newImage: CGImage?
                            do {
                                let pipeline = try StableDiffusionPipeline(resourcesAt: modelsUrl, disableSafety: true)
                                newImage = try pipeline.generateImages(prompt:prompt, stepCount: 3).first!

                                DispatchQueue.main.async {
                                    image = newImage
                                    isLoading = false
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    print("There was an error: \(error)")
                                    isLoading = false
                                }
                            }
                        }
                    },
                    label: {
                        ZStack {
                            Text("Go").opacity(isLoading ? 0.0 : 1.0)
                            if isLoading {
                                ProgressView()
                            }
                        }
                    }
                ).disabled(isLoading)
            }

            if image != nil {
                Image(image!, scale: 1.0, label: Text(verbatim: ""))
            }

            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

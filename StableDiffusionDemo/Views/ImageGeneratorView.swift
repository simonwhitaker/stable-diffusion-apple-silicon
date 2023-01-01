//
//  ImageGeneratorView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 29/12/2022.
//

import SwiftUI
import StableDiffusion

struct ImageGeneratorView: View {
    @State private var prompt: String = "A photo of a kitten on the moon"
    @State private var cgImage: CGImage? = nil
    @State private var generationTime: TimeInterval?

    private var image: Image? {
        guard let cgImage = cgImage else {
            return nil
        }
        return Image(cgImage, scale: 1.0, label: Text(verbatim: ""))
    }

    var imageGenerator: ImageGenerator

    var body: some View {
        VStack {
            HStack {
                TextField("", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task {
                        print("Generating image prompt: \"\(prompt)\"")
                        do {
                            let tStart = Date.now
                            let images = try await imageGenerator.generateImagesForPrompt(prompt: prompt, imageCount: 1)
                            generationTime = Date.now.timeIntervalSince(tStart)
                            cgImage = images.first!
                        } catch {
                            print("There was an error: \(error)")
                        }
                    }
                } label: {
                    Text("Go")
                }

            }
            
            if let image = image {
                VStack() {
                    image.resizable(resizingMode: .stretch).frame(width: 300, height: 300)
                    
                    if let generationTime = generationTime {
                        Text("Generation time: \(generationTime, specifier: "%.2f")s").font(.caption)
                    }

                    ShareLink(item: image, preview: SharePreview(prompt, image: image))
                }
            }
        }
    }
}

struct ImageGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGeneratorView(imageGenerator: LocalImageGenerator())
    }
}

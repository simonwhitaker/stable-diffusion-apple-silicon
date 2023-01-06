//
//  ImageGeneratorView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 29/12/2022.
//

import SwiftUI
import StableDiffusion

private let ImageSize: CGSize = CGSize(width: 512, height: 512)

struct ImageGeneratorView: View, ImageGeneratorDelegate {
    @State private var prompt: String = "A high quality photo of a kitten on the moon"
    @State private var cgImage: CGImage? = nil
    @State private var generationTime: TimeInterval?
    @State private var step: Int = 0
    @State private var totalSteps: Int = 1
    @State private var isGenerating: Bool = false
    
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
                        let tStart = Date.now
                        step = 0
                        isGenerating = true
                        defer {
                            isGenerating = false
                        }
                        do {
                            let images = try await imageGenerator.generateImagesForPrompt(prompt: prompt, imageCount: 1, delegate: self)
                            generationTime = Date.now.timeIntervalSince(tStart)
                            cgImage = images.first!
                        } catch {
                            print("There was an error: \(error)")
                        }
                    }
                } label: {
                    Text("Go")
                }.disabled(isGenerating)
            }
            
            ZStack {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(Color(white: 0.2))
                        .font(.system(.largeTitle))
                }
            }.frame(width: ImageSize.width, height: ImageSize.height).background(Color(white: 0.6))

            if let image = image {
                ShareLink(item: image, preview: SharePreview(prompt, image: image))
            }
            
            // Status area
            if isGenerating {
                ProgressView(value: Float(step), total: Float(totalSteps)) {
                    Text("Generating...").font(.caption)
                }
            } else if let generationTime = generationTime {
                Text("Generation time: \(generationTime, specifier: "%.2f")s").font(.caption)
            }
        }
    }
    
    func didCompleteStep(step: Int, totalSteps: Int) {
        self.step = step
        self.totalSteps = totalSteps
    }
}

struct ImageGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGeneratorView(imageGenerator: LocalImageGenerator())
    }
}

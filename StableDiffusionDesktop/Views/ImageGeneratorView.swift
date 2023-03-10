//
//  ImageGeneratorView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 29/12/2022.
//

import SwiftUI

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
        return Image(decorative: cgImage, scale: 1.0, orientation: .up)
    }

    var imageGenerator: ImageGenerator

    var body: some View {
        GeometryReader { geometry in
            let imageSize = min(geometry.size.width, geometry.size.height, 512)
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
                }.frame(width: imageSize, height: imageSize).background(Color(white: 0.6))

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
    }
    
    func didCompleteStep(step: Int, totalSteps: Int, image: CGImage) {
        self.step = step
        self.totalSteps = totalSteps
        self.cgImage = image
    }
}

struct ImageGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGeneratorView(imageGenerator: LocalImageGenerator())
    }
}

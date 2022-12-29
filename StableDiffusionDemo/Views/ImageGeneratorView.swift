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
    @State private var currentStep: Int? = nil

    private var image: Image? {
        guard let cgImage = cgImage else {
            return nil
        }
        return Image(cgImage, scale: 1.0, label: Text(verbatim: ""))
    }

    var pipeline: StableDiffusionPipeline
    let NumSteps = 3

    var body: some View {
        HStack {
            TextField("Prompt:", text: $prompt)
            Button(
                action: {
                    print("Calling stable diffusion with prompt: \"\(prompt)\"")

                    currentStep = 0
                    DispatchQueue.global(qos:.background).async {
                        var newImage: CGImage?
                        do {
                            newImage = try pipeline.generateImages(prompt:prompt, stepCount: NumSteps, progressHandler: { progress in
                                print("Step \(progress.step) of \(progress.stepCount)")
                                DispatchQueue.main.async {
                                    currentStep = progress.step
                                }
                                return true
                            }).first!

                            DispatchQueue.main.async {
                                cgImage = newImage
                                currentStep = nil
                            }
                        } catch {
                            DispatchQueue.main.async {
                                print("There was an error: \(error)")
                                currentStep = nil
                            }
                        }
                    }
                },
                label: {
                    Text("Go")
                }
            ).disabled(currentStep != nil)
        }


        if currentStep != nil {
            ProgressView(value: Float(currentStep!), total: Float(NumSteps)) {
                Text("Step \(currentStep! + 1) of \(NumSteps)").font(.caption)
            }
        }

        if let image = image {
            VStack(spacing: 10.0) {
                image.resizable(resizingMode: .stretch).frame(width: 200, height: 200)
                ShareLink(item: image, preview: SharePreview(prompt, image: image))
            }
        }
    }
}

struct ImageGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let pipeline = try StableDiffusionPipeline(resourcesAt: URL.currentDirectory())
            return AnyView(ImageGeneratorView(pipeline: pipeline))
        } catch {
            return AnyView(Text("Error loading SD pipeline: \(error.localizedDescription)"))
        }
    }
}

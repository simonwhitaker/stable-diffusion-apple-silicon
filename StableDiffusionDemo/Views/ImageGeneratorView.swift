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

    private var image: Image? {
        guard let cgImage = cgImage else {
            return nil
        }
        return Image(cgImage, scale: 1.0, label: Text(verbatim: ""))
    }

    var imageGenerator: ImageGenerator

    var body: some View {
        TextField("", text: $prompt)
            .submitLabel(.go)
            .textFieldStyle(.roundedBorder)
            .onSubmit {
                Task {
                    print("Generating image prompt: \"\(prompt)\"")
                    do {
                        let images = try await imageGenerator.generateImagesForPrompt(prompt: prompt)
                        cgImage = images.first!
                    } catch {
                        print("There was an error: \(error)")
                    }
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
        ImageGeneratorView(imageGenerator: LocalImageGenerator())
    }
}

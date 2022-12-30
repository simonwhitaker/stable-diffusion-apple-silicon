//
//  ImageGenerator.swift
//  StableDiffusionDemo
//
//  Created by Simon on 30/12/2022.
//

import Foundation
import CoreGraphics
import StableDiffusion
import UIKit

protocol ImageGenerator {
    func generateImagesForPrompt(prompt: String, imageCount: Int) async throws -> [CGImage]
}

extension StableDiffusionPipeline: ImageGenerator {
    func generateImagesForPrompt(prompt: String, imageCount: Int) async throws -> [CGImage] {
        do {
            let images = try self.generateImages(prompt:prompt, imageCount: imageCount)
            return try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.main.async {
                    // The images will be nil if safety checks were performed and found the result to be un-safe. `compactMap` removes nil elements from an array.
                    continuation.resume(with: .success(images.compactMap { $0 }))
                }
            }
        } catch {
            return try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.main.async {
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
}

struct LocalImageGenerator: ImageGenerator {
    func generateImagesForPrompt(prompt: String, imageCount: Int) async throws -> [CGImage] {
        guard let image = UIImage(named: "sample-image")?.cgImage else {
            return []
        }
        return [image]
    }
}

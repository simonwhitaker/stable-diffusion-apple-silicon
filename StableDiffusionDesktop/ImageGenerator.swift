//
//  ImageGenerator.swift
//  StableDiffusionDemo
//
//  Created by Simon on 30/12/2022.
//

import AppKit
import Foundation
import StableDiffusion

protocol ImageGeneratorDelegate {
    func didCompleteStep(step: Int, totalSteps: Int)
}

/// A set of methods that define ways of generating images
protocol ImageGenerator {
    /// Generates images matching the supplied prompt.
    /// - Parameter prompt: A description of the image you want to generate
    /// - Parameter imageCount: The number of images to return
    /// - Returns: An array of images
    ///
    /// Note that you may get fewer than `imageCount` images back. For example, the Stable Diffusion pipeline will remove images that don't pass safety checks.

    func generateImagesForPrompt(prompt: String, imageCount: Int, delegate: ImageGeneratorDelegate?) async throws -> [CGImage]
}

extension StableDiffusionPipeline: ImageGenerator {
    func generateImagesForPrompt(prompt: String, imageCount: Int = 1, delegate: ImageGeneratorDelegate? = nil) async throws -> [CGImage] {
        do {
            let seed = UInt32.random(in: 0...UInt32.max)
            let images = try self.generateImages(prompt:prompt, imageCount: imageCount, seed: seed, progressHandler: { progress in
                DispatchQueue.main.async {
                    delegate?.didCompleteStep(step: progress.step, totalSteps: progress.stepCount)
                }
                return true
            })
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

/// A dummy image generator that returns images from the app's asset catalog. Useful for testing on non-Apple Silicon devices.
struct LocalImageGenerator: ImageGenerator {
    func generateImagesForPrompt(prompt: String, imageCount: Int = 1, delegate: ImageGeneratorDelegate? = nil) async throws -> [CGImage] {
        guard let image = NSImage(named: "sample-image")?.cgImage(forProposedRect: nil, context: .current, hints: nil) else {
            return []
        }
        return [image]
    }
}

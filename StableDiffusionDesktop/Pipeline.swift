//
//  Pipeline.swift
//  StableDiffusionDesktop
//
//  Created by Simon Whitaker on 08/01/2023.
//

import CoreML
import Foundation
import StableDiffusion

func getPipeline(resourceURL: URL) async throws -> StableDiffusionPipeline {
    // I was seeing random errors that mentioned ANE when instantiating the pipeline on MacOS. ANE is Apple Neural Engine. Setting a configuration with computeUnits of .cpuAndGPU prevents this code from running on the neural engine. See also the discussion here: https://github.com/huggingface/swift-coreml-diffusers/blob/2bdfcc593d4daeaefa07e21d681a14e7373c4552/Diffusion/ModelInfo.swift#L36
    let configuration = MLModelConfiguration()
    configuration.computeUnits = isRunningOnMac ? .cpuAndGPU : .cpuAndNeuralEngine

    return try await withCheckedThrowingContinuation { continuation in
        DispatchQueue.global().async {
            do {
                let _pipeline = try StableDiffusionPipeline(resourcesAt: resourceURL, configuration: configuration, disableSafety: true, reduceMemory: !isRunningOnMac)

                DispatchQueue.main.async {
                    continuation.resume(returning: _pipeline)
                }
            } catch {
                DispatchQueue.main.async {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

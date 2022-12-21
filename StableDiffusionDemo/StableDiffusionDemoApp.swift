//
//  StableDiffusionDemoApp.swift
//  StableDiffusionDemo
//
//  Created by Simon on 14/12/2022.
//

import SwiftUI

@main
struct StableDiffusionDemoApp: App {
    @StateObject private var modelData = ModelData()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(modelData)
        }
    }
}

//
//  StableDiffusionMobileApp.swift
//  StableDiffusionMobile
//
//  Created by Simon Whitaker on 08/01/2023.
//

import SwiftUI

@main
struct StableDiffusionMobileApp: App {
    @StateObject private var modelData = ModelData()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(modelData)
        }
    }
}

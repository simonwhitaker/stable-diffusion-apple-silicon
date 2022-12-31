//
//  StableDiffusionDesktopApp.swift
//  StableDiffusionDesktop
//
//  Created by Simon Whitaker on 31/12/2022.
//

import SwiftUI

@main
struct StableDiffusionDesktopApp: App {
    @StateObject private var modelData = ModelData()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(modelData)
        }
    }
}



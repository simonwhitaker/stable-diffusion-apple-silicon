//
//  LoadingModelView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 29/12/2022.
//

import SwiftUI

struct LoadingModelsView: View {
    var body: some View {
        VStack {
            ProgressView {
                Text("Waking the AI...")
            }
        }
    }
}

struct LoadingModelsView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingModelsView()
    }
}

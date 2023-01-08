//
//  LoadingModelView.swift
//  StableDiffusionDemo
//
//  Created by Simon on 29/12/2022.
//

import SwiftUI

struct LoadingModelsView: View {
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        VStack(spacing: 12.0) {
            Spacer()
            ProgressView {
                Text("Waking the AI...")
            }
            Text("\(modelData.localModelMetadata()?.version ?? "Unknown model version")")
                .font(.caption2)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct LoadingModelsView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingModelsView()
    }
}

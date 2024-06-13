//
//  LiveTextView.swift
//  Recognize_SymbolsPOC
//
//  Created by João Bruno Rodrigues on 13/06/24.
//

import Foundation
import SwiftUI
import VisionKit

@MainActor
struct LiveTextView: UIViewRepresentable {
    
    let image: UIImage
    let imageView = LiveTextImageView()     // The data scanner is available on devices with the A12 Bionic chip and later.
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    func makeUIView(context: Context) -> some UIView {
        imageView.image = image
        imageView.addInteraction(interaction)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let image = imageView.image else { return }
        Task { @MainActor in
            let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode, .visualLookUp])
            do {
                let analysis = try await analyzer.analyze(image, configuration: configuration)
                interaction.analysis = analysis
                interaction.preferredInteractionTypes = .visualLookUp
//                interaction.preferredInteractionTypes = .automatic
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

class LiveTextImageView: UIImageView {
    
    override var intrinsicContentSize: CGSize {
        .zero
    }
}

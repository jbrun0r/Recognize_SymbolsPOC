//
//  ScannerView.swift
//  Recognize_SymbolsPOC
//
//  Created by João Bruno Rodrigues on 13/06/24.
//

import Foundation
import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    
    @Binding var shouldCapturePhoto: Bool
    @Binding var capturedPhoto: IdentifiableImage?
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    
//    let recognizedDataTypes:Set<DataScannerViewController.RecognizedDataType> = [
//        .text(textContentType: .URL),
//        .barcode(symbologies: [.qr])
//    ]
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .fast,                    // *
            recognizesMultipleItems: true,          // *
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
//            isGuidanceEnabled: true                 // *
//            isPinchToZoomEnabled: true
        )
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
        
        if shouldCapturePhoto {
            capturePhoto(viewController: uiViewController)
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
        uiViewController.dismiss(animated: true)
    }
    
    private func capturePhoto(viewController: DataScannerViewController) {
        Task { @MainActor in
            do {
                let photo = try await viewController.capturePhoto()
                self.capturedPhoto = .init(image: photo)
            }
            catch {
                print(error.localizedDescription)
            }
            self.shouldCapturePhoto = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($recognizedItems)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var recognizedItems: [RecognizedItem]
        
        init(_ recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems     // "self._" accesses the underlying field
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("didTapOn \(item)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)        // The vibration
            
            recognizedItems.append(contentsOf: addedItems)      // Add new recognized items
            
            print("\n\ndidAddItems:\n\(allItems)\n\n")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter { item in !removedItems.contains(where: {$0.id == item.id}) }
            
            print("\n\ndidRemove:\n\(removedItems)\n\n")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("\n\nbecameUnavailableWithError:\n\(error.localizedDescription)\n\n")
        }
    }
}

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

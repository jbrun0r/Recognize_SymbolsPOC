//
//  AppViewModel.swift
//  Recognize_SymbolsPOC
//
//  Created by João Bruno Rodrigues on 13/06/24.
//

import Foundation
import SwiftUI
import VisionKit
import AVKit

@MainActor
final class AppViewModel: ObservableObject {
    
    @Published var scannerAccessStatus:ScannerAccessStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .text
    @Published var textContentType: DataScannerViewController.TextContentType?
    
    @Published var shouldCapturePhoto = false
    @Published var capturedPhoto: IdentifiableImage? = nil
    
    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    
    var itemCountText: String {
        if !recognizedItems.isEmpty {
            return "Recognized \(recognizedItems.count) item\(recognizedItems.count == 1 ? "" : "s")"
        }
        
        return "Scanning..."
    }
    
    // The data scanner is available on devices with the A12 Bionic chip and later.
    private var scannerAvailable:Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestScannerAccess() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            scannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            scannerAccessStatus = scannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
        case .restricted, .denied:
            scannerAccessStatus = .cameraNotAvailable
            
        case .notDetermined:
            let granted:Bool = await AVCaptureDevice.requestAccess(for: .video)
            
            if granted {
                scannerAccessStatus = scannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                scannerAccessStatus = .cameraAccessNotGranted
            }
        
        default: break
            
        }
    }
}

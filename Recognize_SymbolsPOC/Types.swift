//
//  Enums.swift
//  Recognize_SymbolsPOC
//
//  Created by João Bruno Rodrigues on 13/06/24.
//

import Foundation

enum ScannerAccessStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable       // The data scanner is available on devices with the A12 Bionic chip and later.
    case scannerNotAvailable
}


enum ScanType {
    case barcode, text
}

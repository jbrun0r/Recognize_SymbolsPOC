//
//  Recognize_SymbolsPOCApp.swift
//  Recognize_SymbolsPOC
//
//  Created by João Bruno Rodrigues on 13/06/24.
//

import SwiftUI

@main
struct Recognize_SymbolsPOCApp: App {
    
    @StateObject private var vm = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(vm)
                .task {
                    await vm.requestScannerAccess()
                }
        }
    }
}

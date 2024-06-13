//
//  AppView.swift
//  Recognize_SymbolsPOC
//
//  Created by João Bruno Rodrigues on 13/06/24.
//

import SwiftUI

struct AppView: View {
    
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        switch vm.scannerAccessStatus {
        case .notDetermined:
            Text("Scanner not determined")
        case .cameraAccessNotGranted:
            Text("Scanner access not granted")
        case .cameraNotAvailable:
            Text("Scanner not available")
        case .scannerAvailable:
            ScannerAvailableView
        case .scannerNotAvailable:
            Text("Scanner not available")
        }
    }
    
    private var ScannerAvailableView: some View {
        LiveScanner
            .ignoresSafeArea()
            .background(Color.gray.opacity(0.3))
            .sheet(isPresented: .constant(true)){
                ContentView
                    .background(.ultraThinMaterial)
                    .presentationDetents([.medium, .fraction(0.15)])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
                    .disabled(vm.capturedPhoto != nil)
                    .onAppear {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let controller = windowScene.windows.first?.rootViewController?.presentedViewController else {
                            return
                        }
                        controller.view.backgroundColor = .clear
                    }
                    .sheet(item: $vm.capturedPhoto) { photo in
                        ZStack(alignment: .topTrailing) {
                            LiveTextView(image: photo.image)
                            Button {
                                vm.capturedPhoto = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                            }
                            .foregroundColor(.white)
                            .padding([.trailing, .top])
                            
                        }
                        .edgesIgnoringSafeArea(.bottom)
                    }
            }
    }
    
    @ViewBuilder
    private var LiveScanner: some View {
        if let capturedPhoto = vm.capturedPhoto {
            Image(uiImage: capturedPhoto.image)
                .resizable()
                .scaledToFit()
        } else {
            ScannerView(
                shouldCapturePhoto: $vm.shouldCapturePhoto,
                capturedPhoto: $vm.capturedPhoto,
                recognizedItems: $vm.recognizedItems,
                recognizedDataType: vm.recognizedDataType)
        }
    }
    
    private var ContentView: some View {
        VStack {
            VStack {
//                Picker("Data type", selection: $vm.scanType) {
//                    Text("Barcode").tag(ScanType.barcode)
//                    Text("Text").tag(ScanType.text)
//                }
//                .pickerStyle(.segmented)
//                .padding(.top)
                
                HStack {
                    Text(vm.itemCountText).padding(.top)
                    Spacer()
                    Button {
                        vm.shouldCapturePhoto = true
                    } label: {
                        Image(systemName: "camera")
                            .imageScale(.large)
                            .padding(.top)
                    }
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(vm.recognizedItems) { item in
                        switch item {
                            
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknown")
                            
                        case .text(let text):
                            Text(text.transcript)
                            
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

//#Preview {
//    AppView()
//}

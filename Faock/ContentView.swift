//
//  ContentView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewStep = 0
    var body: some View {
        if viewStep == 0 {
            Home(viewStep: $viewStep)
        } else if viewStep == 1 {
            Game(viewStep: $viewStep)
        }
    }
}

#Preview {
    @ObservedObject var appStorage = AppStorageManager.shared
    return ContentView()
        .environmentObject(appStorage)
}

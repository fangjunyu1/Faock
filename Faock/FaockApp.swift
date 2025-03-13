//
//  FaockApp.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

@main
struct FaockApp: App {
    @StateObject private var appStorage = AppStorageManager.shared  // 共享实例
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appStorage)
        }
    }
}

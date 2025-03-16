//
//  FaockApp.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

@main
struct FaockApp: App {
    @StateObject var iapManager = IAPManager.shared
    @StateObject private var appStorage = AppStorageManager.shared  // 共享实例
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await iapManager.loadProduct()   // 加载产品信息
                    await iapManager.checkAllTransactions()  // 先检查历史交易
                    await iapManager.handleTransactions()   // 加载内购交易更新
                }
                .environmentObject(appStorage)
                .environmentObject(iapManager)
        }
    }
}

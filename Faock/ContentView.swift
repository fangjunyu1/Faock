//
//  ContentView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewStep = 0
    @State private var selectedTab = 0
    // let paintingNameList = ["蒙娜丽莎","呐喊","向日葵","戴珍珠耳环的少女","星空","最后的晚餐","拾穗者","梵高自画像","记忆的永恒","睡莲","抱银貂的女子"]
    // 模式名称
    let modelNames = ["Sinking elimination","Three Identical Blocks","World famous paintings","Slope Blocks","Classic elimination","Football Hot Zone"]
    let paintingMaxNum = 11
    var body: some View {
        if viewStep == 0 {
            Home(viewStep: $viewStep,selectedTab: $selectedTab,paintingMaxNum:paintingMaxNum,modelNames:modelNames)
        } else if viewStep == 1 {
            Game(viewStep: $viewStep,selectedTab: $selectedTab,paintingMaxNum:paintingMaxNum,modelNames:modelNames)
        }
    }
}

#Preview {
//        if let bundleID = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundleID)
//        }
    ContentView()
        .environmentObject(IAPManager.shared)
        .environmentObject(AppStorageManager.shared)
        .environmentObject(SoundManager.shared)
//        .environment(\.locale, .init(identifier: "en")) // 设置其他语言
}

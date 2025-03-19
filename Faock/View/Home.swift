//
//  Home.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var appStorage: AppStorageManager  // 通过 EnvironmentObject 注入
    @Environment(\.colorScheme) var colorScheme
    @Binding var viewStep: Int
    @Binding var selectedTab: Int
    @State private var isSettingView = false
    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $selectedTab) {
                    Image("0")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 380)
                        .shadow(radius: 10,x: 0,y: 10)
                        .tag(0) // 给每个选项卡一个标记
                    
                    Image("1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 380)
                        .shadow(radius: 10,x: 0,y: 10)
                        .tag(1) // 给每个选项卡一个标记
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                Spacer().frame(height: 100)
                Button(action: {
                    // 跳转到游戏视图
                    viewStep = 1
                    // 增加游戏场次
                    appStorage.GameSessions += 1
                }, label: {
                    Text("Start the game")
                        .fontWeight(.bold)
                        .frame(width: 280, height: 64)
                        .foregroundColor(.white)
                        .background(colorScheme == .light ?  Color(hex:"2F438D") : .gray)
                        .cornerRadius(6)
                })
            }
            .navigationTitle("Faock")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isSettingView) {
                SettingView()
            }
            .toolbar {
                // 图标
                ToolbarItem(placement: .topBarLeading) {
                    Image(colorScheme == .light ? "icon2" : "icon4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                }
                // 设置
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                            isSettingView = true
                    }, label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(colorScheme == .light ? Color(hex:"2F438D") : .white)
                    })
                }
            }
        }
        .navigationViewStyle(.stack) // 让 macOS 也变成单个视图
    }
}

#Preview {
    Home(viewStep: .constant(1), selectedTab: .constant(0))
        .environmentObject(AppStorageManager.shared)
}

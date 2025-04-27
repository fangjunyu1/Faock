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
    @State private var isMasterpieceView = false
    
    let paintingMaxNum: Int     // 最大画作数量
    let modelNames:[String]
    
    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $selectedTab) {
                    ForEach(0..<modelNames.count) {item in
                        VStack {
                            Image("\(item)")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 380)
                                .shadow(radius: 10,x: 0,y: 10)
                                .tag(item) // 给每个选项卡一个标记
                            Spacer().frame(height: 30)
                            Text(LocalizedStringKey(modelNames[item]))
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(.vertical,5)
                                .padding(.horizontal,10)
                                .background(.gray)
                                .cornerRadius(10)
                                .background {
                                    // 世界名画模式，新增画廊
                                    if item == 2 {
                                        Button(action: {
                                            isMasterpieceView = true
                                            print("点击了画廊按钮")
                                        }, label: {
                                            Image(systemName: "paintpalette.fill")
                                                .foregroundColor(Color(hex: "2F438D"))
                                                .padding(.leading, 250)
                                        })
                                    }
                                }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .onAppear {
                    if colorScheme == .light {
                        UIPageControl.appearance().currentPageIndicatorTintColor = .black // 当前页指示器为黑色
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3) // 其他页指示器半透明黑色
                    }
                }
                .frame(height: 550)
                Spacer().frame(height: 30)
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
                Spacer()
            }
            .navigationTitle("Faock")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isSettingView) {
                SettingView()
            }
            .sheet(isPresented: $isMasterpieceView, content: {
                MasterpieceView(paintingMaxNum:paintingMaxNum)
            })
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
    Home(viewStep: .constant(1), selectedTab: .constant(0), paintingMaxNum: 11, modelNames: ["Sinking elimination","Three Identical Blocks","World famous paintings","Slope Blocks","Classic elimination"])
        .environmentObject(AppStorageManager.shared)
}

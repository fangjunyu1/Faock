//
//  ManageGameDataViews.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/13.
//

import SwiftUI

struct ManageGameDataViews: View {
    
    @EnvironmentObject var appStorage: AppStorageManager  // 通过 EnvironmentObject 注入
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showAlert: Bool = false
    var body: some View {
        
        NavigationView {
            
            GeometryReader { geo in
                var width = geo.frame(in: .global).width
                var height = geo.frame(in: .global).height
                ScrollView {
                    // 留白
                    Spacer().frame(height: 30)
                    // 最高分数
                    HStack {
                        // 图标
                        // 图标
                        Rectangle()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(hex: "BD27B1"))
                            .cornerRadius(4)
                            .overlay {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.white)
                            }
                        
                        Spacer().frame(width: 20)
                        Text("Highest score")
                        Spacer()
                        Text("\(appStorage.HighestScore)")
                        Spacer().frame(width: 20)
                    }
                    .padding(10)
                    .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                    .cornerRadius(10)
                    .tint(colorScheme == .light ? .black : .white)
                    
                    Spacer().frame(height: 16)
                    
                    // 游戏场次
                    HStack {
                        // 图标
                        Rectangle()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(hex: "2799BD"))
                            .cornerRadius(4)
                            .overlay {
                                Image(systemName: "flag.checkered.2.crossed")
                                    .foregroundColor(.white)
                                    .font(.footnote)
                            }
                        Spacer().frame(width: 20)
                        Text("Game times")
                        Spacer()
                        Text("\(appStorage.GameSessions)")
                        Spacer().frame(width: 20)
                    }
                    .padding(10)
                    .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                    .cornerRadius(10)
                    .tint(colorScheme == .light ? .black : .white)
                    
                    Spacer().frame(height: 16)
                    
                    Button(action: {
                        showAlert = true
                    }, label: {
                        Text("Reset all game data")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    })
                    .alert("Reset all game data",isPresented: $showAlert) {
                        Button("Confirm",role: .destructive) {
                            appStorage.HighestScore = 0
                            appStorage.GameSessions = 0
                        }
                    }
                    // 底部留白
                    Spacer().frame(height: 100)
                }
                .frame(width: width * 0.9)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(colorScheme == .light ? Color(hex: "E9E9E9") : .black)
            }
        }
        .navigationTitle("Manage game data")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack) // 让 macOS 也变成单个视图
    }
}

#Preview {
    @ObservedObject var appStorage = AppStorageManager.shared
    return ManageGameDataViews()
        .environmentObject(appStorage)
}

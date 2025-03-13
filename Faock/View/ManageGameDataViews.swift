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
                        Image(systemName: "chevron.right")
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
                        Image(systemName: "chevron.right")
                    }
                    .padding(10)
                    .background(colorScheme == .light ? .white : Color(hex:"1F1F1F"))
                    .cornerRadius(10)
                    .tint(colorScheme == .light ? .black : .white)
                    
                    Spacer().frame(height: 16)
                    
                    Button(action: {
                        
                    }, label: {
                        Text("Reset all game data")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    })
                    // 底部留白
                    Spacer().frame(height: 100)
                }
                .frame(width: width * 0.9)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Manage game data")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Return")
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                        })
                    }
                }
                .background(colorScheme == .light ? Color(hex: "E9E9E9") : .black)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ManageGameDataViews()
}

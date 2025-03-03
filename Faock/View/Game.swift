//
//  Game.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

struct Game: View {
    @Binding var viewStep: Int
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .toolbar {
                // 标题
                ToolbarItem(placement: .principal) {
                    Text("Sinking elimination")
                        .foregroundColor(Color(hex: "2F438D")) // 确保 Color(hex:) 已实现
                        .font(.headline)
                }
                // 首页
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewStep = 0
                    }, label: {
                        Image(systemName: "house")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(hex: "2F438D"))
                    })
                }
                // 设置
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(Color(hex:"2F438D"))
                    })
                }
            }
        }
    }
}

#Preview {
    Game(viewStep: .constant(1))
}

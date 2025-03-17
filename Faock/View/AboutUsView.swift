//
//  AboutUsView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/13.
//

import SwiftUI

struct AboutUsView: View {
    @Environment(\.layoutDirection) var layoutDirection
    @EnvironmentObject var appStorage: AppStorageManager  // 通过 EnvironmentObject 注入
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                var width = geo.frame(in: .global).width
                var height = geo.frame(in: .global).height
                ScrollView(showsIndicators: false) {
                    LottieView(filename: "developer")
                        .frame(width: 300,height: 300)
                    Text("Who are we?")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer().frame(height: 20)
                    VStack(alignment: .leading) {
                       Text("    ") + Text("Hello, I am Fang Junyu, from Rizhao, Shandong Province, China.")
                        Text("    ") + Text("This is the second application I developed, or to be more precise, the first game. The idea of ​​this game comes from Blockdoku of Easybrain.")
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    Spacer().frame(height: 20)
                    Image("Blockdoku")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                    Spacer().frame(height: 20)
                    VStack(alignment: .leading) {
                        Text("    ") + Text("Because I liked playing Blockdoku very much before, the gameplay is simple, so I came up with the idea of ​​developing a similar game.")
                        Text("    ") + Text("The gameplay of this game is Tetris + Sudoku board. The existing gameplay is to eliminate the blocks downwards when eliminating rows and columns, and there are also ways to expand the existing gameplay and add skins.")
                        Text("    ") + Text("Finally, I hope this game can bring you enough fun, and I also hope that you can support us through in-app purchases.")
                        Text("    ") + Text("Thank you for reading and playing.")
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    Spacer().frame(height: 30)
                }
                .frame(width: width * 0.9)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(colorScheme == .light ? Color(hex: "E9E9E9") : .black)
            }
        }
        .navigationTitle("About us")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack) // 让 macOS 也变成单个视图
    }
}

#Preview {
    AboutUsView()
//        .environment(\.locale, .init(identifier: "ar")) // 设置为阿拉伯语
}

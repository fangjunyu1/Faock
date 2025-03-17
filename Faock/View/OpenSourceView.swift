//
//  OpenSourceView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/15.
//

import SwiftUI

struct OpenSourceView: View {
    @EnvironmentObject var appStorage: AppStorageManager  // 通过 EnvironmentObject 注入
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            
            GeometryReader { geo in
                var width = geo.frame(in: .global).width
                var height = geo.frame(in: .global).height
                ScrollView(showsIndicators: false) {
                    Spacer().frame(height: 30)
                    Text("Let the code be exposed to the sun")
                        .fontWeight(.bold)
                        .font(.title3)
                    Spacer().frame(height: 20)
                    Text("    ") + Text("In order to further demonstrate our protection of user privacy, we decided to host the game code as an open source project on GitHub.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    Spacer().frame(height: 20)
                    Image("GitHub")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                        .cornerRadius(10)
                    Spacer().frame(height: 20)
                    Text("Project address")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text("https://github.com/fangjunyu1/Faock")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .tint(.gray)
                    Spacer()
                        .frame(height: 20)
                    Link(destination: URL(string: "https://github.com/fangjunyu1/Faock")!) {
                        Text("GitHub")
                            .fontWeight(.bold)
                            .frame(width: 180,height: 60)
                            .foregroundColor(colorScheme == .light ? .white : .black)
                            .background(colorScheme == .light ? .black : .white)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .frame(width: width * 0.9)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(colorScheme == .light ? Color(hex: "E9E9E9") : .black)
            }
        }
        .navigationTitle("Open source")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack) // 让 macOS 也变成单个视图
    }
}

#Preview {
    OpenSourceView()
        .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
}

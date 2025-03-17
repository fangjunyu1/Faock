//
//  AcknowledgementsView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/13.
//

import SwiftUI

struct AcknowledgementsView: View {
    
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
                    Text("Thanks to Freepik, LottieFile and px")
                        .fontWeight(.bold)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    Spacer().frame(height: 10)
                    Text("for providing free images, animations and sound effects.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Spacer().frame(height: 20)
                    Image("freepik")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                        .cornerRadius(10)
                    Spacer().frame(height: 20)
                    Image("px")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                        .cornerRadius(10)
                    Spacer().frame(height: 20)
                    Image("lottiefiles")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                        .cornerRadius(10)
                    Spacer().frame(height: 30)
                    Text("Thanks to Easybrain")
                        .fontWeight(.bold)
                        .font(.title3)
                    Spacer().frame(height: 10)
                    Text("for providing game ideas")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer().frame(height: 10)
                    Image("easybrain")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                        .cornerRadius(10)
                }
                .frame(width: width * 0.9)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(colorScheme == .light ? Color(hex: "E9E9E9") : .black)
            }
        }
        .navigationTitle("Acknowledgements")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack) // 让 macOS 也变成单个视图
    }
}


#Preview {
    AcknowledgementsView()
        .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
}

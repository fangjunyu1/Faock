//
//  MasterpieceView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/22.
//

import SwiftUI

struct MasterpieceView: View {
    @EnvironmentObject var appStorage: AppStorageManager  // 通过 EnvironmentObject 注入
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let paintingMaxNum: Int     // 最大画作数量
    let columns = [
            GridItem(.adaptive(minimum: 150, maximum: 200)), // 控制列宽范围
            GridItem(.adaptive(minimum: 150, maximum: 200))
    ]
    
    @State private var selectedImageIndex: Int? = nil    // 选中的图片索引
    
    var body: some View {
        ZStack {
            NavigationView {
                GeometryReader { geo in
                    let width = geo.frame(in: .global).width * 0.9
                    let height = geo.frame(in: .global).height
                    ScrollView(showsIndicators: false) {
                        Spacer().frame(height: 10)
                        LazyVGrid(columns: columns){
                            ForEach(0..<paintingMaxNum) { item in
                                ZStack {
                                    Image("masterpiece\(item)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 115, height: 115)  // 固定大小，避免适应变化
                                    Image("PictureFrame")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 170, height: 170)  // 固定大小，避免适应变化
                                }
                                .padding(.vertical,20)
                                .onTapGesture {
                                    selectedImageIndex = item  // 记录点击的图片索引
                                }
                            }
                        }
                        Spacer().frame(height: 20)
                        Text("The artwork is cropped to fit the chessboard size, which may differ from the original content and dimensions.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: width,alignment: .center)
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                    .navigationTitle("Gallery")
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
                }
            }
            // 放大图片视图（通过 ZStack 叠加）
                        if let index = selectedImageIndex {
                            ZStack {
                                Color.black.opacity(0.8)
                                    .edgesIgnoringSafeArea(.all)
                                    .onTapGesture {
                                        selectedImageIndex = nil  // 关闭图片
                                    }
                                
                                Image("masterpiece\(index)")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                                    .onTapGesture {
                                        selectedImageIndex = nil  // 点击图片关闭
                                    }
                            }
                            .transition(.opacity)
                            .animation(.easeInOut, value: selectedImageIndex)
                        }
        }
    }
}

#Preview {
    MasterpieceView(paintingMaxNum:11)
        .environmentObject(AppStorageManager.shared)
}

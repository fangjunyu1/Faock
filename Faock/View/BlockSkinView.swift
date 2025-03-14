//
//  BlockSkinView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/13.
//

import SwiftUI

struct BlockSkinView: View {
    @EnvironmentObject var appStorage: AppStorageManager  // 通过 EnvironmentObject 注入
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    let columns = [
            GridItem(.adaptive(minimum: 100, maximum: 120)), // 控制列宽范围
            GridItem(.adaptive(minimum: 100, maximum: 120)),
            GridItem(.adaptive(minimum: 100, maximum: 120))
        ]
    var blockSkinCount: [Int] = Array(0..<27)
    var Limitation: Int = 6
    var body: some View {
        NavigationView {
            
            GeometryReader { geo in
                var width = geo.frame(in: .global).width
                var height = geo.frame(in: .global).height
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns){
                        ForEach(blockSkinCount, id: \.self) {item in
                            Image("block\(item)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                                .onTapGesture {
                                    // 如果完成内购，每个图标都可以点击
                                    if appStorage.isInAppPurchase{
                                        appStorage.BlockSkins = "block\(item)"
                                    } else if !appStorage.isInAppPurchase && item < Limitation {
                                        appStorage.BlockSkins = "block\(item)"
                                    }
                                }
                                .overlay {
                                    // 如果没有内购，当显示数量超限时，显示锁定图案
                                    if !appStorage.isInAppPurchase && item >= Limitation {
                                        Rectangle().background(Color(hex: "2F438D"))
                                            .opacity(0.2)
                                            .overlay {
                                                Image(systemName: "lock.fill")
                                                    .foregroundColor(.white)
                                                    .font(.title)
                                            }
                                    } else if "block\(item)" == appStorage.BlockSkins {
                                        Rectangle().background(.gray)
                                            .opacity(0.5)
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.title)
                                                    .padding(10)
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    Spacer().frame(height: 30)
                    Text("Image by freepik")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer().frame(height: 100)
                }
                .frame(width: width * 0.9)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(colorScheme == .light ? Color(hex: "E9E9E9") : .black)
            }
        }
        .navigationTitle("Block skins")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @ObservedObject var appStorage = AppStorageManager.shared
    return BlockSkinView()
        .environmentObject(appStorage)
}

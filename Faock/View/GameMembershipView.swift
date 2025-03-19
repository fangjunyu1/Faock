//
//  GameMembershipView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/13.
//

import SwiftUI

struct GameMembershipView: View {
    
    @EnvironmentObject var appStorage: AppStorageManager  // 通过 EnvironmentObject 注入
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var iapManager: IAPManager
    @State private var endOfWait = false    // 为true时，显示结束等待按钮
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                Image("king3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                Text("Enjoy the charm of the game cube")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                Text("If you are satisfied with our game, we hope you can sponsor us through in-app purchases to help us develop more and better games.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 20)
                // 游戏会员
                VStack(spacing: 0) {
                    HStack {
                        Text("Game membership")
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(1) // 限制文本为一行
                            .minimumScaleFactor(0.5) // 最小缩放比例
                        Spacer()
                        Text("Non-consumable items")
                            .font(.footnote)
                            .lineLimit(1) // 限制文本为一行
                            .minimumScaleFactor(0.5) // 最小缩放比例
                    }
                    Spacer().frame(height: 20)
                    HStack {
                        VStack(alignment: .leading,spacing: 5) {
                            Text("Play all game modes")
                                .fontWeight(.bold)
                                .lineLimit(1) // 限制文本为一行
                                .minimumScaleFactor(0.5) // 最小缩放比例
                            Text("No pop-up ads")
                                .fontWeight(.bold)
                                .lineLimit(1) // 限制文本为一行
                                .minimumScaleFactor(0.5) // 最小缩放比例
                            Text("Enjoy all game skins")
                            .fontWeight(.bold)
                            .lineLimit(1) // 限制文本为一行
                            .minimumScaleFactor(0.5) // 最小缩放比例
                            Text("Get all the rights of the game")
                            .fontWeight(.bold)
                            .lineLimit(1) // 限制文本为一行
                            .minimumScaleFactor(0.5) // 最小缩放比例
                        }
                        .font(.footnote)
                        Spacer()
                        VStack {
                            Image("icon5")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                            Spacer()
                        }
                    }
                    Spacer().frame(height: 20)
                    HStack {
                        if !iapManager.products.isEmpty {
                            
                            Text("\(iapManager.products.first?.displayPrice ?? "N/A")")
                                .lineLimit(1) // 限制文本为一行
                                .minimumScaleFactor(0.5) // 最小缩放比例
                        } else {
                            Text("$ --")
                                .lineLimit(1) // 限制文本为一行
                                .minimumScaleFactor(0.5) // 最小缩放比例
                        }
                        Spacer()
                        if appStorage.isInAppPurchase {
                            Text("Completed purchase")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .light ?  Color(hex: "2F438D") : Color(hex: "1F1F1F"))
                                .frame(width: 180)
                                .padding(.vertical,14)
                                .padding(.horizontal,10)
                                .background(.white)
                                .cornerRadius(10)
                        } else {
                            Button(action: {
                                    if !iapManager.products.isEmpty {
                                        iapManager.loadPurchased = true // 显示加载动画
                                        // 将商品分配给一个变量
                                        let productToPurchase = iapManager.products[0]
                                        // 分开调用购买操作
                                        iapManager.purchaseProduct(productToPurchase)
                                        // 当等待时间超过20秒时，显示结束按钮
                                        Task {
                                            try? await Task.sleep(nanoseconds: 20_000_000_000) // 延迟 20 秒
                                            endOfWait = true
                                        }
                                    } else {
                                        print("products为空")
                                        Task {
                                            await iapManager.loadProduct()   // 加载产品信息
                                        }
                                    }
                            }, label: {
                                Text("Get game membership")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .light ?  Color(hex: "2F438D") : Color(hex: "1F1F1F"))
                                    .frame(width: 180)
                                    .padding(.vertical,14)
                                    .padding(.horizontal,10)
                                    .background(.white)
                                    .cornerRadius(10)
                            })
                        }
                        Spacer()
                    }
                }
                .frame(width: 280)
                .padding(.vertical,16)
                .padding(.horizontal,30)
                .foregroundColor(.white)
                .background(colorScheme == .light ? Color(hex: "2F438D") : Color(hex:"1F1F1F"))
                .cornerRadius(10)
                Spacer().frame(height: 10)
                VStack {
                    Text("Apple will adjust the specific amount of in-app purchases based on the exchange rate/tax of the national currency.")
                    Text("Game membership is permanent and is a non-consumable item.")
                }
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .font(.footnote)
                .padding(.horizontal,18)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .light ? Color(hex: "E9E9E9") : .black)
        }
        .navigationTitle("Game membership")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack) // 让 macOS 也变成单个视图
        .overlay {
            if iapManager.loadPurchased == true {
                ZStack {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                    VStack {
                        // 加载条
                        ProgressView("loading...")
                        // 加载条修饰符
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .background(colorScheme == .dark ? Color(hex: "A8AFB3") : Color.white)
                            .cornerRadius(10)
                            .overlay {
                                // 当等待时间超过10秒时显示结束
                                if endOfWait == true {
                                    Button(action: {
                                        iapManager.loadPurchased = false
                                    }, label: {
                                        Text("End of the wait")
                                            .foregroundStyle(.red)
                                            .frame(width: 100,height: 30)
                                            .background(.white)
                                            .cornerRadius(10)
                                    })
                                    .offset(y:60)
                                }
                            }
                        
                    }
                }
            }
        }
    }
}

#Preview {
    return GameMembershipView()
        .environmentObject(IAPManager.shared)
        .environmentObject(AppStorageManager.shared)
        .environment(\.locale, .init(identifier: "de")) // 设置其他语言
}

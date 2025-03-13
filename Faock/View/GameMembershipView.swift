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
    
    var body: some View {
        NavigationView {
            ScrollView {
                // 顶部留白
                Spacer().frame(height: 30)
                Image("king3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                Text("Enjoy the charm of the game cube")
                    .fontWeight(.bold)
                    .font(.title3)
                    .padding()
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
                        Spacer()
                        Text("Non-consumable items")
                            .font(.footnote)
                    }
                    Spacer().frame(height: 20)
                    HStack {
                        VStack(alignment: .leading,spacing: 5) {
                            Text("Play all game modes")
                                .fontWeight(.bold)
                            Text("No pop-up ads")
                                .fontWeight(.bold)
                            Text("Enjoy all game skins")
                            .fontWeight(.bold)
                            Text("Get all the rights of the game")
                            .fontWeight(.bold)
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
                        Text("$4")
                            .font(.title2)
                        Spacer()
                        Button(action: {
                            
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
            .navigationTitle("Game membership")
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
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GameMembershipView()
}

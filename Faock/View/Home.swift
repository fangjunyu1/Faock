//
//  Home.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

struct Home: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var viewStep: Int
    var body: some View {
        NavigationView {
            VStack {
                Image("3")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 380)
                    .shadow(radius: 10,x: 0,y: 10)
                Spacer().frame(height: 20)
                Text("Image by freepik")
                    .foregroundColor(colorScheme == .light ?  Color(hex:"2F438D") : .gray)
                    .font(.footnote)
                Spacer().frame(height: 100)
                Button(action: {
                    viewStep = 1
                }, label: {
                    Text("Start the game")
                        .fontWeight(.bold)
                        .frame(width: 280, height: 64)
                        .foregroundColor(.white)
                        .background(colorScheme == .light ?  Color(hex:"2F438D") : .gray)
                        .cornerRadius(6)
                })
            }
            .navigationTitle("Faock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 图标
                ToolbarItem(placement: .topBarLeading) {
                    Image(colorScheme == .light ? "icon2" : "icon4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                }
                // 设置
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(colorScheme == .light ? Color(hex:"2F438D") : .white)
                    })
                }
            }
        }
    }
}

#Preview {
    Home(viewStep: .constant(1))
}

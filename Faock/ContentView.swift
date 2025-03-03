//
//  ContentView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image("3")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                Button(action: {
                    
                }, label: {
                    Text("Start the game")
                })
            }
        }
    }
}

#Preview {
    ContentView()
}

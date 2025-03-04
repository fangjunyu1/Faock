//
//  GameGridView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/4.
//

import SwiftUI

struct GameGridView: View {
    var grid: [[Int]]
    var rowCount = 0
    var colCount = 0
    
    init(grid: [[Int]]) {
        self.grid = grid
        self.rowCount = grid.count
        self.colCount = grid.first?.count ?? 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 横向 9 行
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: 0) {
                    // 竖向 9 格
                    ForEach(0..<colCount, id: \.self) { col in
                        // 方格
                        Rectangle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.clear)
                            .border(Color(hex: "C7CDDC"))
                            .overlay {
                                if grid[row][col] == 1  {
                                    Image("block0")
                                        .resizable()
                                        .scaledToFit()
                                } else {
                                    Color.clear
                                }
                            }
                    }
                }
            }
        }
        .overlay {
            ZStack {
                // 边框线
                Rectangle()
                    .stroke(Color(hex: "465963"),lineWidth: 4)
                    .foregroundColor(.clear)
                // 分割 - 横线
                VStack {
                    ForEach(0..<2) { item in
                        if item == 0 { Spacer() }
                        Rectangle()
                            .foregroundColor(Color(hex: "61727A"))
                            .frame(height: 1)
                        Spacer()
                    }
                }
                // 分割 - 竖线
                HStack {
                    ForEach(0..<2) { item in
                        if item == 0 { Spacer() }
                        Rectangle()
                            .foregroundColor(Color(hex: "61727A"))
                            .frame(width: 1)
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    GameGridView(grid: Array(repeating: Array(repeating: 0, count: 9), count: 9))
}

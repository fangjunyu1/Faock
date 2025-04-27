//
//  GameGridView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/4.
//

import SwiftUI

struct GameGridView: View {
    @EnvironmentObject var appStorage: AppStorageManager  // 通过 EnvironmentObject 注入
    @Environment(\.colorScheme) var colorScheme
    var grid: [[Int]]
    var shadowPosition: (row: Int, col: Int)?
    var shadowBlock: Block?
    var rowCount = 0
    var colCount = 0
    var cellSize: CGFloat
    var pendingClearRows: Set<Int>
    var pendingClearColumns: Set<Int>
    var specialEliminationArea:[(Int,Int)] = [] // 特殊消除区域
    
    init(grid: [[Int]],shadowPosition: (row: Int, col: Int)?,shadowBlock: Block?,cellSize: CGFloat,pendingClearRows: Set<Int> = [],
         pendingClearColumns: Set<Int> = []) {
        self.grid = grid
        self.shadowPosition = shadowPosition
        self.shadowBlock = shadowBlock
        self.rowCount = grid.count
        self.colCount = grid.first?.count ?? 0
        self.cellSize = cellSize
        self.pendingClearRows = pendingClearRows
        self.pendingClearColumns = pendingClearColumns
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 横向 9 行
                ForEach(0..<rowCount, id: \.self) { row in
                    HStack(spacing: 0) {
                        // 竖向 9 格
                        ForEach(0..<colCount, id: \.self) { col in
                            // 方格
                            let isPending = pendingClearColumns.contains(col) || pendingClearRows.contains(row)
                            Rectangle()
                                .frame(width: cellSize, height: cellSize)
                                .foregroundColor(.clear)
                                .border(Color(hex: "C7CDDC"))
                                .overlay {
                                    if grid[row][col] == 1  {
                                        Image(colorScheme == .light ? appStorage.BlockSkins : "block1")
                                            .resizable()
                                            .scaledToFit()
                                            .opacity(isPending ? 0.8 : 1)
                                    } else {
                                        Color.clear
                                    }
                                }
                        }
                    }
                }
            }
            
            // 绘制阴影
            
            if let shadow = shadowBlock, let position = shadowPosition {
                VStack(spacing: 0) {
                    // 横向 9 行
                    ForEach(0..<rowCount, id: \.self) { row in
                        HStack(spacing: 0) {
                            // 竖向 9 格
                            ForEach(0..<colCount, id: \.self) { col in
                                let inShadowArea = (row >= position.row && row < position.row + shadow.shape.count) &&
                                (col >= position.col && col < position.col + shadow.shape[0].count)
                                // 在阴影区域内，shadowRow和shadowCol则变成相对位置
                                // 例如row和col为阴影区域的左上角，假设阴影区域为（3，4）
                                // row和col也从（3，4）开始计算
                                // 那么 shadowRow 和 shadowCol 就是 （0，0）
                                // 所以 shadow.shape[shadowRow][shadowCol] = shadow.shape[0，0]
                                // 如果为1，表示有方块
                                let shadowRow = row - position.row
                                let shadowCol = col - position.col
                                let shouldDrawShadow = inShadowArea && shadow.shape[shadowRow][shadowCol] == 1
                                
                                Rectangle()
                                    .frame(width: cellSize, height: cellSize)
                                    .foregroundColor(.clear)
                                    .overlay {
                                        if shouldDrawShadow {
                                            Image(colorScheme == .light ? appStorage.BlockSkins : "block1")
                                                .resizable()
                                                .scaledToFit()
                                                .opacity(colorScheme == .light ? 0.3 : 0.5)
                                        }
                                    }
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
                    .stroke(colorScheme == .light ? Color(hex: "465963") : .gray,lineWidth: 4)
                    .foregroundColor(.clear)
                // 分割 - 横线
                VStack {
                    ForEach(0..<1) { item in
                        if item == 0 { Spacer() }
                        Rectangle()
                            .foregroundColor(Color(hex: "61727A"))
                            .frame(height: 1)
                        Spacer()
                    }
                }
                // 分割 - 竖线
                HStack {
                    ForEach(0..<1) { item in
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
    @ObservedObject var appStorage = AppStorageManager.shared
    GameGridView(grid: [
        [1,0,0,0,1,0,0,0],
        [1,1,1,1,1,1,1,1],
        [1,0,0,0,1,0,0,0],
        [1,0,0,0,1,0,0,0],
        [1,0,0,0,1,0,0,0],
        [1,0,0,0,0,0,0,0],
        [1,0,0,0,0,0,0,0],
        [1,0,0,0,1,0,0,0],
        [1,0,0,0,1,0,0,0],
        [1,0,0,0,1,0,0,0],
        [1,0,0,0,1,0,0,0],
        [1,0,0,0,1,0,0,0]
    ],
                 shadowPosition: (row: 5, col: 3),shadowBlock: Block(shape: [[1,0,1],[1,1,1]]),cellSize: 36,pendingClearRows: [],pendingClearColumns: Set([4]))
    .environmentObject(appStorage)
}

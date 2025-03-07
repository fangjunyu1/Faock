//
//  Game.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

struct Game: View {
    // 定义网格的行列
    @State private var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 9), count: 9)
    @Binding var viewStep: Int
    @State private var GameScore = 0
    @State private var CurrentBlock: [Block?] = []
    @State private var gridOrigin: CGPoint = .zero  // 记录视图左上角坐标
    @State private var locationText: CGPoint = .zero
    
    
    let GestureOffset: CGFloat = 80
    let cellSize: CGFloat = 40  // 需要与网格大小一致
    
    let block = Block(shape: [[1, 1, 1], [0, 1, 0]])
    
    func generateNewBlocks() -> [Block] {
        let blocks = [
            // 横向
            //  单行
            Block(shape: [[1]]),   // 点
            Block(shape: [[1,1]]),   // 两点横
            Block(shape: [[1,1,1]]),   // 三点横
            Block(shape: [[1,1,1,1]]), // 长条形
            // 双行
            Block(shape: [[1,1], [1,1]]), // 正方形
            Block(shape: [[1,1], [0,1]]), // 「 型
            Block(shape: [[1,1], [1,0]]), // 7 型
            Block(shape: [[0,1], [1,1]]), // 」 型
            Block(shape: [[1,0], [1,1]]), // L 型
            // 三行
            Block(shape: [[1,1,1], [0,1,0]]), // T形
            Block(shape: [[0,1,0], [0,1,0], [1,1,1]]),   // ⊥ 型
            Block(shape: [[0,1,0],[1,1,1],[0,1,0]]), // 十字架
            Block(shape: [[1,0,0], [1,0,0], [1,1,1]]), // L形
            Block(shape: [[0,0,1], [0,0,1], [1,1,1]]), // 」 型
            Block(shape: [[1,0,0], [1,1,1], [1,0,0]]), // 卜 型
            Block(shape: [[0,0,1], [1,1,1], [0,0,1]]), // 卜 型，反向
            //            Block(shape: [[1,1,1], [1,0,1], [1,1,1]]), // 口 型
            
            // 竖向
            // 单列
            Block(shape: [[1],[1]]), // 两点竖
            Block(shape: [[1],[1],[1]]), // 三点竖
            Block(shape: [[1],[1],[1],[1]]), // 四点竖
        ]
        return blocks.shuffled().prefix(3).map { $0 }
    }
    
    func placeBlock(_ block: Block, _ start: CGPoint, _ end: CGSize, _ origins: CGPoint, _ indices : Int) {
        print("start:\(start)")
        print("end:\(end)")
        print("origins:\(origins)")
        print("gridOrigin:\(gridOrigin)")
        // y轴：方块到顶点的距离 - 方块到棋盘的 60 - 手势偏移的80 = 第一行
        let CalculateY = origins.y - gridOrigin.y - GestureOffset + end.height
        let row = Int(CalculateY / cellSize)
        // x轴：方块到左侧点的距离 - 方块到棋盘的 60 = 第一列
        let CalculateX = origins.x + end.width
        let col = Int(CalculateX / cellSize)
        print("row:\(row), col: \(col)")
        // 检查 row 和 col 是否有效
        guard row >= 0, col >= 0, row < 9, col < 9 else {
            print("无法放置方块，超出网格边界")
            return
        }
        
        // 检查是否可以放置
        if canPlaceBlock(block, atRow: row, col: col) {
            for r in 0..<block.rows {
                for c in 0..<block.shape[r].count {
                    if block.shape[r][c] == 1 {
                        grid[row + r][col + c] = 1
                    }
                }
            }
            // 计算得分
            GameScore += block.score
            //  放置后，将对应的方块设为 nil
            CurrentBlock[indices] = nil
            // 如果方块列表没有方块，则刷新方块列表
            if CurrentBlock.allSatisfy ({ $0 == nil}) {
                print("当前列表为空，刷新列表")
                CurrentBlock = generateNewBlocks()
                print("CurrentBlock:\(CurrentBlock)")
            }
        } else {
            print("无法放置方块")
        }
    }
    
    // 检查方块是否可以放置
    func canPlaceBlock(_ block: Block, atRow row: Int, col: Int) -> Bool {
        // 遍历当前方块的行数
        for r in 0..<block.shape.count {
            // 遍历当前方块的列数
            for c in 0..<block.shape[r].count {
                // 如果方块对应的格为 1，则进入判断
                if block.shape[r][c] == 1 {
                    // 放置网格的 row 和 col
                    // 假设，定位的坐标为 row = 1，col = 4
                    // 方块为 let shape: [[Int]] = [[0, 1,], [1, 1,]]
                    // 那么，当shape[0][1] == 1 符合条件时,r = 0, c = 1
                    // targetRow = 1 + 0 = 1, targetCol = 4 + 1 = 5
                    // 判断网格的 1，5 是否超过 9 以及是否已经有方块，如果超过 9 或有方块，则返回 false，否则返回 true。
                    let targetRow = row + r
                    let targetCol = col + c
                    if targetRow < 0 || targetRow >= 9 || targetCol < 0 || targetCol >= 9 || grid[targetRow][targetCol] == 1 {
                        return false
                    }
                }
            }
        }
        // 返回 true
        return true
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { globalGeo in
                VStack {
                    // 得分
                    Text("\(GameScore)")
                        .frame(width: 100, height: 36)
                        .foregroundColor(.white)
                        .background(Color(hex: "2F438D"))
                        .cornerRadius(10)
                    Spacer().frame(height: 30)
                    // 背景网格
                    GameGridView(grid:grid)
                        .overlay {
                            GeometryReader { gridGeo in
                                Color.clear.onAppear {
                                    
                                    DispatchQueue.main.async {
                                        let gridPosition = gridGeo.frame(in: .global).origin
                                        print("网格原点 gridPosition: \(gridPosition)")
                                        gridOrigin = gridPosition
                                    }
                                }
                            }
                        }
                    Spacer().frame(height: 30)
                    // 三个随机生成的方块
                    HStack(alignment: .center,spacing: 0) {
                        ForEach(0..<3,id: \.self) {item in
                            ZStack {
                                if CurrentBlock.indices.contains(item), let block = CurrentBlock[item] {
                                    DraggableBlockView(block: block, GestureOffset: GestureOffset) { start, end, geo  in
                                        placeBlock(block, start, end, geo, item)
                                    }
                                } else {
                                    Rectangle()
                                        .opacity(0)
                                }
                            }
                            .frame(width: 115,height: 115)
                        }
                    }
                    .frame(width: 360)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    if CurrentBlock.isEmpty {
                        CurrentBlock = generateNewBlocks()
                    }
                }
                .toolbar {
                    // 标题
                    ToolbarItem(placement: .principal) {
                        Text("Sinking elimination")
                            .foregroundColor(Color(hex: "2F438D")) // 确保 Color(hex:) 已实现
                            .font(.headline)
                    }
                    // 首页
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            viewStep = 0
                        }, label: {
                            Image(systemName: "house")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(hex: "2F438D"))
                        })
                    }
                    // 设置
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "gearshape")
                                .foregroundColor(Color(hex:"2F438D"))
                        })
                    }
                }
            }
        }
    }
}

#Preview {
    Game(viewStep: .constant(1))
}

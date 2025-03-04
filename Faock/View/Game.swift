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
    @State private var CurrentBlock: [Block] = Game.generateNewBlocks()
    let block = Block(shape: [[1, 1, 1], [0, 1, 0]])
    
    static func generateNewBlocks() -> [Block] {
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
    
        func placeBlock(at location: CGPoint) {
    //        let row = Int(location.y / 30)
    //        let col = Int(location.x / 30)
    //
    //        // 检查是否可以放置
    //        if block.canPlace(in: grid, at: row, col: col) {
    //            for r in 0..<block.rows {
    //                for c in 0..<block.shape[r].count {
    //                    if block.shape[r][c] == 1 {
    //                        grid[row + r][col + c] = 1
    //                    }
    //                }
    //            }
    //        }
        }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 得分
                Text("0")
                    .frame(width: 100, height: 36)
                    .foregroundColor(.white)
                    .background(Color(hex: "2F438D"))
                    .cornerRadius(10)
                Spacer().frame(height: 30)
                
                // 背景网格
                GameGridView(grid:grid)
                
                Spacer().frame(height: 30)
                
                // 随机生成的方块
                HStack {
                    ForEach(0..<3) { item in
                        DraggableBlockView(block: CurrentBlock[item]) { dropLocation in
                            print("dropLocation:\(dropLocation)")
                                placeBlock(at: dropLocation)
                        }
                    }
                }
                
                
                Spacer()
            }
            .onAppear {
                if CurrentBlock.isEmpty {
                    CurrentBlock = Game.generateNewBlocks()
                }
                print("CurrentBlock:\(CurrentBlock)")
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

#Preview {
    Game(viewStep: .constant(1))
}

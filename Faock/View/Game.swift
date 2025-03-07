//
//  Game.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

struct Game: View {
    
    @Environment(\.colorScheme) var colorScheme
    // 定义网格的行列
    @State private var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 9), count: 9)
    @Binding var viewStep: Int
    @State private var GameScore = 0
    @State private var CurrentBlock: [Block?] = []
    @State private var gridOrigin: CGPoint = .zero  // 记录视图左上角坐标
    @State private var locationText: CGPoint = .zero
    @State private var shadowPosition: (row: Int, col: Int)? = nil  // 阴影位置
    @State private var shadowBlock: Block? = nil    // 阴影方块
    
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
    
    // 放置方块
    func placeBlock(_ block: Block, _ start: CGPoint, _ end: CGSize, _ origins: CGPoint, _ indices : Int) {
        print("start:\(start)")
        print("end:\(end)")
        print("origins:\(origins)")
        print("gridOrigin:\(gridOrigin)")
        // 计算用户实际触碰的相对位置
        let touchOffsetX = start.x / 2 + origins.x
        let touchOffsetY = start.y / 2 + origins.y
        print("touchOffsetX:\(touchOffsetX)")
        print("touchOffsetY:\(touchOffsetY)")
        // y轴：方块到顶点的距离 - 方块到棋盘的 60 - 手势偏移的80 = 第一行
        let CalculateY = touchOffsetY - gridOrigin.y - GestureOffset + end.height
        let row = Int(CalculateY / cellSize)
        // x轴：方块到左侧点的距离 - 方块到棋盘的 60 = 第一列
        let CalculateX = touchOffsetX + end.width
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
    
    // 显示放置方块的阴影
    func shadowBlock(_ block: Block, _ start: CGPoint, _ end: CGSize, _ origins: CGPoint, _ indices : Int) {
        
        let touchOffsetX = start.x / 2 + origins.x
        let touchOffsetY = start.y / 2 + origins.y
        // y轴：方块到顶点的距离 - 方块到棋盘的 60 - 手势偏移的80 = 第一行
        let CalculateY = touchOffsetY - gridOrigin.y - GestureOffset + end.height
        let row = Int(CalculateY / cellSize)
        // x轴：方块到左侧点的距离 - 方块到棋盘的 60 = 第一列
        let CalculateX = touchOffsetX + end.width
        let col = Int(CalculateX / cellSize)
        print("row:\(row), col: \(col)")
        // 检查 row 和 col 是否有效
        guard row >= 0, col >= 0, row < 9, col < 9 else {
            print("无法放置方块，超出网格边界")
            return
        }
        // 检查是否可以放置
        if canPlaceBlock(block, atRow: row, col: col) {
            print("可以放置，绘制方块阴影")
            shadowPosition = (row, col)
            shadowBlock = block
        } else {
            shadowPosition = nil
            shadowBlock = nil
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
    
    // 消除整行/整列的方块
    func clearFullRowsAndColumns() {
        var newGrid = grid
        // 找到需要消除的行
            var rowsToClear: Set<Int> = []
            for row in 0..<9 {
                if newGrid[row].allSatisfy({ $0 == 1 }) {
                    rowsToClear.insert(row)
                }
            }
        // 找到需要消除的列
            var colsToClear: Set<Int> = []
            for col in 0..<9 {
                if (0..<9).allSatisfy({ newGrid[$0][col] == 1 }) {
                    colsToClear.insert(col)
                }
            }
        
        
        print("需要清除的行: \(rowsToClear.sorted())")
        
        // 清除整行
            for row in rowsToClear {
                newGrid[row] = Array(repeating: 0, count: 9)
            }

            // 清除整列
            for col in colsToClear {
                for row in 0..<9 {
                    newGrid[row][col] = 0
                }
            }
        
        
        // 奖励消除积分
        let EliminationRewards = rowsToClear.count * 10 + colsToClear.count * 10
        // 更新积分
        GameScore += EliminationRewards
        
        
        // 处理方块下落：上面的行向下移动
        // 例如rowsToClear为 [2,5,3],sorted()为[2,3,5], reversed()为[5,3,2]
            for row in rowsToClear.sorted().reversed() { // 从下往上处理
                print("row:\(row)")
                // 假如 row 只是3，那么reversed()为 [3,2,1]，所以先消除 row 为3的行
                for r in (1...row).reversed() {
                    print("r:\(r)")
                    // newGrid[3] = newGrid[2]
                    // newGrid[2] = newGrid[1]
                    // newGrid[1] = newGrid[0]
                    // 最好将第0行消除到第1行
                    newGrid[r] = newGrid[r - 1] // 当前行变成上一行
                }
                // 新增空行填充到第0行。
                newGrid[0] = Array(repeating: 0, count: 9) // 顶部填充空行
            }

            grid = newGrid
    }
    var body: some View {
        NavigationStack {
            GeometryReader { globalGeo in
                VStack {
                    // 得分
                    Text("\(GameScore)")
                        .frame(width: 100, height: 36)
                        .foregroundColor(.white)
                        .background(colorScheme == .light ? Color(hex: "2F438D") : .gray)
                        .cornerRadius(10)
                    Spacer().frame(height: 30)
                    // 背景网格
                    GameGridView(grid: grid, shadowPosition: shadowPosition, shadowBlock: shadowBlock)
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
                    HStack(alignment: .center,spacing: 10) {
                        ForEach(0..<3,id: \.self) {item in
                            ZStack {
                                if CurrentBlock.indices.contains(item), let block = CurrentBlock[item] {
                                    DraggableBlockView(block: block, GestureOffset: GestureOffset,
                                                       onDrag :{ start, end, geo  in
                                        print("移动中")
                                        shadowBlock(block, start, end, geo, item)
                                    },
                                                       onDrop: {start, end, geo  in
                                        placeBlock(block, start, end, geo, item)
                                        // 放置方块
                                        shadowPosition = nil
                                        shadowBlock = nil
                                        // 消除行、列的方块
                                        clearFullRowsAndColumns()
                                    })
                                } else {
                                    Rectangle()
                                        .opacity(0)
                                }
                            }
                            .frame(width: 120,height: 120)
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
                            .foregroundColor(colorScheme == .light ? Color(hex:"2F438D") : .white)
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
                                .foregroundColor(colorScheme == .light ? Color(hex:"2F438D") : .white)
                        })
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
}

#Preview {
    Game(viewStep: .constant(1))
}

//
//  Game.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI
import StoreKit

struct Game: View {
    
    @EnvironmentObject var appStorage: AppStorageManager  // 通过 EnvironmentObject 注入
    @EnvironmentObject var sound: SoundManager  // 通过 Sound 注入
    @Environment(\.colorScheme) var colorScheme
    
    // 定义网格的行列
    @State private var grid: [[Int]]
    // 定义“世界名画”模式的名画
    @State private var masterpieceGrid: [[Int]]
    
    @Binding var viewStep: Int
    @Binding var selectedTab: Int
    
    @State private var GameScore = 0
    @State private var CurrentBlock: [Block?] = []  // 当前方块
    @State private var CurrentBlockStatus: [Bool] = Array(repeating: true, count: 3)   // 方块透明度
    @State private var gridOrigin: CGPoint = .zero  // 记录视图左上角坐标
    @State private var locationText: CGPoint = .zero
    @State private var shadowPosition: (row: Int, col: Int)? = nil  // 阴影位置
    @State private var shadowBlock: Block? = nil    // 阴影方块
    @State private var GameOver = false
    @State private var shakeOffset: CGFloat = 0
    @State private var GameOverZoomAnimation = false
    @State private var isSettingView = false
    @State private var CompletedFamousPainting = false
    // 分数更新动画
    let incrementStep = 1  // 每次增加多少
    let animationSpeed = 0.05  // 速度（秒）
    
    let GestureOffset: CGFloat = 80
    let cellSize: CGFloat = 40  // 需要与网格大小一致
    
    let rowCount:Int    //  行
    let colCount:Int    // 列
    //    let block = Block(shape: [[1, 1, 1], [0, 1, 0]])
    
    let paintingMaxNum: Int     // 最大画作数量
    let modelNames:[String]

    // 待消除的行列
    @State var pendingClearRows: Set<Int> = []
    @State var pendingClearColumns: Set<Int> = []
    
    // 仅用于标记“世界名画”名称
    @State private var paintingNumber = 0
    @State private var windowSize: CGSize = .zero
    @State private var GameOverButton = false
    @State private var ShowHighestScore = false
    init(viewStep: Binding<Int>,selectedTab:Binding<Int>, rowCount: Int = 10, colCount: Int = 8,paintingMaxNum: Int,modelNames: [String]) {
        self._viewStep = viewStep
        self._selectedTab = selectedTab
        self.rowCount = rowCount
        self.colCount = colCount
        _grid = State(initialValue: Array(repeating: Array(repeating: 0, count: colCount), count: rowCount))
        
        // 设置画作
        paintingNumber = Int.random(in: 0..<paintingMaxNum)
        // 设置名画
        _masterpieceGrid = State(initialValue: Array(repeating: Array(repeating: 0, count: colCount), count: rowCount))
        // 画作数量
        self.paintingMaxNum = paintingMaxNum
        self.modelNames = modelNames
    }
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
        let slopeBlocks = [
            // 单点
            Block(shape: [[1]]),
            // 两行方格
            Block(shape: [[0,1],[1,0]]),
            Block(shape: [[1,0],[0,1]]),
            Block(shape: [[0,1,0],[1,0,1]]),
            Block(shape: [[1,0,1],[0,1,0]]),
            Block(shape: [[1,0,1,0],[0,1,0,1]]),
            Block(shape: [[0,1,0,1],[1,0,1,0]]),
            // 三行方格
            Block(shape: [[1,0,0],[0,1,0],[0,0,1]]),
            Block(shape: [[1,0],[0,1],[1,0]]),
            Block(shape: [[0,0,1],[0,1,0],[1,0,0]]),
            Block(shape: [[0,1],[1,0],[0,1]]),
            Block(shape: [[0,1,0],[1,0,1],[0,1,0]]),
            Block(shape: [[1,0,1],[0,1,0],[1,0,1]]),
            Block(shape: [[1,0,1],[0,1,0],[1,0,0]]),
            Block(shape: [[1,0,1],[0,1,0],[0,0,1]]),
            Block(shape: [[0,0,1],[0,1,0],[1,0,1]]),
            Block(shape: [[1,0,0],[0,1,0],[1,0,1]]),
            // 四行方格
            Block(shape: [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]),
            Block(shape: [[0,0,0,1],[0,0,1,0],[0,1,0,0],[1,0,0,0]]),
            // 复杂方格

        ]
        if selectedTab == 0 {
            return blocks.shuffled().prefix(3).map { $0 }
        } else if selectedTab == 1 {
            // 生成3个相同方块
            if let block = blocks.randomElement() {
                return Array(repeating: block, count: 3)  // 重复3次
            } else {
                return []
            }
        } else if selectedTab == 3 {
            // 生成3个相同方块
            return slopeBlocks.shuffled().prefix(3).map { $0 }
        } else {
            return blocks.shuffled().prefix(3).map { $0 }
        }
    }
    
    
    // 放置方块
    func placeBlock(_ block: Block, _ start: CGPoint, _ end: CGSize, _ origins: CGPoint, _ indices : Int) {
        guard let (col,row) = calculateRowCol(touchOffsetX: origins.x, touchOffsetY: origins.y, end: end) else {
            return
        }
        print("row:\(row), col: \(col)")
        // 检查 row 和 col 是否有效
        guard row >= 0, col >= 0, row < rowCount, col < colCount else {
            print("无法放置方块，超出网格边界")
            return
        }
        
        // 检查是否可以放置
        let isCanPlaceBlock =  canPlaceBlock(block, atRow: row, col: col)
        print("当canPlaceBlock方法为true时，执行棋盘遍历")
        if isCanPlaceBlock{
            print("进入棋盘遍历")
            for r in 0..<block.rows {
                for c in 0..<block.shape[r].count {
                    if block.shape[r][c] == 1 {
                        grid[row + r][col + c] = 1
                        if selectedTab == 2 {
                            masterpieceGrid[row + r][col + c] = 1
                        }
                    }
                }
            }
            print("棋盘遍历完成")
            // 播放放置方块音效
            print("播放音效")
            if appStorage.Music {
                sound.playSound(named: "blockSound")
            }
            // 计算得分
            print("计算得分")
            increaseScore(to: GameScore + block.score)
            //  放置后，将对应的方块设为 nil
            print("设置CurrentBlock[indices]为nil")
            CurrentBlock[indices] = nil
            // 如果方块列表没有方块，则刷新方块列表
            print("判断当前方块列表有无方块")
            let isCurrentBlock = CurrentBlock.allSatisfy ({ $0 == nil})
            if isCurrentBlock {
                print("当前列表为空，刷新列表")
                CurrentBlock = generateNewBlocks()
                
                // 消除行、列的方块，用于判断新的方块位置
                clearFullRowsAndColumns()
                
                // 重新判断刷新的方块能否放置
                isBlockPlaced()
                print("CurrentBlock:\(CurrentBlock)")
                // 判断游戏是否结束
                if !GameOver && isGameOver() {
                    executeGameover()
                } else if !GameOver && isMasterpieceGameOver() {
                    executeGameover()
                }
            }
        } else {
            print("无法放置方块")
        }
    }
    
    // 执行GameOver方法
    func executeGameover() {
        // 播放结束音效
        if appStorage.Music {
            sound.playSound(named: "gameover1")
        }
        withAnimation {
            print("当放置方块后，检测isGameOver，GameOver改为true")
            GameOver = true
        }
        triggerShake() // 触发抖动
        // 更新最高分数
        updateScore()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                GameOverZoomAnimation = true
                GameOverButton = true
            }
        }
    }
    // 显示放置方块的阴影
    func shadowBlock(_ block: Block, _ start: CGPoint, _ end: CGSize, _ origins: CGPoint, _ indices : Int) {
        print("进入shadowBlock方法")
        guard let (col,row) = calculateRowCol(touchOffsetX: origins.x, touchOffsetY: origins.y, end: end) else {
            return
        }
        print("row:\(row), col: \(col)")
        // 检查 row 和 col 是否有效
        guard row >= 0, col >= 0, row < rowCount, col < colCount else {
            print("无法放置方块，超出网格边界")
            return
        }
        // 检查是否可以放置
        let canPlace = canPlaceBlock(block, atRow: row, col: col)
        print("canPlaceBlock(row: \(row), col: \(col)) 返回值: \(canPlace)")
        if canPlace {
            print("进入 if 语句，canPlace 为 true")
            self.shadowPosition = (row, col)
            self.shadowBlock = block
            print("阴影尝试放置位置：row:\(row), col:\(col)")
            print("当前 shadowPosition：\(String(describing: shadowPosition))")
            print("当前 shadowBlock：\(String(describing: shadowBlock))")
            
            
        } else {
            print("进入 else 语句，canPlace 为 false")
            shadowPosition = nil
            shadowBlock = nil
        }
    }
    
    // 检查待消除的行列
    func willClearLinesAndColumns(_ block: Block, _ start: CGPoint, _ end: CGSize, _ origins: CGPoint, _ indices : Int) {
        print("进入willClearLinesAndColumns方法")
        
        // 每次都会清除待消除的行列
        pendingClearRows = []
        pendingClearColumns = []
        guard let (col,row) = calculateRowCol(touchOffsetX: origins.x, touchOffsetY: origins.y, end: end) else {
            return
        }
        
        // 检查 row 和 col 是否有效
        guard row >= 0, col >= 0, row < rowCount, col < colCount else {
            print("无法放置方块，超出网格边界")
            return
        }
        // 检查是否可以放置
        let canPlace = canPlaceBlock(block, atRow: row, col: col)
        print("canPlaceBlock(row: \(row), col: \(col)) 返回值: \(canPlace)")
        if canPlace {
            // 创建新的临时
            var newGrid = grid
            print("当前的临时棋盘为:\(grid)")
            // 将当前方块遍历到新棋盘上
            for r in 0..<block.shape.count {
                // 遍历当前方块的列数
                for c in 0..<block.shape[r].count {
                    // 如果方块对应的格为 1，则进入判断
                    if block.shape[r][c] == 1 {
                        let targetRow = row + r
                        let targetCol = col + c
                        // 将临时棋盘对应的方格新增棋子
                        newGrid[targetRow][targetCol] = 1
                    }
                }
            }
            print("新增方块后，当前的临时棋盘为:\(newGrid)")
            for row in 0..<rowCount {
                if newGrid[row].allSatisfy({ $0 == 1 }) {
                    // 如果临时棋盘整行都有方块，将该行设置为待消除状态
                    print("当前第\(row)行为待消除行，将对应行设置为待消除状态")
                    pendingClearRows.insert(row)
                }
            }
            for col in 0..<colCount {
                if (0..<rowCount).allSatisfy({ newGrid[$0][col] == 1 }) {
                    print("当前第\(col)行为待消除列，将对应列设置为待消除状态")
                    pendingClearColumns.insert(col)
                }
            }
            
        } else {
            print("当前区域不能放置，待消除行列重置为空")
            pendingClearRows = []
            pendingClearColumns = []
        }
    }
    
    func calculateRowCol(touchOffsetX: CGFloat, touchOffsetY: CGFloat, end: CGSize) -> (Int, Int)? {
        // y轴：鼠标点击位置 - 棋盘到顶点的位置 - 手势的偏移量 80
        let calculateY = touchOffsetY - gridOrigin.y - GestureOffset + end.height
        let row = Int(round(Double(calculateY / cellSize)))
        // x轴：方块到左侧点的距离 - 方块到棋盘的 60 = 第一列
        let calculateX = touchOffsetX + end.width  - gridOrigin.x
        let col = Int(round(Double(calculateX / cellSize)))
        return (col,row)
    }
    
    // 检查方块是否可以放置
    func canPlaceBlock(_ block: Block, atRow row: Int, col: Int) -> Bool {
        // 提前检查边界（避免循环内过多判断）
        if row + block.shape.count > rowCount || col + block.shape[0].count > colCount {
            return false
        }
        print("进入canPlaceBlock方法")
        print("计算出的 row:\(row), col:\(col)")
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
                    if targetRow < 0 || targetRow >= rowCount || targetCol < 0 || targetCol >= colCount || grid[targetRow][targetCol] == 1 {
                        print("targetRow:\(targetRow)")
                        print("targetCol:\(targetCol)")
                        print("返回false")
                        return false
                    }
                }
            }
        }
        // 返回 true
        print("当前可放置的方块为：\(block)")
        print("可放置行数为：\(row)")
        print("可放置列数为：\(col)")
        print("返回true")
        return true
    }
    
    // 消除整行/整列的方块
    func clearFullRowsAndColumns() {
        print("进入clearFullRowsAndColumns方法")
        print("当前棋盘为:\(grid)")
        var newGrid = grid
        print("创建newGrid")
        // 找到需要消除的行
        var rowsToClear: Set<Int> = []
        print("新增rowsToClear方法")
        for row in 0..<rowCount {
            if newGrid[row].allSatisfy({ $0 == 1 }) {
                rowsToClear.insert(row)
            }
        }
        print("补充rowsToClear方法")
        // 找到需要消除的列
        print("新增colsToClear方法")
        var colsToClear: Set<Int> = []
        for col in 0..<colCount {
            if (0..<rowCount).allSatisfy({ newGrid[$0][col] == 1 }) {
                colsToClear.insert(col)
            }
        }
        
        print("补充colsToClear方法")
        if !rowsToClear.isEmpty || !colsToClear.isEmpty {
            if appStorage.Music {
                sound.playSound(named: "clearSoundeffects")
            }
        }
        
        print("需要清除的行: \(rowsToClear.sorted())")
        print("需要清除的列: \(colsToClear.sorted())")
        
        // 清除整行
        for row in rowsToClear {
            print("清理第\(row)行")
            newGrid[row] = Array(repeating: 0, count: colCount)
        }
        
        print("清理整行后的棋盘为:\(newGrid)")
        // 清除整列
        for col in colsToClear {
            print("清理第\(col)列")
            for row in 0..<rowCount {
                print("将第\(col)列的第\(row)设置为0")
                newGrid[row][col] = 0
            }
        }
        print("清理整列侯的棋盘为:\(newGrid)")
        
        print("colCount:\(colCount),rowCount:\(rowCount)")
        // 奖励消除积分
        let EliminationRewards = rowsToClear.count * 10 + colsToClear.count * 10
        // 更新积分
        increaseScore(to: GameScore + EliminationRewards)
        
        // 处理方块下落：上面的行向下移动
        // 例如rowsToClear为 [2,5,3],sorted()为[2,3,5], reversed()为[5,3,2]
        print("rowsToClear.sorted().reversed():\(Array(rowsToClear.sorted().reversed()))")
        print("rowsToClear.sorted().enumerated():\(Array(rowsToClear.sorted().enumerated()))")
        print("rowsToClear.sorted().reversed().enumerated():\(Array(rowsToClear.sorted().reversed().enumerated()))")
        
        // 只有下沉消除消除模式，会向下消除
        if selectedTab == 0 {
            for (index, row) in rowsToClear.sorted().reversed().enumerated() { // 从下往上处理
                
                let adjustedRow = max(0, row + index) // 确保不会小于 0
                print("row:\(row)")
                if adjustedRow >= 1 {  // 只有 adjustedRow >= 1 时，才能进行下移操作
                    // 假如 row 只是3，那么reversed()为 [3,2,1]，所以先消除 row 为3的行
                    for r in (1...adjustedRow).reversed() {
                        print("r:\(r)")
                        // newGrid[3] = newGrid[2]
                        // newGrid[2] = newGrid[1]
                        // newGrid[1] = newGrid[0]
                        // 最好将第0行消除到第1行
                        newGrid[r] = newGrid[r - 1] // 当前行变成上一行
                    }
                }
                // 新增空行填充到第0行。
                newGrid[0] = Array(repeating: 0, count: colCount) // 顶部填充空行
            }
        }
        grid = newGrid
    }
    
    /// 判断当前是否游戏结束
    func isGameOver() -> Bool {
        print("当前棋盘grid为:\(grid)")
        print("CurrentBlock:\(CurrentBlock)")
        // 棋盘尺寸
        let rows = grid.count
        let cols = grid[0].count
        // 遍历当前的方块
        for block in CurrentBlock.compactMap({ $0 }) {
            // 方块行列
            let blockRows = block.shape.count
            let blockCols = block.shape[0].count
            // 在棋盘的每个位置尝试放置方块
            for startRow in 0...(rows - blockRows) {
                for startCol in 0...(cols - blockCols) {
                    let isCanPlaceBlock = canPlaceBlock(block, atRow: startRow, col: startCol)
                    print("isCanPlaceBlock:\(isCanPlaceBlock)")
                    print("进入判断")
                    if isCanPlaceBlock {
                        print("当前方块可以放置，游戏继续。")
                        return false
                    }
                }
            }
        }
        print("没有方块可以放置，游戏结束。")
        return true
    }
    
    // 判断世界名画模式的结束规则
    func isMasterpieceGameOver() -> Bool{
        // 如果是“世界名画”模式，判断selectedTab
        if selectedTab == 2 {
            for rows in masterpieceGrid {
                for col in rows {
                    // 当存在未填满的方块时，判断为false
                    if col == 0 {
                        return false
                    }
                }
            }
            // 如果遍历后，没有未填满的方块，返回true
            withAnimation(.easeIn(duration: 1)) {
                CompletedFamousPainting = true
            }
            return true
        }
        return false
    }
    
    // 分数递增动画
    func increaseScore(to newScore: Int) {
        Timer.scheduledTimer(withTimeInterval: animationSpeed, repeats: true) { timer in
            if GameScore < newScore{
                GameScore += incrementStep
            } else {
                timer.invalidate() // 目标值达到时停止
            }
        }
    }
    
    // 最高分数递增动画
    func increaseHighestScore(to newScore: Int) {
        // 如果新得分和总得分差距过大，设置总得分为新得分的 -60.
        if appStorage.HighestScore + 60 < newScore {
            appStorage.HighestScore = newScore - 60
        }
        // 加载逐渐递增的动画效果
        Timer.scheduledTimer(withTimeInterval: animationSpeed, repeats: true) { timer in
            if appStorage.HighestScore < newScore{
                appStorage.HighestScore += incrementStep
            } else {
                timer.invalidate() // 目标值达到时停止
            }
        }
    }
    
    // 更新最高分
    func updateScore() {
        if GameScore > appStorage.HighestScore {
            print("更新最高得分")
            ShowHighestScore = true
            increaseHighestScore(to: GameScore)
        }
    }
    // 触发抖动的简单方法
    private func triggerShake() {
        withAnimation(Animation.linear(duration: 0.1).repeatCount(5, autoreverses: true)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            shakeOffset = 0
        }
    }
    
    //  生成蒙版，显示已占据的部分
    func maskView() -> some View {
        VStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<colCount, id: \.self) { col in
                        if masterpieceGrid[row][col] == 1 {
                            Rectangle()
                                .fill(Color.white) // 显示占据部分
                        } else {
                            Rectangle()
                                .opacity(0)
                        }
                    }
                }
            }
        }
    }
    
    // 检查方块是否可以放置
    func isBlockPlaced() {
        print("进入isBlockPlaced方法")
        let rows = grid.count
        let cols = grid[0].count
        // 遍历当前方块
        for (index, block) in CurrentBlock.enumerated() {
            guard let block = block else {
                CurrentBlockStatus[index] = false  // 如果 block 为 nil，直接设置为不可放置
                continue
            }
            var canPlace = false  // 标志位：是否可以放置
            // 检查每个位置是否可以放置
            for startRow in 0...(rows - block.shape.count) {
                for startCol in 0...(cols - block.shape[0].count) {
                    let isCanPlaceBlock = canPlaceBlock(block, atRow: startRow, col: startCol)
                    if isCanPlaceBlock {
                        print("当前方块可以放置，游戏继续。")
                        CurrentBlockStatus[index] = true
                        canPlace = true
                        break  // 找到一个可放置的位置后，立即跳出内层循环
                    }
                }
                if canPlace { break }  // 也跳出外层循环
            }
            
            // 如果遍历完所有位置都无法放置，则标记为 false
            if !canPlace {
                CurrentBlockStatus[index] = false
            }
        }
    }
    var body: some View {
        NavigationView {
            GeometryReader { globalGeo in
                // 棋盘和方块
                VStack {
                    VStack(spacing: 10) {
                        // 本次得分
                        if !ShowHighestScore {
                            HStack {
                                if GameOver {
                                    Text("This time's score")
                                    Spacer().frame(width: 20)
                                }
                                Text("\(GameScore)")
                            }
                        } else {
                            // 最高得分
                            HStack {
                                Text("Highest score")
                                Spacer().frame(width: 20)
                                Text("\(appStorage.HighestScore)")
                            }
                        }
                    }
                    .padding(.horizontal, 50)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(colorScheme == .light ? Color(hex: "2F438D") : .gray)
                    .cornerRadius(10)
                    Spacer().frame(height: 50)
                    // 网格和方块，用于结束时缩放。
                    VStack {
                        // 背景网格
                        GameGridView(grid: grid, shadowPosition: shadowPosition, shadowBlock: shadowBlock,cellSize: cellSize,pendingClearRows:pendingClearRows,pendingClearColumns:pendingClearColumns)
                            .background {
                                GeometryReader { gridGeo in
                                    Color.clear
                                        .onAppear {
                                            DispatchQueue.main.async {
                                                let gridPosition = gridGeo.frame(in: .global).origin
                                                gridOrigin = gridPosition
                                                print("使用延迟获取的网格原点 gridOrigin: \(gridOrigin)")
                                            }
                                        }
                                }
                                if selectedTab != 2 {
                                    Image("\(appStorage.ChessboardSkin)")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: CGFloat(colCount) * cellSize, height: CGFloat(rowCount) * cellSize)
                                        .clipped()
                                } else {
                                    ZStack {
                                        // 虚化背景
                                        Image("masterpiece\(paintingNumber)")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: CGFloat(colCount) * cellSize, height: CGFloat(rowCount) * cellSize)
                                            .clipped()
                                            .opacity(0.3)
                                        // 放置背景
                                        Image("masterpiece\(paintingNumber)")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: CGFloat(colCount) * cellSize, height: CGFloat(rowCount) * cellSize)
                                            .clipped()
                                            .opacity(0.8)
                                            .mask(maskView()) // 使用 mask 实现显示占据的部分
                                    }
                                }
                                
                            }
                            .overlay {
                                if CompletedFamousPainting {
                                    Image("masterpiece\(paintingNumber)")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: CGFloat(colCount) * cellSize, height: CGFloat(rowCount) * cellSize)
                                        .clipped()
                                        .opacity(CompletedFamousPainting ? 1 : 0)
                                }
                            }
                        Spacer().frame(height: 30)
                        // 三个随机生成的方块
                        HStack(alignment: .center,spacing: 10) {
                            ForEach(0..<3,id: \.self) {item in
                                ZStack {
                                    if CurrentBlock.indices.contains(item), let block = CurrentBlock[item] {
                                        DraggableBlockView(block: block,
                                                           GestureOffset: GestureOffset,
                                                           onDrag :{ start, end, geo  in
                                            DispatchQueue.main.async {
                                                print("移动中")
                                                print("gridOrigin:\(gridOrigin)")
                                                // 阴影方块
                                                shadowBlock(block, start, end, geo, item)
                                                // 待消除的行列
                                                willClearLinesAndColumns(block,start, end, geo, item)
                                            }
                                        },
                                                           onDrop: {start, end, geo  in
                                            print("放置方块")
                                            print("清空待消除的行列")
                                            pendingClearRows = []
                                            pendingClearColumns = []
                                            
                                            print("gridOrigin:\(gridOrigin)")
                                            placeBlock(block, start, end, geo, item)
                                            // 放置方块
                                            print("设置shadowPosition和shadowBlock为nil")
                                            shadowPosition = nil
                                            shadowBlock = nil
                                            // 消除方块
                                            clearFullRowsAndColumns()
                                            // 判断方块能否放置
                                            isBlockPlaced()
                                            // 判断游戏是否结束
                                            if !GameOver && isGameOver() {
                                                executeGameover()
                                            } else if isMasterpieceGameOver() {
                                                executeGameover()
                                            }
                                        })
                                        .offset(x: shakeOffset) // 应用抖动偏移
                                        .opacity(CurrentBlockStatus[item] ? 1.0 : 0.3)  // 无法放置时改变透明度
                                    } else {
                                        Rectangle()
                                            .opacity(0)
                                    }
                                }
                                .frame(width: 120,height: 120)
                            }
                        }
                        .frame(width: 360)
                    }
                    .frame(height: GameOverZoomAnimation ? 306 : 510)
                    .scaleEffect(GameOverZoomAnimation ? 0.6 : 1)
                    .animation(.easeInOut(duration: 0.3), value: GameOverZoomAnimation)
                    if GameOverButton {
                        Spacer().frame(height: 30)
                        VStack {
                            Button(action: {
                                print("点击了重新开始按钮")
                                if !appStorage.RequestRating {
                                    appStorage.RequestRating = true
                                    SKStoreReviewController.requestReview()
                                }
                                // 重制方块状态，改为可放置状态
                            CurrentBlockStatus = Array(repeating: true, count: 3)
                                withAnimation {
                                    print("结束标识改为false")
                                    // 结束标识改为false
                                    GameOver = false
                                    // 结束动画标识改为false
                                    GameOverZoomAnimation = false
                                    GameOverButton = false
                                    // 重置分数
                                    GameScore = 0
                                    // 重置显示最高得分
                                    ShowHighestScore = false
                                    // 重置棋盘
                                    grid = Array(repeating: Array(repeating: 0, count: colCount), count: rowCount)
                                    // 重制名画棋盘
                                    masterpieceGrid = Array(repeating: Array(repeating: 0, count: colCount), count: rowCount)
                                    // 重置方块
                                    CurrentBlock = generateNewBlocks()
                                    appStorage.GameSessions += 1
                                    // 设置完成名画为false
                                    CompletedFamousPainting = false
                                    
                                    // 重新设置世界名画的内容
                                    paintingNumber = Int.random(in: 0..<paintingMaxNum)
                                }
                            }, label: {
                                Text("Play again")
                                    .fontWeight(.bold)
                                    .frame(width: 240,height: 60)
                                    .foregroundColor(.white)
                                    .background(colorScheme == .light ? Color(hex: "2F438D") : .gray)
                                    .cornerRadius(10)
                            })
                            Spacer().frame(height: 30)
                            Button(action: {
                                viewStep = 0
                            }, label: {
                                Text("Return")
                                    .fontWeight(.bold)
                                    .frame(width: 240,height: 60)
                                    .foregroundColor(colorScheme == .light ?  Color(hex:"2F438D") : .white)
                                    .background(colorScheme == .light ? .white : .black)
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                            })
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    if CurrentBlock.isEmpty {
                        CurrentBlock = generateNewBlocks()
                    }
                    DispatchQueue.main.async {
                        windowSize = globalGeo.size
                    }
                }
                .onChange(of: globalGeo.size) { newSize in
                    DispatchQueue.main.async {
                        windowSize = globalGeo.size
                    }
                    
                }
                .overlay {
                    // 当达到最高分或者完成“世界名画”时，播放烟花
                    if ShowHighestScore || CompletedFamousPainting {
                        VStack {
                            LottieView(filename: "Fireworks2") // 替换为你的 Lottie 文件名
                                .allowsHitTesting(false) // 让动画不阻挡点击
                                .offset(y: -200)
                        }
                    }
                }
                .sheet(isPresented: $isSettingView) {
                    SettingView()
                }
                .toolbar {
                    // 标题
                    ToolbarItem(placement: .principal) {
                        Text(LocalizedStringKey(modelNames[selectedTab]))
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
                            isSettingView = true
                        }, label: {
                            Image(systemName: "gearshape")
                                .foregroundColor(colorScheme == .light ? Color(hex:"2F438D") : .white)
                        })
                    }
                }
            }
        }
        .navigationViewStyle(.stack) // 让 macOS 也变成单个视图
    }
}

#Preview {
    //    if let bundleID = Bundle.main.bundleIdentifier {
    //        UserDefaults.standard.removePersistentDomain(forName: bundleID)
    //    }
    Game(viewStep: .constant(1),selectedTab: .constant(5), paintingMaxNum: 11, modelNames: ["Sinking elimination","Three Identical Blocks","World famous paintings","Slope Blocks","Classic elimination","Football Hot Zone"])
        .environmentObject(AppStorageManager.shared)
        .environmentObject(SoundManager.shared)
}

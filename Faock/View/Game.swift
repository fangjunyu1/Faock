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
    
    @Binding var viewStep: Int
    @Binding var selectedTab: Int
    
    @State private var GameScore = 0
    @State private var CurrentBlock: [Block?] = []
    @State private var gridOrigin: CGPoint = .zero  // 记录视图左上角坐标
    @State private var locationText: CGPoint = .zero
    @State private var shadowPosition: (row: Int, col: Int)? = nil  // 阴影位置
    @State private var shadowBlock: Block? = nil    // 阴影方块
    @State private var GameOver = false
    @State private var shakeOffset: CGFloat = 0
    @State private var GameOverZoomAnimation = false
    @State private var isSettingView = false
    // 分数更新动画
    let incrementStep = 1  // 每次增加多少
    let animationSpeed = 0.05  // 速度（秒）
    
    let GestureOffset: CGFloat = 80
    let cellSize: CGFloat = 40  // 需要与网格大小一致
    
    let rowCount:Int    //  行
    let colCount:Int    // 列
    //    let block = Block(shape: [[1, 1, 1], [0, 1, 0]])
    
    @State private var windowSize: CGSize = .zero
    @State private var GameOverButton = false
    @State private var ShowHighestScore = false
    
    init(viewStep: Binding<Int>,selectedTab:Binding<Int>, rowCount: Int = 10, colCount: Int = 8) {
        self._viewStep = viewStep
        self._selectedTab = selectedTab
        self.rowCount = rowCount
        self.colCount = colCount
        _grid = State(initialValue: Array(repeating: Array(repeating: 0, count: colCount), count: rowCount))
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
        if selectedTab == 0 {
            return blocks.shuffled().prefix(3).map { $0 }
        } else if selectedTab == 1 {
            // 生成3个相同方块
            if let block = blocks.randomElement() {
                return Array(repeating: block, count: 3)  // 重复3次
            } else {
                return []
            }
        } else {
            return blocks.shuffled().prefix(3).map { $0 }
        }
    }
    
    
    // 放置方块
    func placeBlock(_ block: Block, _ start: CGPoint, _ end: CGSize, _ origins: CGPoint, _ indices : Int) {
        print("进入placeBlock方法")
        print("start:\(start)")
        print("end:\(end)")
        print("origins:\(origins)")
        print("gridOrigin:\(gridOrigin)")
        // 计算用户实际触碰的相对位置
        let touchOffsetX = origins.x
        let touchOffsetY = origins.y
        print("touchOffsetX:\(touchOffsetX)")
        print("touchOffsetY:\(touchOffsetY)")
        // y轴：方块到顶点的距离 - 方块到棋盘的 60 - 手势偏移的80 = 第一行
        let CalculateY = touchOffsetY - gridOrigin.y - GestureOffset + end.height
        let row = Int(round(Double(CalculateY / cellSize)))
        // x轴：方块到左侧点的距离 - 方块到棋盘的 60 = 第一列
        let CalculateX = touchOffsetX + end.width - gridOrigin.x
        let col = Int(round(Double(CalculateX / cellSize)))
        print("row:\(row), col: \(col)")
        // 检查 row 和 col 是否有效
        guard row >= 0, col >= 0, row < rowCount, col < colCount else {
            print("无法放置方块，超出网格边界")
            return
        }
        
        // 检查是否可以放置
        print("进入canPlaceBlock方法")
        let isCanPlaceBlock =  canPlaceBlock(block, atRow: row, col: col)
        print("当canPlaceBlock方法为true时，执行棋盘遍历")
        if isCanPlaceBlock{
            print("进入棋盘遍历")
            for r in 0..<block.rows {
                for c in 0..<block.shape[r].count {
                    if block.shape[r][c] == 1 {
                        grid[row + r][col + c] = 1
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
                print("CurrentBlock:\(CurrentBlock)")
                // 判断游戏是否结束
                if isGameOver() {
                    withAnimation {
                        GameOver = true
                    }
                    triggerShake() // 触发抖动
                    // 更新最高分数
                    updateScore()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            GameOverZoomAnimation = true
                            GameOverButton = true
                        }
                    }
                }
            }
        } else {
            print("无法放置方块")
        }
    }
    
    // 显示放置方块的阴影
    func shadowBlock(_ block: Block, _ start: CGPoint, _ end: CGSize, _ origins: CGPoint, _ indices : Int) {
        print("进入shadowBlock方法")
        print("start:\(start)")
        print("end:\(end)")
        print("origins:\(origins)")
        print("gridOrigin:\(gridOrigin)")
        let touchOffsetX = origins.x
        let touchOffsetY = origins.y
        // y轴：方块到顶点的距离 - 方块到棋盘的 60 - 手势偏移的80 = 第一行
        let CalculateY = touchOffsetY - gridOrigin.y - GestureOffset + end.height
        let row = Int(round(Double(CalculateY / cellSize)))
        // x轴：方块到左侧点的距离 - 方块到棋盘的 60 = 第一列
        let CalculateX = touchOffsetX + end.width  - gridOrigin.x
        let col = Int(round(Double(CalculateX / cellSize)))
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
            if (0..<colCount).allSatisfy({ newGrid[$0][col] == 1 }) {
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
        
        // 清除整行
        for row in rowsToClear {
            newGrid[row] = Array(repeating: 0, count: rowCount)
        }
        
        // 清除整列
        for col in colsToClear {
            for row in 0..<colCount {
                newGrid[row][col] = 0
            }
        }
        
        // 奖励消除积分
        let EliminationRewards = rowsToClear.count * 10 + colsToClear.count * 10
        // 更新积分
        increaseScore(to: GameScore + EliminationRewards)
        
        // 处理方块下落：上面的行向下移动
        // 例如rowsToClear为 [2,5,3],sorted()为[2,3,5], reversed()为[5,3,2]
        print("rowsToClear.sorted().reversed():\(Array(rowsToClear.sorted().reversed()))")
        print("rowsToClear.sorted().enumerated():\(Array(rowsToClear.sorted().enumerated()))")
        print("rowsToClear.sorted().reversed().enumerated():\(Array(rowsToClear.sorted().reversed().enumerated()))")
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
        grid = newGrid
    }
    
    /// 判断当前是否游戏结束
    func isGameOver() -> Bool {
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
        Timer.scheduledTimer(withTimeInterval: animationSpeed, repeats: true) { timer in
            if appStorage.HighestScore < newScore{
                appStorage.HighestScore += incrementStep
            } else {
                timer.invalidate() // 目标值达到时停止
                ShowHighestScore = true
            }
        }
    }
    
    func updateScore() {
        if GameScore > appStorage.HighestScore {
            print("更新最高得分")
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
                        GameGridView(grid: grid, shadowPosition: shadowPosition, shadowBlock: shadowBlock,cellSize: cellSize)
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
                                                shadowBlock(block, start, end, geo, item)
                                            }
                                        },
                                                           onDrop: {start, end, geo  in
                                            print("放置方块")
                                            print("gridOrigin:\(gridOrigin)")
                                            placeBlock(block, start, end, geo, item)
                                            // 放置方块
                                            print("设置shadowPosition和shadowBlock为nil")
                                            shadowPosition = nil
                                            shadowBlock = nil
                                            // 消除行、列的方块
                                            print("进入clearFullRowsAndColumns方法")
                                            clearFullRowsAndColumns()
                                            // 判断游戏是否结束
                                            if isGameOver() {
                                                withAnimation {
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
                                        })
                                        .offset(x: shakeOffset) // 应用抖动偏移
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
                                if !appStorage.RequestRating {
                                    appStorage.RequestRating = true
                                    SKStoreReviewController.requestReview()
                                }
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
                                // 重置方块
                                CurrentBlock = generateNewBlocks()
                                appStorage.GameSessions += 1
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
                    if ShowHighestScore {
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
                        Text(selectedTab == 0 ? String(localized: "Sinking elimination") : String(localized: "Three Identical Blocks"))
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
    Game(viewStep: .constant(1),selectedTab: .constant(1))
        .environmentObject(AppStorageManager.shared)
        .environmentObject(SoundManager.shared)
}

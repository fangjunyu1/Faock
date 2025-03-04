//
//  GameViewModel.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

//class GameViewModel: ObservableObject {
//    @Published var grid: [[GridCell]]
//    @Published var score: Int = 0
//    @Published var currentBlocks: [Block] = []
//    
//    init() {
//        self.grid = Array(repeating: Array(repeating: GridCell(), count: 9), count: 9)
//        self.currentBlocks = generateNewBlocks()
//    }
//
//    /// 生成新的可拖动方块
//    func generateNewBlocks() -> [Block] {
//        let blocks = [
//            Block(shape: [[1,1,1], [0,1,0]]), // T形
//            Block(shape: [[1,1], [1,1]]),     // 方块
//            Block(shape: [[1,1,1,1]])         // 长条形
//        ]
//        return blocks.shuffled().prefix(3).map { $0 }
//    }
//
//    /// 尝试放置方块
//    func placeBlock(_ block: Block, at position: (row: Int, col: Int)) -> Bool {
//        let shape = block.shape
//        let rows = shape.count
//        let cols = shape[0].count
//        
//        // 检查是否可以放置
//        for r in 0..<rows {
//            for c in 0..<cols {
//                if shape[r][c] == 1 {
//                    let targetRow = position.row + r
//                    let targetCol = position.col + c
//                    if targetRow >= 9 || targetCol >= 9 || grid[targetRow][targetCol].isOccupied {
//                        return false
//                    }
//                }
//            }
//        }
//
//        // 放置方块
//        for r in 0..<rows {
//            for c in 0..<cols {
//                if shape[r][c] == 1 {
//                    let targetRow = position.row + r
//                    let targetCol = position.col + c
//                    grid[targetRow][targetCol].isOccupied = true
//                }
//            }
//        }
//
//        // 检查消除
//        checkAndRemoveFullLines()
//        applyGravity()
//        score += 10 // 简单加分逻辑
//        return true
//    }
//
//    /// 消除满行/满列
//    func checkAndRemoveFullLines() {
//        var newGrid = grid
//        
//        // 检查行
//        for row in (0..<9).reversed() {
//            if newGrid[row].allSatisfy({ $0.isOccupied }) {
//                newGrid.remove(at: row)
//                newGrid.insert(Array(repeating: GridCell(), count: 9), at: 0)
//            }
//        }
//        
//        // 检查列
//        for col in 0..<9 {
//            if newGrid.allSatisfy({ $0[col].isOccupied }) {
//                for row in 0..<9 {
//                    newGrid[row][col].isOccupied = false
//                }
//            }
//        }
//        
//        grid = newGrid
//    }
//
//    /// 模拟重力：方块下落
//    func applyGravity() {
//        for col in 0..<9 {
//            var emptyRows: [Int] = []
//            
//            for row in (0..<9).reversed() {
//                if !grid[row][col].isOccupied {
//                    emptyRows.append(row)
//                } else if !emptyRows.isEmpty {
//                    let firstEmptyRow = emptyRows.removeFirst()
//                    grid[firstEmptyRow][col] = grid[row][col]
//                    grid[row][col] = GridCell()
//                    emptyRows.append(row)
//                }
//            }
//        }
//    }
//}

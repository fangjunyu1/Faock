//
//  Block.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

struct Block {
    let shape: [[Int]] // 二维数组表示形状  1 代表有方块，0 代表空白。
    
    /// 计算方块的行数
    //    var rows: Int { shape.count }
    
    /// 计算方块的列数，确保是最宽的一行
    //    var cols: Int { shape.map { $0.count }.max() ?? 0 }
    
    // 检查方块是否可以放入指定的 9x9 网格
//    func canPlace(in grid: [[Int]], at row: Int, col: Int) -> Bool {
//        guard row + rows <= grid.count, col + cols <= grid[0].count else {
//            return false // 超出网格边界
//        }
//        
//        for r in 0..<rows {
//            for c in 0..<shape[r].count {
//                if shape[r][c] == 1 && grid[row + r][col + c] == 1 {
//                    return false // 位置被占用，不能放置
//                }
//            }
//        }
//        return true
//    }
}

//
//  Block.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

struct Block {
    let shape: [[Int]] // 二维数组表示形状  1 代表有方块，0 代表空白。
    
    var rows: Int {  shape.count }
    
    var cols: Int { shape.first?.count ?? 0 }
    
    var score: Int {
        var count = 0
        for i in 0..<shape.count {
            for j in 0..<shape[i].count {
                if shape[i][j] == 1 {
                    count += 1
                }
            }
        }
        return count
    }
}

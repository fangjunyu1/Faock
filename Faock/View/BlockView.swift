//
//  BlockView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//
// 渲染棋子

import SwiftUI

struct BlockView: View {
    let block: Block
    let blockSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<block.rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<block.cols, id: \.self) { col in
                        if block.shape[row][col] == 1 {
                            Image("block0")
                                .resizable()
                                .scaledToFit()
                                .frame(width: blockSize, height: blockSize)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: blockSize, height: blockSize)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    BlockView(block: Block(shape: [[0,1,0],[1,1,1]]))
}

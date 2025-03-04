//
//  GridView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/3.
//

import SwiftUI

//struct GridView: View {
//    @ObservedObject var viewModel: GameViewModel
//    
//    let columns = Array(repeating: GridItem(.flexible()), count: 9)
//    
//    var body: some View {
//        LazyVGrid(columns: columns, spacing: 2) {
//            ForEach(0..<9, id: \.self) { row in
//                ForEach(0..<9, id: \.self) { col in
//                    Rectangle()
//                        .fill($viewModel.grid[row][col].isOccupied ? Color.blue : Color.gray.opacity(0.3))
//                        .frame(width: 30, height: 30)
//                        .border(Color.black, width: 1)
//                        .onDrop(of: ["public.text"], isTargeted: nil) { providers -> Bool in
//                            if let blockData = providers.first?.loadItem(forTypeIdentifier: "public.text", options: nil) as? String {
//                                let block = Block(shape: [[1,1], [1,1]]) // 解析数据（这里默认方块）
//                                return viewModel.placeBlock(block, at: (row, col))
//                            }
//                            return false
//                        }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    GridView(viewModel: GameViewModel())
//}

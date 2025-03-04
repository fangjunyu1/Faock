//
//  DraggableBlockView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/4.
//

import SwiftUI

struct DraggableBlockView: View {
    let block: Block
    let onDrop: (CGPoint) -> Void
    @GestureState private var dragOffset: CGSize = .zero
    @State private var isMoving: Bool = false
        
        var body: some View {
            BlockView(block: block)
                .offset(dragOffset)
                .scaleEffect(isMoving ? 1 :0.5)
                .gesture(
                    DragGesture()
                        .onChanged { _ in
                            isMoving = true
                        }
                        .updating($dragOffset) { value, status,_ in
                            status = value.translation
                            status.height -= 80
                        }
                        .onEnded { value in
                            isMoving = false
                            onDrop(value.location) // 用户松手时，触发放置
                        }
                )
        }
}

#Preview {
    DraggableBlockView(block: Block(shape: [[0,1,0],[1,1,1]]), onDrop: {_ in })
}

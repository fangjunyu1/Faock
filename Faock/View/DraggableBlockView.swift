//
//  DraggableBlockView.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/4.
//

import SwiftUI

struct DraggableBlockView: View {
    let block: Block
    let GestureOffset: CGFloat
    let onDrag: (CGPoint, CGSize, CGPoint) -> Void // 新增闭包
    let onDrop: (CGPoint,CGSize,CGPoint) -> Void
    @GestureState private var dragOffset: CGSize = .zero
    @State private var isMoving: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            
                let geoPosition =  geo.frame(in: .global).origin
            BlockView(block: block)
                .offset(dragOffset)
                .scaleEffect(isMoving ? 1 :0.5)
                .gesture(
                    DragGesture()
                        .onChanged { _ in
                            isMoving = true
                        }
                        .updating($dragOffset) { value, status,_ in
                            let startPosition = value.startLocation
                            let endTranslation = value.translation
                            status = value.translation
                            status.height -= GestureOffset
                            onDrag(startPosition,endTranslation,geoPosition) // 移动，调用闭包
                        }
                        .onEnded { value in
                            isMoving = false
                            let startPosition = value.startLocation
                            let endTranslation = value.translation
                            onDrop(startPosition,endTranslation,geoPosition) // 用户松手时，调用闭包
                        }
                )
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
    }
}

#Preview {
    DraggableBlockView(block: Block(shape: [[0,1,0],[1,1,1]]), GestureOffset: 80, onDrag: {_,_,_ in }, onDrop: { _, _,_  in })
}

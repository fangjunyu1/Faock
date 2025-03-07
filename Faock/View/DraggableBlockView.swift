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
    let onDrop: (CGPoint,CGSize,CGPoint) -> Void
    @GestureState private var dragOffset: CGSize = .zero
    @State private var isMoving: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            
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
                            status.height -= GestureOffset
                        }
                        .onEnded { value in
                            let geoPosition =  geo.frame(in: .global).origin
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
    DraggableBlockView(block: Block(shape: [[0,1,0],[1,1,1]]), GestureOffset: 80, onDrop: { _, _,_  in })
}

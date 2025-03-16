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
    @State private var geoPosition: CGPoint = .zero // 存储 GeometryReader 位置
    
    /// **强制更新 geoPosition**
    private func updateGeoPosition() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.windows.first })
                .first {
                let frame = window.convert(CGRect.zero, from: nil)
                geoPosition = frame.origin
                print("强制更新 geoPosition: \(String(describing: geoPosition))")
            }
        }
    }
    
    var body: some View {
        BlockView(block: block)
            .offset(dragOffset)
            .scaleEffect(isMoving ? 1 : 0.5)
            .background {
                GeometryReader { geo in
                    Color.clear.onAppear {
                        DispatchQueue.main.async {
                            geoPosition = geo.frame(in: .global).origin
                        }
                    }
                    
                    .onChange(of: geo.frame(in: .global).origin) { newValue in
                        DispatchQueue.main.async {
                            geoPosition = newValue
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        isMoving = true
                        if geoPosition == .zero {
                            updateGeoPosition() // 手势开始时检查 geoPosition 是否有效
                        }
                    }
                    .updating($dragOffset) { value, status,_ in
                        // 计算缩放前的点击点
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
    }
}

#Preview {
    let appStorage = AppStorageManager.shared
    return DraggableBlockView(block: Block(shape: [[0,1,0],[1,1,1]]), GestureOffset: 80, onDrag: {_,_,_ in }, onDrop: { _, _,_  in })
        .environmentObject(appStorage) // 确保环境对象存在
}

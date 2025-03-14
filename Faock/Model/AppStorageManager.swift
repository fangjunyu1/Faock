//
//  AppStorageManager.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/12.
//


import SwiftUI
import Observation


class AppStorageManager:ObservableObject {
    static let shared = AppStorageManager()  // 全局单例
    private init() {
        // 初始化时同步本地存储
        loadUserDefault()
        
        // 从iCloud读取数据
        loadFromiCloud()
        
        // 监听 iCloud 变化，同步到本地
        observeiCloudChanges()
        
        // 监听应用进入后台事件
        observeAppLifecycle()
    }
    
    // 视图步骤
    @Published var Music: Bool = false {
        didSet {
            if Music != oldValue {
                UserDefaults.standard.set(Music, forKey: "Music")
                syncToiCloud()
            }
        }
    }
    
    // 最高得分
    @Published var HighestScore: Int = 0 {
        didSet {
            if HighestScore != oldValue {
                UserDefaults.standard.set(HighestScore, forKey: "HighestScore")
                syncToiCloud()
            }
        }
    }
    
    // 游戏场次
    @Published var GameSessions: Int = 0 {
        didSet {
            if GameSessions != oldValue {
                UserDefaults.standard.set(GameSessions, forKey: "GameSessions")
                syncToiCloud()
            }
        }
    }
    
    // 方块皮肤
    @Published var BlockSkins: String = "block0" {
        didSet {
            if BlockSkins != oldValue {
                UserDefaults.standard.set(BlockSkins, forKey: "BlockSkins")
                syncToiCloud()
            }
        }
    }
    
    // 棋盘皮肤
    @Published var ChessboardSkin: String = "bg0" {
        didSet {
            if ChessboardSkin != oldValue {
                UserDefaults.standard.set(ChessboardSkin, forKey: "ChessboardSkin")
                syncToiCloud()
            }
        }
    }
    
    // 评分
    @Published var RequestRating: Bool = false {
        didSet {
            if RequestRating != oldValue {
                UserDefaults.standard.set(RequestRating, forKey: "RequestRating")
                syncToiCloud()
            }
        }
    }
    
    @Published   var isInAppPurchase = false {
        didSet {
            if isInAppPurchase != oldValue {
                UserDefaults.standard.set(isInAppPurchase, forKey: "isInAppPurchase")
                syncToiCloud()
            }
        }
    }
    
    // 从UserDefaults加载数据
    private func loadUserDefault() {
        Music = UserDefaults.standard.bool(forKey: "Music")  // 视图步骤
        HighestScore = UserDefaults.standard.integer(forKey: "HighestScore")  // 最高得分
        GameSessions = UserDefaults.standard.integer(forKey: "GameSessions")  // 游戏场次
        BlockSkins = UserDefaults.standard.string(forKey: "BlockSkins") ?? "block0"  // 方块皮肤
        ChessboardSkin = UserDefaults.standard.string(forKey: "ChessboardSkin") ?? "block0"  // 棋盘皮肤
        RequestRating = UserDefaults.standard.bool(forKey: "RequestRating")  // 视图步骤
        isInAppPurchase = UserDefaults.standard.bool(forKey: "isInAppPurchase")  // 商品内购
    }
    
    /// 从 iCloud 读取数据
    private func loadFromiCloud() {
        let store = NSUbiquitousKeyValueStore.default
        print("从iCloud读取数据")
        
        // 读取布尔值
        if store.object(forKey: "Music") != nil {
            Music = store.bool(forKey: "Music")
        } else {
            store.set(Music, forKey: "Music")
        }
        
        if store.object(forKey: "RequestRating") != nil {
            RequestRating = store.bool(forKey: "RequestRating")
        } else {
            store.set(RequestRating, forKey: "RequestRating")
        }
        
        if store.object(forKey: "isInAppPurchase") != nil {
            isInAppPurchase = store.bool(forKey: "isInAppPurchase")
        } else {
            store.set(isInAppPurchase, forKey: "isInAppPurchase")
        }
        
        // 读取整数值
        if let storeHighestScore = store.object(forKey: "HighestScore") as? Int {
            HighestScore = storeHighestScore
        } else {
            store.set(HighestScore, forKey: "HighestScore")
        }
        
        if let storeGameSessions = store.object(forKey: "GameSessions") as? Int {
            GameSessions = storeGameSessions
        } else {
            store.set(HighestScore, forKey: "GameSessions")
        }
        
        // 读取字符串值
        if let storeBlockSkins = store.string(forKey: "BlockSkins"){
            BlockSkins = storeBlockSkins
        } else {
            store.set(BlockSkins, forKey: "BlockSkins")
        }
        
        if let storeChessboardSkin = store.string(forKey: "ChessboardSkin"){
            ChessboardSkin = storeChessboardSkin
        } else {
            store.set(ChessboardSkin, forKey: "ChessboardSkin")
        }
        
        store.synchronize() // 强制触发数据同步
    }
    
    /// 数据变化时，**同步到 iCloud**
    private func syncToiCloud() {
        let store = NSUbiquitousKeyValueStore.default
        store.set(Music, forKey: "Music")
        store.set(HighestScore, forKey: "HighestScore")
        store.set(GameSessions, forKey: "GameSessions")
        store.set(BlockSkins, forKey: "BlockSkins")
        store.set(ChessboardSkin, forKey: "ChessboardSkin")
        store.set(RequestRating, forKey: "RequestRating")
        store.set(isInAppPurchase, forKey: "isInAppPurchase")
        store.synchronize() // 强制触发数据同步
    }
    
    /// 监听 iCloud 变化，同步到本地
    private func observeiCloudChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudDidUpdate),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
    }
    
    /// iCloud 数据变化时，更新本地数据
    @objc private func iCloudDidUpdate(notification: Notification) {
        print("iCloud数据发生变化，更新本地数据")
        DispatchQueue.main.async {
            self.loadFromiCloud()
        }
    }
    
    /// 监听应用生命周期事件
    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    /// 当应用进入后台时，将数据同步到 iCloud
    @objc private func appWillResignActive() {
        print("应用进入后台，将本地数据同步到iCloud")
        syncToiCloud()
    }
    
    /// 防止内存泄漏
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
}

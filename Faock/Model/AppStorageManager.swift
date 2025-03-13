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
    
    // 从UserDefaults加载数据
    private func loadUserDefault() {
        Music = UserDefaults.standard.bool(forKey: "Music")  // 视图步骤
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
        store.synchronize() // 强制触发数据同步

    }
    
    /// 数据变化时，**同步到 iCloud**
    private func syncToiCloud() {
        let store = NSUbiquitousKeyValueStore.default
        store.set(Music, forKey: "Music")
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

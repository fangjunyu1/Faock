//
//  appVersion.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/12.
//


import Foundation
extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var appBuild: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

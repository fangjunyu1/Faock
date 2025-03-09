//
//  SoundManager.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/9.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager() // 单例
    var player: AVAudioPlayer?

    func playSound(named soundName: String) {
        if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("播放失败: \(error.localizedDescription)")
            }
        } else {
            print("找不到音效文件: \(soundName)")
        }
    }
}

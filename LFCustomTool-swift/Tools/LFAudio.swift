//
//  LFAudio.swift
//  音效播放
//
//  Created by 刘丰 on 2017/10/14.
//  Copyright © 2017年 liufeng. All rights reserved.
//

import UIKit
import AudioToolbox

class LFAudio: NSObject {
    
    /// 用于播放短音效（一般30秒以内）
    ///
    /// - Parameters:
    ///   - name: 音效名称
    ///   - subdirectory: 音效所在子bundle目录
    ///   - completion: 播放完成后的回调
    public static func playShort(name: String, subdirectory: String = "", completion: ((_ errorString: String?) -> ())? = nil) {
        //获取文件的路径
        guard let pathUrl = Bundle.main.url(forResource: name, withExtension: nil, subdirectory: subdirectory) else {
        completion?("音效路径不正确")
        return
        }
    
        //获取音效文件对应的sourceID
        var sourceID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(pathUrl as CFURL, &sourceID)
    
        //根据id播放音效
        AudioServicesPlaySystemSoundWithCompletion(sourceID) {
        //根据id释放音效
        AudioServicesDisposeSystemSoundID(sourceID)
            completion?(nil)
        }
    }
    
    public static func playShort(name: String, completion: ((_ errorString: String?) -> ())?) {
        self.playShort(name: name, subdirectory: "", completion: completion)
    }
}


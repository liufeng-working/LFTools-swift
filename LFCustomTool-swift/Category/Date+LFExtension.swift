//
//  Date+LFExtension.swift
//  WeiBo
//
//  Created by 刘丰 on 2017/9/25.
//  Copyright © 2017年 liufeng. All rights reserved.
//

import Foundation

extension Date {
    
    /// 从时间字符串转换成可阅读的字符串
    ///
    /// - Parameters:
    ///   - originString: 原字符串
    ///   - originStringDateFormat: 原字符串的时间格式
    /// - Returns: 可阅读字符串
    public static func readableString(from originString: String, originStringDateFormat: String = "EEE MM dd HH:mm:ss Z yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = originStringDateFormat
        dateFormatter.locale = Locale(identifier: "en")
        
        var timeStr = ""
        if let createAtDate = dateFormatter.date(from: originString) {
            let interval = -createAtDate.timeIntervalSinceNow
            if interval < 0 {
                timeStr = "穿越了"
            }else if interval < 10 {//10秒内
                timeStr = "刚刚"
            }else if interval < 60 {
                timeStr = "1分钟内"
            }else if interval < 60*60 {
                timeStr = "\(Int(interval)/60)分钟前"
            }else if interval < 60*60*24 {
                timeStr = "\(Int(interval)/60/60)小时前"
            }else if interval < 60*60*24*2 {
                dateFormatter.dateFormat = "昨天 HH:mm"
                timeStr = dateFormatter.string(from: createAtDate)
            }else if interval < 60*60*24*3 {
                dateFormatter.dateFormat = "前天 HH:mm"
                timeStr = dateFormatter.string(from: createAtDate)
            }else {
                let calendar = Calendar.current
                let component = calendar.dateComponents(Set<Calendar.Component>([.year]), from: createAtDate, to: Date())
                if component.year! < 1 {
                    dateFormatter.dateFormat = "MM-dd HH:mm"
                    timeStr = dateFormatter.string(from: createAtDate)
                }else {
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    timeStr = dateFormatter.string(from: createAtDate)
                }
            }
        }
        return timeStr
    }
    
    /// 从秒数转成媒体式字符串
    ///
    /// - Parameter timeInterval: 描述
    /// - Returns: 媒体式字符串
    public static func mediaString(second timeInterval: TimeInterval) -> String {
        
        if timeInterval <= 0 {
            return "00:00"
        }
        
        let second = round(timeInterval) //四舍五入
        let dateFormatter = DateFormatter()
        if second < 60*60 {//1小时以内
            dateFormatter.dateFormat = "mm:ss"
        }else if second < 60*60*24 {//24小时以内
            dateFormatter.dateFormat = "HH:mm:ss"
        }else {//大于一天
            return "23:59:59";
        }
        
        let date = Date(timeIntervalSince1970: second)
        return dateFormatter.string(from: date)
    }
}

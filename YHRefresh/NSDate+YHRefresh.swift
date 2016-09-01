//
//  NSDate+YHRefresh.swift
//
//  Created by Detailscool on 16/3/23.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import Foundation

extension NSDate {
    
    func stringFromDate(format:String = "yyyy-MM-dd HH:mm:ss" ) -> String {
        let dfm = NSDateFormatter()
        dfm.dateFormat = format
        dfm.locale = NSLocale(localeIdentifier: "en")
        return dfm.stringFromDate(self)
    }
    
    class func dateFromString(string:String, format:String = "yyyy-MM-dd HH:mm:ss") -> NSDate? {
        let dfm = NSDateFormatter()
        dfm.dateFormat = format
        dfm.locale = NSLocale(localeIdentifier: "en")
        return dfm.dateFromString(string)
    }
    
    func isToday() -> Bool {
        return NSCalendar.currentCalendar().isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        return NSCalendar.currentCalendar().isDateInYesterday(self)
    }
    
}

extension String {
    
    func timeStateForRefresh(format:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let createDate = NSDate.dateFromString(self , format: format)
        if let date = createDate {
            if date.isToday() {
                return yh_Titles[6] + "\(date.stringFromDate("HH:mm"))"
            }else if date.isYesterday() {
                return yh_Titles[7] + " \(date.stringFromDate("HH:mm"))"
            }else {
                return "\(date.stringFromDate("MM-dd HH:mm"))"
            }
        }
        return self
    }
    
}

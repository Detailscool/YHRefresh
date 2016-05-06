//
//  NSDate+Extension.swift
//
//  Created by Detailscool on 16/3/23.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import Foundation

extension NSDate {
    
    func stringFromDate(format:String = "yyyy-MM-dd HH:mm:ss" ) -> String {
        
        let dfm = NSDateFormatter()
        
        dfm.dateFormat = format
        
        return dfm.stringFromDate(self)
        
    }

    class func dateFromString(string:String, format:String = "yyyy-MM-dd HH:mm:ss") -> NSDate? {
    
        let dfm = NSDateFormatter()
    
        dfm.dateFormat = format
        
        dfm.locale = NSLocale(localeIdentifier: "en")
    
        return dfm.dateFromString(string)
    
    }

    func dateComponentsDateToNow() -> NSDateComponents {
    
        let unit = NSCalendarUnit(rawValue: UInt.max)
        
        return NSCalendar.currentCalendar().components(unit, fromDate: self, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
    }
    
    func isThisYear() -> Bool {
        
        let created_at = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: self)
        let now = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: NSDate())
        return created_at.year == now.year

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
            
            if date.isThisYear() {
                
                if date.isToday() {
    
                    return NSLocalizedString("今天 ", comment: "Today")+"\(date.stringFromDate("HH:mm"))"
                    
                }else if date.isYesterday() {
                    
                    return NSLocalizedString("昨天 ", comment: "Yesterday")+" \(date.stringFromDate("HH:mm"))"
                    
                }else {
                    
                    return "\(date.stringFromDate("MM-dd HH:mm"))"
                }
                
            }else {
                
                return self
            }
            
        }
        
        return self
    }
    
}
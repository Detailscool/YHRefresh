//
//  UIScrollView+YH_Refresh.swift
//
//  Created by Detailscool on 16/3/28.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

var YHRefreshHeaderKey = "YHRefreshHeaderKey"
var YHRefreshFooterKey = "YHRefreshFooterKey"

public extension UIScrollView {
    
    open override static func initialize() {
        struct Static {
            static let token: String = NSUUID().uuidString
        }
        
        DispatchQueue.once(token: Static.token) {
            
            let originalSelector = NSSelectorFromString("dealloc")
            let swizzledSelector = #selector(UIScrollView.yhDeinit)
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    }
    
    func yhDeinit() {
        
        if let _ = yh_header {
            removeObserver(yh_header!, forKeyPath: yh_RefreshContentOffsetKey)
            removeObserver(yh_header!, forKeyPath: yh_RefreshContentSizeKey)
            yh_header!.removeFromSuperview()
        }
        
        if let _ = yh_footer {
            removeObserver(yh_footer!, forKeyPath: yh_RefreshContentOffsetKey)
            removeObserver(yh_footer!, forKeyPath: yh_RefreshContentSizeKey)
            yh_footer!.removeFromSuperview()
        }
        
        yhDeinit()
    }
    
    public var yh_header : YHRefreshHeader? {
        
        get {
            if let header = objc_getAssociatedObject(self, &YHRefreshHeaderKey) as? YHRefreshHeader {
                return header
            } else {
                return nil
            }
        }
        
        set {
            if let _ = self.yh_header, self.yh_header != newValue {
                self.yh_header!.removeFromSuperview()
            }
            
            self.addSubview(newValue!)
            objc_setAssociatedObject(self, &YHRefreshHeaderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        
    }
    
    public var yh_footer : YHRefreshFooter? {
        
        get {
            if let footer = objc_getAssociatedObject(self, &YHRefreshFooterKey) as? YHRefreshFooter {
                return footer
            } else {
                return nil
            }
        }
        
        set {
            if let _ = self.yh_footer, self.yh_footer != newValue {
                self.yh_footer!.removeFromSuperview()
            }
            
            self.addSubview(newValue!)
            objc_setAssociatedObject(self, &YHRefreshFooterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        
    }
    
    public var isHeaderRefreshing : Bool {
        guard let header = yh_header else {
            return false
        }
        
        return header.isRefreshing
    }
    
    public var isFooterRefreshing : Bool {
        guard let footer = yh_footer else {
            return false
        }
            
       return footer.isRefreshing
    }
    
    public var isRefreshing : Bool {
        return isHeaderRefreshing || isFooterRefreshing
    }
    
}

public extension Date {
    
    func stringFromDate(_ format:String = "yyyy-MM-dd HH:mm:ss" ) -> String {
        let dfm = DateFormatter()
        dfm.dateFormat = format
        dfm.locale = Locale(identifier: "en")
        return dfm.string(from: self)
    }
    
    static func dateFromString(_ string:String, format:String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dfm = DateFormatter()
        dfm.dateFormat = format
        dfm.locale = Locale(identifier: "en")
        return dfm.date(from: string)
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
}

public extension String {
    
    func timeStateForRefresh(_ format:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let createDate = Date.dateFromString(self , format: format)
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

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

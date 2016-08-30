//
//  UIScrollView+YH_Refresh.swift
//
//  Created by Detailscool on 16/3/28.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

var YHRefreshHeaderKey = "YHRefreshHeaderKey"
var YHRefreshFooterKey = "YHRefreshFooterKey"

extension UIScrollView {
    
    public override static func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            let originalSelector = Selector("dealloc")
            let swizzledSelector = Selector("yhDeinit")
            
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
            if let _ = self.yh_header where self.yh_header != newValue {
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
            if let _ = self.yh_footer where self.yh_footer != newValue {
                self.yh_footer!.removeFromSuperview()
            }
            
            self.addSubview(newValue!)
            objc_setAssociatedObject(self, &YHRefreshFooterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        
    }
    
    public func isHeaderRefreshing() -> Bool {
        if let _ = yh_header {
            return yh_header!.isRefreshing
        }else {
            return false
        }
    }
    
    public func isFooterRefreshing() -> Bool {
        if let _ = yh_footer {
            return yh_footer!.isRefreshing
        }else {
            return false
        }
    }
    
    public func isRefreshing() -> Bool {
        return isHeaderRefreshing() || isFooterRefreshing()
    }
    
}

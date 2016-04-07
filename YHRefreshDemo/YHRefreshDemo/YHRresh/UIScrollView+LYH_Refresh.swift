//
//  UIScrollView+LYH_Refresh.swift
//
//  Created by Detailscool on 16/3/28.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

var YHRefreshHeaderKey = "YHRefreshHeaderKey"
var YHRefreshFooterKey = "YHRefreshFooterKey"

extension UIScrollView {
    
    var yh_header : YHRefreshHeader? {
        
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
            
            self.insertSubview(newValue!, atIndex: 0)
                    
            objc_setAssociatedObject(self, &YHRefreshHeaderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            
        }
    }
    
    var yh_footer : YHRefreshFooter? {
        
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
    
}

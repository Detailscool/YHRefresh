//
//  YHRefreshConst.swift
//
//  Created by Detailscool on 16/4/1.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

enum YHRefreshState : String {
    case Normal = "Normal"
    case WillRefresh = "WillRefresh"
    case Refreshing = "Refreshing"
    case NoMoreData = "NoMoreData"
}

let yh_RefreshContentOffsetKey = "contentOffset"
let yh_RefreshContentSizeKey = "contentSize"

let yh_RefreshViewHeight : CGFloat = 60
let yh_SpringHeaderHeight : CGFloat = yh_RefreshViewHeight * 4 / 3

let yh_ScreenW = UIScreen.mainScreen().bounds.size.width
let yh_ScreenH = UIScreen.mainScreen().bounds.size.height

let yh_AnimationDuration = 0.25
let yh_ViewMargin : CGFloat = 15
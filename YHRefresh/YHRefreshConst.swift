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

typealias YHRefreshHandler = (Void -> ())

public let yh_RefreshContentOffsetKey = "contentOffset"
public let yh_RefreshContentSizeKey = "contentSize"
public let yh_RefreshFrameKey = "frame"
public let yh_RefreshRotationKey = "transform.rotation"

public let yh_RefreshHeaderHeight : CGFloat = 60
public let yh_SpringHeaderHeight : CGFloat = yh_RefreshHeaderHeight * 4 / 3
public let yh_RefreshFooterHeight : CGFloat = 55

public let yh_MaterialMaxOffset : CGFloat = 120

public let yh_ScreenW = UIScreen.mainScreen().bounds.size.width
public let yh_ScreenH = UIScreen.mainScreen().bounds.size.height

public let yh_AnimationDuration : NSTimeInterval = 0.25
public let yh_ViewMargin : CGFloat = 15

public let yh_Titles : [String] = [
                                   NSLocalizedString("下拉刷新...", comment: "PullDownToRefresh"),
                                   NSLocalizedString("释放刷新...", comment: "ReleaseToRefresh"),
                                   NSLocalizedString("正在刷新...", comment: "Refreshing"),
                                   NSLocalizedString("上拉刷新", comment: "PullUpToRefresh"),
                                   NSLocalizedString("没有更多数据", comment: "NoMoreData"),
                                   NSLocalizedString("最后更新时间 : ", comment: "Lastest Update"),
                                   NSLocalizedString("今天 ", comment: "Today"),
                                   NSLocalizedString("昨天 ", comment: "Yesterday")
                                   ]



//
//  YHRefresh.swift
//
//  Created by Detailscool on 16/4/1.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

class YHRefreshComponent: UIView {
    
    private weak var scrollView : UIScrollView!
    
    private weak var target : AnyObject?
    
    private var selector : Selector?
    
    private var handler : (Void -> ())?
    
    private var currentState : YHRefreshState = YHRefreshState.Normal
    
    private var state : YHRefreshState = YHRefreshState.Normal
    
    private var updateTime : NSDate?
    
    private lazy var loadingView : UIImageView = {
        let iv = UIImageView(image: UIImage(named: "YHRefresh.bundle/YHRefresh_loading"))
        iv.hidden = true
        return iv
    }()
    
    private lazy var messageLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = .Center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var activityIndicator : UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.color = UIColor.blackColor()
        ai.hidesWhenStopped = true
        return ai
    }()
    
    private lazy var arrowView : UIImageView = {
        let iv = UIImageView(image: UIImage(named: "YHRefresh.bundle/YHRefresh_arrow"))
        return iv
    }()
    
    func endRefreshing() {
        state = .Normal
    }
    
    var isRefreshing : Bool {
        get{
            return state == .Refreshing
        }
    }
    
}

class YHRefreshHeader : YHRefreshComponent {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        state = YHRefreshState.Normal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if let view = newSuperview as? UIScrollView {
            superview?.removeObserver(self, forKeyPath: yh_RefreshContentOffsetKey)
            superview?.removeObserver(self, forKeyPath: yh_RefreshContentSizeKey)
            
            scrollView = view
            
            scrollView.addObserver(self, forKeyPath: yh_RefreshContentOffsetKey, options: [], context: nil)
            scrollView.addObserver(self, forKeyPath: yh_RefreshContentSizeKey, options: [], context: nil)
        }
    }
    
    class func header(target:AnyObject?,selector:Selector?) -> AnyObject {
        let header = self.init()
        header.target = target
        header.selector = selector
        return header
    }
    
    class func header(handler:(Void -> ())) -> AnyObject {
        let header = self.init()
        header.handler = handler
        return header
    }
    
    func beginRefreshing() {
        state = .Refreshing
    }
    
}

class YHRefreshNormalHeader : YHRefreshHeader {
    
    override var state : YHRefreshState {
        didSet {
            
            switch state {
                
            case .Normal:
                
                loadingView.hidden = true
                arrowView.hidden = false
                messageLabel.text = updateTime == nil ? yh_Titles[0] : yh_Titles[0] + "\n" + yh_Titles[5] + updateTime!.stringFromDate().timeStateForRefresh()
                
                loadingView.layer.removeAllAnimations()
                
                UIImageView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                    self.arrowView.transform = CGAffineTransformIdentity
                })
                
                if currentState == .Refreshing {
                    UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                        self.scrollView.contentInset.top -= yh_RefreshHeaderHeight
                    })
                }
                
            case .WillRefresh:
                
                messageLabel.text = updateTime == nil ? yh_Titles[1] : yh_Titles[1] + "\n" + yh_Titles[5] + updateTime!.stringFromDate().timeStateForRefresh()
                
                UIImageView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                    self.arrowView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI - 0.0001))
                })
                
            case .Refreshing:
                
                loadingView.hidden = false
                arrowView.hidden = true
                messageLabel.text = yh_Titles[2] + "\n" + yh_Titles[5] + yh_Titles[6] + "\(NSDate().stringFromDate("HH : mm"))"
                updateTime = NSDate()
                
                let ani = CABasicAnimation(keyPath: "transform.rotation")
                ani.toValue = 2 * M_PI
                ani.duration = 0.75
                ani.repeatCount = MAXFLOAT
                ani.removedOnCompletion = false
                loadingView.layer.addAnimation(ani, forKey: "")
                
                UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                    self.scrollView.contentInset.top += yh_RefreshHeaderHeight
                    }, completion: { (_) -> Void in
                        if let _ = self.handler {
                            self.handler!()
                        }
                        if let _ = self.selector {
                            self.target?.performSelector(self.selector!)
                        }
                })
                
            default : break
                
            }
            
            currentState = state
        }
    }
    
    override init(var frame: CGRect) {
        frame = CGRect(x: 0, y: -yh_RefreshHeaderHeight, width: yh_ScreenW, height: yh_RefreshHeaderHeight)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(arrowView)
        addSubview(loadingView)
        addSubview(messageLabel)
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem:self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: arrowView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -yh_ViewMargin))
        addConstraint(NSLayoutConstraint(item: arrowView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: loadingView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: arrowView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: loadingView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: arrowView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let dragging = scrollView?.dragging {
            if dragging == true {
                if scrollView.contentOffset.y > -scrollView.contentInset.top - yh_RefreshHeaderHeight && state != .Normal && state != .Refreshing {
                    state = .Normal
                } else if scrollView.contentOffset.y <= -scrollView.contentInset.top - yh_RefreshHeaderHeight && state != .WillRefresh && state != .Refreshing {
                    state = .WillRefresh
                }
            }else {
                if state == .WillRefresh {
                    state = .Refreshing
                }
            }
        }
    }
    
}

class YHRefreshSpringHeader : YHRefreshHeader {
    
    override var state : YHRefreshState {
        didSet {
            
            switch state {
                
            case .Normal:
                
                activityIndicator.stopAnimating()
                
                springView.hidden = false
                
                if currentState == .Refreshing {
                    UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                        self.scrollView.contentInset.top -= yh_SpringHeaderHeight
                    })
                }
                
            case .Refreshing:
                
                springView.hidden = true
                
                activityIndicator.startAnimating()
                
                UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                    self.scrollView.contentInset.top += yh_SpringHeaderHeight
                    }, completion: { (_) -> Void in
                        if let _ = self.handler {
                            self.handler!()
                        }
                        if let _ = self.selector {
                            self.target?.performSelector(self.selector!)
                        }
                })
                
            default:break
                
            }
            
            currentState = state
        }
    }
    
    override init(var frame: CGRect) {
        frame = CGRect(x: 0, y: -yh_SpringHeaderHeight, width: yh_ScreenW, height: yh_SpringHeaderHeight)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(springView)
        addSubview(activityIndicator)
        
        springView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: springView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: springView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        springView.addConstraint(NSLayoutConstraint(item: springView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: yh_SpringHeaderHeight))
        springView.addConstraint(NSLayoutConstraint(item: springView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: yh_RefreshHeaderHeight))
        
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if scrollView.dragging == false {
            springView.progress = 0
        }
        
        let factor : CGFloat =  1
        
        if scrollView.contentOffset.y <= -scrollView.contentInset.top - yh_SpringHeaderHeight && state != .Refreshing{
            state = .Refreshing
        }
        
        if state != .Refreshing && scrollView.contentOffset.y <= -scrollView.contentInset.top - yh_RefreshHeaderHeight * factor {
            let progress = -(scrollView.contentOffset.y + scrollView.contentInset.top + yh_RefreshHeaderHeight * factor)/(yh_SpringHeaderHeight - yh_RefreshHeaderHeight * factor)
            springView.progress = progress
        }
    }
    
    private lazy var springView : YHRefreshSpringView = YHRefreshSpringView()
    
    class YHRefreshSpringView: UIView {
        
        var factor : CGFloat = 2.8
        
        var endFactor1 : CGFloat = 0.4
        var endFactor2 : CGFloat = 0.8
        
        var progress : CGFloat? {
            didSet {
                
                if progress > 1 || progress < 0 {
                    return
                }
                
                center2.y = frame.height - (frame.height/factor)*(1 + (factor - 1 - endFactor2) * progress!)
                radius1 = (min(frame.width, frame.height)/factor) * (1 - (1 - endFactor1) * progress!) //(0.6 * pow((progress! - 1),10) + 0.4)
                center1.y = frame.height - (frame.height/factor)*(1 - (1 - endFactor1) * progress!)
                radius2 = (min(frame.width, frame.height)/factor) * (1 - (1 - endFactor2) * progress!)
                
                setNeedsDisplay()
                
            }
        }
        
        private var center1 : CGPoint!
        private var center2 : CGPoint!
        private var radius1 : CGFloat!
        private var radius2 : CGFloat!
        
        private var arcPoint1 : CGPoint!
        private var arcPoint2 : CGPoint!
        
        private var arcPoint3 : CGPoint!
        private var arcPoint4 : CGPoint!
        
        private var controlPiont : CGPoint!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        private func setup() {
            backgroundColor = UIColor.clearColor()
            
            radius1 = min(frame.width, frame.height)/factor
            radius2 = min(frame.width, frame.height)/factor
            
            center1 = CGPoint(x: frame.width/2, y: frame.height*(factor - 1)/factor)
            center2 = CGPoint(x: frame.width/2, y: frame.height*(factor - 1)/factor)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setup()
        }
        
        var sizeFactor : CGFloat = 1.3
        
        override func drawRect(rect: CGRect) {
            
            let ctx = UIGraphicsGetCurrentContext()
            CGContextAddArc(ctx, center1.x, center1.y, radius1 , 0, CGFloat(2 * M_PI), 1)
            CGContextSetFillColorWithColor(ctx, UIColor.grayColor().CGColor)
            CGContextFillPath(ctx)
            
            CGContextAddArc(ctx, center2.x, center2.y, radius2 , 0, CGFloat(2 * M_PI), 1)
            CGContextSetFillColorWithColor(ctx, UIColor.grayColor().CGColor)
            CGContextFillPath(ctx)
            
            if !isSameCerter() {
                
                calculateTangent()
                
                CGContextMoveToPoint(ctx, arcPoint1.x, arcPoint1.y)
                //            CGContextAddQuadCurveToPoint(ctx, controlPiont.x + radius2, controlPiont.y, arcPoint3.x, arcPoint3.y)
                CGContextAddLineToPoint(ctx, arcPoint3.x, arcPoint3.y)
                CGContextAddLineToPoint(ctx, arcPoint4.x, arcPoint4.y)
                //            CGContextAddQuadCurveToPoint(ctx, controlPiont.x - radius2, controlPiont.y, arcPoint2.x, arcPoint2.y)
                CGContextAddLineToPoint(ctx, arcPoint2.x, arcPoint2.y)
                
                CGContextClosePath(ctx)
                CGContextFillPath(ctx)
            }
            
            let image = UIImage(named: "YHRefresh.bundle/YHRefresh_load")
            
            image?.drawInRect(CGRect(x: center2.x - radius2 * (sizeFactor / 2), y: center2.y - radius2 * (sizeFactor / 2), width: sizeFactor * radius2, height: sizeFactor * radius2))
            
        }
        
        private func isSameCerter() -> Bool {
            return center1 == center2
        }
        
        private func calculateTangent() {
            
            let centerDistance = sqrt(pow((center1.x - center2.x), 2) + pow((center1.y - center2.y), 2))
            let radiusGap = fabs(radius1 - radius2)
            let angle = acos(radiusGap / centerDistance)
            
            arcPoint1 = CGPoint(x: radius1 * sin(angle) + center1.x, y: -radius1 * cos(angle) + center1.y)
            arcPoint2 = CGPoint(x: -radius1 * sin(angle) + center1.x, y: -radius1 * cos(angle) + center1.y)
            arcPoint3 = CGPoint(x: radius2 * sin(angle) + center2.x, y: -radius2 * cos(angle) + center2.y)
            arcPoint4 = CGPoint(x: -radius2 * sin(angle) + center2.x, y: -radius2 * cos(angle) + center2.y)
            
            let controlY = centerDistance > 2 * (radius1 + radius2) ? center1.y + fabs(centerDistance - radius1 - radius2) : fabs(center2.y + center1.y)/2
            
            controlPiont = CGPointMake(fabs(center2.x + center1.x)/2, controlY)
            
        }
    }
    
}

class YHRefreshGifHeader : YHRefreshHeader {
    
    override var state : YHRefreshState {
        didSet {
            
            switch state {
                
            case .Normal:
                
                messageLabel.text = updateTime == nil ? yh_Titles[0] : yh_Titles[0] + "\n" + yh_Titles[5] + updateTime!.stringFromDate().timeStateForRefresh()
                
                if currentState == .Refreshing {
                    UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                        self.scrollView.contentInset.top -= yh_RefreshHeaderHeight
                    })
                    gifView.stopAnimating()
                }
                
                if currentState == .WillRefresh {
                    gifView.stopAnimating()
                }
                
            case .WillRefresh:
                
                messageLabel.text = updateTime == nil ? yh_Titles[1] : yh_Titles[1] + "\n" + yh_Titles[5] + updateTime!.stringFromDate().timeStateForRefresh()
                
                let images = stateImages[state.rawValue]
                
                if let _ = images {
                    if images!.count == 1 {
                        gifView.image = images!.first
                    }else {
                        gifView.animationImages = images
                        gifView.animationDuration = stateDurations[state.rawValue]!
                        gifView.startAnimating()
                    }
                }
                
            case .Refreshing:
                
                messageLabel.text = yh_Titles[2] + "\n" + yh_Titles[5] + yh_Titles[6] + "\(NSDate().stringFromDate("HH : mm"))"
                updateTime = NSDate()
                
                let images = stateImages[state.rawValue]
                
                if let _ = images {
                    if images!.count == 1 {
                        gifView.image = images!.first
                    }else {
                        gifView.animationImages = images
                        gifView.animationDuration = stateDurations[state.rawValue]!
                        gifView.startAnimating()
                    }
                }
                
                UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                    self.scrollView.contentInset.top += yh_RefreshHeaderHeight
                    }, completion: { (_) -> Void in
                        if let _ = self.handler {
                            self.handler!()
                        }
                        if let _ = self.selector {
                            self.target?.performSelector(self.selector!)
                        }
                })
                
            default : break
                
            }
            
            currentState = state
        }
    }
    
    override init(var frame: CGRect) {
        frame = CGRect(x: 0, y: -yh_RefreshHeaderHeight, width: yh_ScreenW, height: yh_RefreshHeaderHeight)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(gifView)
        addSubview(messageLabel)
        
        gifView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: gifView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -yh_ViewMargin))
        addConstraint(NSLayoutConstraint(item: gifView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let dragging = scrollView?.dragging {
            if dragging == true {
                if scrollView.contentOffset.y > -scrollView.contentInset.top - yh_RefreshHeaderHeight && state != .Normal && state != .Refreshing {
                    state = .Normal
                } else if scrollView.contentOffset.y <= -scrollView.contentInset.top - yh_RefreshHeaderHeight && state != .WillRefresh && state != .Refreshing {
                    state = .WillRefresh
                }
            }else {
                if state == .WillRefresh {
                    state = .Refreshing
                }
            }
        }
        
        if state == .Normal {
            pullingPercent = (scrollView.contentOffset.y + scrollView.contentInset.top) / (-yh_RefreshHeaderHeight)
            
            let images = stateImages[state.rawValue]
            if let _ = images where pullingPercent<=1 && pullingPercent>=0 {
                if images!.count == 1 {
                    gifView.image = images!.first
                }else {
                    gifView.image = stateImages[state.rawValue]![Int(CGFloat(images!.count - 1) * pullingPercent)]
                }
            }
        }
        
    }
    
    private var pullingPercent : CGFloat!
    
    private lazy var gifView = UIImageView()
    
    private lazy var stateImages = [String : [UIImage]]()
    
    private lazy var stateDurations = [String : NSTimeInterval]()
    
    func setGifHeader(images:[UIImage],duration:NSTimeInterval,state:YHRefreshState) {
        stateImages[state.rawValue] = images
        stateDurations[state.rawValue] = duration
    }
    
    func setGifHeader(images:[UIImage],state:YHRefreshState) {
        stateImages[state.rawValue] = images
        stateDurations[state.rawValue] = Double(images.count) * 0.1
    }
    
}

class YHRefreshMaterialHeader : YHRefreshHeader,UIGestureRecognizerDelegate {
    override var state : YHRefreshState {
        didSet {
            
            switch state {
                
            case .Normal:
                materialView.layer.removeAllAnimations()
                
                UIView.animateWithDuration(yh_AnimationDuration, animations: { 
                    self.frame.origin.y = -yh_SpringHeaderHeight
                    }, completion: { (_) in
                        
                })
                
            case .Refreshing:
                let ani = CABasicAnimation(keyPath: "transform.rotation")
                ani.toValue = 2 * M_PI
                ani.duration = 0.75
                ani.repeatCount = MAXFLOAT
                ani.removedOnCompletion = false
                materialView.layer.addAnimation(ani, forKey: "")
                
                if let _ = self.handler {
                    self.handler!()
                }
                if let _ = self.selector {
                    self.target?.performSelector(self.selector!)
                }
                
            default:break
                
            }
            
            currentState = state
        }
    }
    
    private var panGesture : UIPanGestureRecognizer!
    
    override init(var frame: CGRect) {
        frame = CGRect(x: 0, y: -yh_RefreshHeaderHeight, width: yh_ScreenW, height: yh_RefreshHeaderHeight)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panResponse(_:)))
        panGesture.delegate = self
        if scrollView != nil {
            scrollView.bounces = false
        }
    }
    
    private func setup() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(materialView)
        
        materialView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: materialView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: materialView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        materialView.addConstraint(NSLayoutConstraint(item: materialView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: yh_RefreshHeaderHeight))
        materialView.addConstraint(NSLayoutConstraint(item: materialView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: yh_RefreshHeaderHeight))
    }
    
    func panResponse(pan:UIPanGestureRecognizer) {
        
        frame.origin.y = min(-yh_RefreshHeaderHeight + pan.translationInView(scrollView).y, yh_MaterialMaxOffset)
        
        if pan.state == .Ended && frame.origin.y == yh_MaterialMaxOffset {
            state = .Refreshing
        }
        
        if pan.state == .Ended && frame.origin.y < yh_MaterialMaxOffset {
            state = .Normal
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.isEqual(panGesture) {
            if panGesture.translationInView(scrollView).y < 0 {
                scrollView.removeGestureRecognizer(panGesture)
            }
        }
        
        return true
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            if let _ = scrollView.gestureRecognizers where !scrollView.gestureRecognizers!.contains(panGesture) {
                scrollView.addGestureRecognizer(panGesture)
            }
        }
    }

    private lazy var materialView : YHRefreshMaterialView = YHRefreshMaterialView()
    
    class YHRefreshMaterialView: UIView {
        
        var progress : CGFloat? {
            didSet {
                
                if progress > 1 || progress < 0 {
                    return
                }
                
                setNeedsDisplay()
            }
        }
        
        private var circleCenter : CGPoint!
        private var radius : CGFloat!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        private func setup() {
            backgroundColor = UIColor.clearColor()
            
            radius = min(frame.width, frame.height)/2
            circleCenter = CGPoint(x: frame.width/2, y: frame.height/2)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setup()
        }
        
        var sizeFactor : CGFloat = 1.3
        
        override func drawRect(rect: CGRect) {
            
            let ctx = UIGraphicsGetCurrentContext()
            CGContextAddArc(ctx, circleCenter.x, circleCenter.y, radius , 0, CGFloat(2 * M_PI), 1)
            CGContextSetFillColorWithColor(ctx, UIColor.grayColor().CGColor)
            CGContextFillPath(ctx)
            
            let image = UIImage(named: "YHRefresh.bundle/YHRefresh_load")
            
            image?.drawInRect(CGRect(x: circleCenter.x - radius * (sizeFactor / 2), y: circleCenter.y - radius * (sizeFactor / 2), width: sizeFactor * radius, height: sizeFactor * radius))
            
        }
    }
    
}

class YHRefreshFooter : YHRefreshComponent {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        state = YHRefreshState.Normal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if let view = newSuperview as? UIScrollView {
            superview?.removeObserver(self, forKeyPath: yh_RefreshContentOffsetKey)
            superview?.removeObserver(self, forKeyPath: yh_RefreshContentSizeKey)
            
            scrollView = view
            
            frame = CGRect(x: 0, y: scrollView.contentSize.height, width: yh_ScreenW, height: yh_RefreshHeaderHeight)
            
            scrollView.addObserver(self, forKeyPath: yh_RefreshContentOffsetKey, options: [], context: nil)
            scrollView.addObserver(self, forKeyPath: yh_RefreshContentSizeKey, options: [], context: nil)
        }
    }
    
    class func footer(target:AnyObject?,selector:Selector?) -> AnyObject {
        let footer = self.init()
        footer.target = target
        footer.selector = selector
        return footer
    }
    
    class func footer(handler:(Void -> ())) -> AnyObject {
        let footer = self.init()
        footer.handler = handler
        return footer
    }
    
    func showNoMoreData() {
        state = .NoMoreData
    }
    
}

class YHRefreshNormalFooter : YHRefreshFooter {
    
    override var state : YHRefreshState {
        didSet {
            
            switch state {
                
            case .Normal:
                
                loadingView.hidden = true
                arrowView.hidden = false
                messageLabel.text = updateTime == nil ? yh_Titles[3] : yh_Titles[3] + "\n" + yh_Titles[5] + updateTime!.stringFromDate().timeStateForRefresh()
                
                loadingView.layer.removeAllAnimations()
                
                UIImageView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                    self.arrowView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI - 0.0001))
                })
                
                if currentState == .Refreshing {
                    UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                        self.scrollView?.contentInset.bottom -= yh_RefreshFooterHeight
                    })
                }
                
            case .WillRefresh:
                
                messageLabel.text = updateTime == nil ? yh_Titles[1] : yh_Titles[1] + "\n" + yh_Titles[5] + updateTime!.stringFromDate().timeStateForRefresh()
                
                UIImageView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                    self.arrowView.transform = CGAffineTransformIdentity
                })
                
            case .Refreshing:
                
                loadingView.hidden = false
                arrowView.hidden = true
                messageLabel.text = yh_Titles[2] + "\n" + yh_Titles[5] + yh_Titles[6] + "\(NSDate().stringFromDate("HH : mm"))"
                updateTime = NSDate()
                
                let ani = CABasicAnimation(keyPath: "transform.rotation")
                ani.toValue = 2 * M_PI
                ani.duration = 0.75
                ani.repeatCount = MAXFLOAT
                ani.removedOnCompletion = false
                loadingView.layer.addAnimation(ani, forKey: "")
                
                UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                    self.scrollView?.contentInset.bottom += yh_RefreshFooterHeight
                    }, completion: { (_) -> Void in
                        if let _ = self.handler {
                            self.handler!()
                        }
                        if let _ = self.selector {
                            self.target?.performSelector(self.selector!)
                        }
                })
                
            case .NoMoreData :
                
                scrollView?.contentInset.bottom += yh_RefreshFooterHeight
                activityIndicator.stopAnimating()
                arrowView.hidden = true
                loadingView.hidden = true
                messageLabel.hidden = false
                messageLabel.text = yh_Titles[4]
            }
            
            currentState = state
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(arrowView)
        addSubview(loadingView)
        addSubview(messageLabel)
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: arrowView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -yh_ViewMargin))
        addConstraint(NSLayoutConstraint(item: arrowView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: loadingView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: arrowView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: loadingView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: arrowView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        arrowView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI + 0.0001))
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == yh_RefreshContentSizeKey {
            if scrollView.contentSize.height >= yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top {
                frame = CGRect(x: 0, y: scrollView.contentSize.height, width: yh_ScreenW, height: yh_RefreshFooterHeight)
            }else {
                frame = CGRect(x: 0, y: yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top, width: yh_ScreenW, height: yh_RefreshFooterHeight)
            }
        }
        
        if state == .NoMoreData {
            return
        }
        
        if keyPath == yh_RefreshContentOffsetKey {
            if let dragging = scrollView?.dragging {
                if dragging == true {
                    if scrollView.contentSize.height >= yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top {
                        if scrollView?.contentOffset.y < scrollView.contentSize.height - yh_ScreenH + scrollView.contentInset.bottom + yh_RefreshFooterHeight && state != .Normal  && state != .Refreshing {
                            state = .Normal
                        } else if scrollView?.contentOffset.y >= scrollView.contentSize.height - yh_ScreenH + scrollView.contentInset.bottom + yh_RefreshFooterHeight && state != .WillRefresh && state != .Refreshing {
                            state = .WillRefresh
                        }
                        
                    }else {
                        if scrollView.contentOffset.y < yh_RefreshFooterHeight - scrollView.contentInset.top  && state != .Refreshing {
                            state = .Normal
                        } else if scrollView.contentOffset.y >= yh_RefreshFooterHeight - scrollView.contentInset.top && state != .WillRefresh && state != .Refreshing {
                            state = .WillRefresh
                        }
                    }
                }else {
                    if state == .WillRefresh {
                        state = .Refreshing
                    }
                }
            }
        }
    }
    
}

class YHRefreshAutoFooter : YHRefreshFooter {
    
    override var state : YHRefreshState {
        didSet {
            switch state {
                
            case .Normal:
                
                activityIndicator.stopAnimating()
                
                if currentState == .Refreshing {
                    UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                        self.scrollView?.contentInset.bottom -= yh_RefreshFooterHeight
                    })
                }
                
            case .Refreshing:
                
                activityIndicator.startAnimating()
                
                UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                    self.scrollView?.contentInset.bottom += yh_RefreshFooterHeight
                    }, completion: { (_) -> Void in
                        if let _ = self.handler {
                            self.handler!()
                        }
                        if let _ = self.selector {
                            self.target?.performSelector(self.selector!)
                        }
                })
                
            case .NoMoreData :
                
                scrollView?.contentInset.bottom += yh_RefreshFooterHeight
                activityIndicator.stopAnimating()
                arrowView.hidden = true
                loadingView.hidden = true
                messageLabel.hidden = false
                messageLabel.text = yh_Titles[4]
                
            default : break
                
            }
            
            currentState = state
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(activityIndicator)
        addSubview(messageLabel)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.hidden = true
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == yh_RefreshContentSizeKey {
            hidden = scrollView.contentSize.height < yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top
            frame = CGRect(x: 0, y: scrollView.contentSize.height, width: yh_ScreenW, height: yh_RefreshFooterHeight)
        }
        
        if state == .NoMoreData {
            return
        }
        
        if scrollView.contentSize.height != 0 && scrollView?.contentOffset.y > 0 && scrollView?.contentOffset.y > scrollView.contentSize.height - yh_ScreenH + scrollView.contentInset.bottom && state != .Refreshing {
            state = .Refreshing
        }
    }
    
}

class YHRefreshGifFooter : YHRefreshFooter {
    
    override var state : YHRefreshState {
        didSet {
            
            switch state {
                
            case .Normal:
                
                messageLabel.text = updateTime == nil ? yh_Titles[3] : yh_Titles[3] + "\n" + yh_Titles[5] + updateTime!.stringFromDate().timeStateForRefresh()
                
                if currentState == .Refreshing {
                    UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                        self.scrollView?.contentInset.bottom -= yh_RefreshFooterHeight
                    })
                    gifView.stopAnimating()
                }
                
                if currentState == .WillRefresh {
                    gifView.stopAnimating()
                }
                
            case .WillRefresh:
                
                messageLabel.text = updateTime == nil ? yh_Titles[1] : yh_Titles[1] + "\n" + yh_Titles[5] + updateTime!.stringFromDate().timeStateForRefresh()
                
                let images = stateImages[state.rawValue]
                
                if let _ = images {
                    if images!.count == 1 {
                        gifView.image = images!.first
                    }else {
                        gifView.animationImages = images
                        gifView.animationDuration = stateDurations[state.rawValue]!
                        gifView.startAnimating()
                    }
                }
                
            case .Refreshing:
                
                messageLabel.text = yh_Titles[2] + "\n" + yh_Titles[5] + yh_Titles[6] + "\(NSDate().stringFromDate("HH : mm"))"
                updateTime = NSDate()
                
                let images = stateImages[state.rawValue]
                
                if let _ = images {
                    if images!.count == 1 {
                        gifView.image = images!.first
                    }else {
                        gifView.animationImages = images
                        gifView.animationDuration = stateDurations[state.rawValue]!
                        gifView.startAnimating()
                    }
                }
                
                UIView.animateWithDuration(yh_AnimationDuration, animations: { () -> Void in
                    self.scrollView.contentInset.bottom += yh_RefreshFooterHeight
                    }, completion: { (_) -> Void in
                        if let _ = self.handler {
                            self.handler!()
                        }
                        if let _ = self.selector {
                            self.target?.performSelector(self.selector!)
                        }
                })
                
            default : break
                
            }
            
            currentState = state
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(gifView)
        addSubview(messageLabel)
        
        gifView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: gifView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -yh_ViewMargin))
        addConstraint(NSLayoutConstraint(item: gifView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == yh_RefreshContentSizeKey {
            if scrollView.contentSize.height >= yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top {
                frame = CGRect(x: 0, y: scrollView.contentSize.height, width: yh_ScreenW, height: yh_RefreshFooterHeight)
            }else {
                frame = CGRect(x: 0, y: yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top, width: yh_ScreenW, height: yh_RefreshFooterHeight)
            }
        }
        
        if state == .NoMoreData {
            return
        }
        
        if keyPath == yh_RefreshContentOffsetKey {
            if let dragging = scrollView?.dragging {
                if dragging == true {
                    if scrollView.contentSize.height >= yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top {
                        if scrollView?.contentOffset.y < scrollView.contentSize.height - yh_ScreenH + scrollView.contentInset.bottom + yh_RefreshFooterHeight && state != .Normal  && state != .Refreshing {
                            state = .Normal
                        } else if scrollView?.contentOffset.y >= scrollView.contentSize.height - yh_ScreenH + scrollView.contentInset.bottom + yh_RefreshFooterHeight && state != .WillRefresh && state != .Refreshing {
                            state = .WillRefresh
                        }
                        
                    }else {
                        if scrollView.contentOffset.y < yh_RefreshFooterHeight - scrollView.contentInset.top  && state != .Refreshing {
                            state = .Normal
                        } else if scrollView.contentOffset.y >= yh_RefreshFooterHeight - scrollView.contentInset.top  && state != .WillRefresh && state != .Refreshing {
                            state = .WillRefresh
                        }
                    }
                }else {
                    if state == .WillRefresh {
                        state = .Refreshing
                    }
                }
            }
            
            if state == .Normal {
                if scrollView.contentSize.height >= yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top {
                    pullingPercent = (scrollView.contentOffset.y - scrollView.contentSize.height + yh_ScreenH - scrollView.contentInset.bottom) / yh_RefreshFooterHeight
                } else {
                    pullingPercent = (scrollView.contentOffset.y + scrollView.contentInset.top) / yh_RefreshFooterHeight
                }
                let images = stateImages[state.rawValue]
                if let _ = images where pullingPercent<=1 && pullingPercent>=0 {
                    if images!.count == 1 {
                        gifView.image = images!.first
                    }else {
                        gifView.image = stateImages[state.rawValue]![Int(CGFloat(images!.count - 1) * pullingPercent)]
                    }
                }
            }
        }
        
    }
    
    private var pullingPercent : CGFloat!
    
    private lazy var gifView = UIImageView()
    
    private lazy var stateImages = [String : [UIImage]]()
    
    private lazy var stateDurations = [String : NSTimeInterval]()
    
    func setGifFooter(images:[UIImage],duration:NSTimeInterval,state:YHRefreshState) {
        stateImages[state.rawValue] = images
        stateDurations[state.rawValue] = duration
    }
    
    func setGifFooter(images:[UIImage],state:YHRefreshState) {
        stateImages[state.rawValue] = images
        stateDurations[state.rawValue] = Double(images.count) * 0.1
    }
    
}

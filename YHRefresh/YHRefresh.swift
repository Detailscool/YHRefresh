//
//  YHRefresh.swift
//
//  Created by Detailscool on 16/4/1.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

// MARK: - YHRefreshComponent
open class YHRefreshComponent: UIView {
    
    fileprivate weak var scrollView: UIScrollView?
    
    fileprivate weak var target: AnyObject?
    
    fileprivate var selector: Selector?
    
    fileprivate var handler: YHRefreshHandler?
    
    fileprivate var oldState  = YHRefreshState.normal
    
    fileprivate var state = YHRefreshState.normal
    
    fileprivate var updateTime: Date?
    
    fileprivate lazy var stateTitles = [YHRefreshState: String]()
    
    fileprivate lazy var loadingView: UIImageView = {
        let imagePath = Bundle(for:type(of: self)).path(forResource: "/YHRefresh.bundle/YHRefresh_loading.png", ofType: nil)
        let image = UIImage(contentsOfFile:imagePath!)
        let iv = UIImageView(image: image)
        iv.isHidden = true
        return iv
    }()
    
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.color = UIColor.black
        ai.hidesWhenStopped = true
        return ai
    }()
    
    fileprivate lazy var arrowView: UIImageView = {
        let imagePath = Bundle(for:type(of: self)).path(forResource: "/YHRefresh.bundle/YHRefresh_arrow.png", ofType: nil)
        let image = UIImage(contentsOfFile: imagePath!)
        let iv = UIImageView(image: image)
        return iv
    }()
    
    open func endRefreshing() {
        state = .normal
    }
    
    open var isRefreshing: Bool {
        get{
            return state == .refreshing
        }
    }
    
    open func setTitles(title: String , forState state: YHRefreshState) {
        self.stateTitles[state] = title
    }
    
    fileprivate func titles(forState state: YHRefreshState, statement: String) -> String {
        if let title = self.stateTitles[state] {
            return  updateTime == nil ? title: title + "\n" + yh_Titles[5] + updateTime!.stringFromDate().timeStateForRefresh()
        }else {
            return  updateTime == nil ? statement: statement + "\n" + yh_Titles[5] + updateTime!.stringFromDate().timeStateForRefresh()
        }
    }
}

// MARK: - YHRefreshHeader
open class YHRefreshHeader: YHRefreshComponent {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        state = YHRefreshState.normal
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let view = newSuperview as? UIScrollView {
            scrollView?.removeObserver(self, forKeyPath: yh_RefreshContentOffsetKey)
            scrollView?.removeObserver(self, forKeyPath: yh_RefreshContentSizeKey)
            
            scrollView = view
            
            scrollView!.addObserver(self, forKeyPath: yh_RefreshContentOffsetKey, options: [], context: nil)
            scrollView!.addObserver(self, forKeyPath: yh_RefreshContentSizeKey, options: [], context: nil)
        }
    }
    
    open class func header(_ target:AnyObject?,selector:Selector?) -> Self {
        let header = self.init()
        header.target = target
        header.selector = selector
        return header
    }
    
    open class func header(_ handler:@escaping (() -> ())) -> Self {
        let header = self.init()
        header.handler = handler
        return header
    }
    
    open func beginRefreshing() {
        state = .refreshing
    }
    
}

// MARK: - YHRefreshNormalHeader
open class YHRefreshNormalHeader: YHRefreshHeader {
    
    override var state: YHRefreshState {
        didSet {
            
            switch state {
            
            case .normal:
                
                loadingView.isHidden = true
                arrowView.isHidden = false
                messageLabel.text = titles(forState: .normal, statement: yh_Titles[0])
                
                loadingView.layer.removeAllAnimations()
                
                UIImageView.animate(withDuration: yh_AnimationDuration, animations: {
                    self.arrowView.transform = CGAffineTransform.identity
                })
                
                if oldState == .refreshing {
                    UIView.animate(withDuration: yh_AnimationDuration, animations: {
                        self.scrollView?.contentInset.top -= yh_RefreshHeaderHeight
                    })
                }
                
            case .willRefresh:
                
                messageLabel.text = titles(forState: .willRefresh, statement: yh_Titles[1])
                
                UIImageView.animate(withDuration: yh_AnimationDuration, animations: {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi - 0.0001))
                })
                
            case .refreshing:
                
                loadingView.isHidden = false
                arrowView.isHidden = true
                messageLabel.text = yh_Titles[2] + "\n" + yh_Titles[5] + yh_Titles[6] + "\(Date().stringFromDate("HH: mm"))"
                updateTime = Date()
                
                let ani = CABasicAnimation(keyPath: yh_RefreshRotationKey)
                ani.toValue = 2 * Double.pi
                ani.duration = 0.75
                ani.repeatCount = MAXFLOAT
                ani.isRemovedOnCompletion = false
                loadingView.layer.add(ani, forKey: "")
                
                UIView.animate(withDuration: yh_AnimationDuration, animations: {
                    self.scrollView?.contentInset.top += yh_RefreshHeaderHeight
                }, completion: { _ in
                    self.handler?()
                    
                    if let selector = self.selector {
                        _ = self.target?.perform(selector)
                    }
                })
                
            default: break
                
            }
            
            oldState = state
        }
    }
    
    override init(frame: CGRect) {
        var frame = frame
        frame = CGRect(x: 0, y: -yh_RefreshHeaderHeight, width: yh_ScreenW, height: yh_RefreshHeaderHeight)
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        backgroundColor = UIColor.clear
        
        addSubview(arrowView)
        addSubview(loadingView)
        addSubview(messageLabel)
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem:self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: arrowView, attribute: .trailing, relatedBy: .equal, toItem: messageLabel, attribute: .leading, multiplier: 1, constant: -yh_ViewMargin))
        addConstraint(NSLayoutConstraint(item: arrowView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: arrowView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: arrowView, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let scrollView = scrollView else {
            return;
        }
        
        if scrollView.isDragging {
            if scrollView.contentOffset.y > -scrollView.contentInset.top - yh_RefreshHeaderHeight, state == .normal, state != .refreshing {
                state = .normal
            } else if scrollView.contentOffset.y <= -scrollView.contentInset.top - yh_RefreshHeaderHeight, state != .willRefresh, state != .refreshing {
                state = .willRefresh
            }
        } else {
            if state == .willRefresh {
                state = .refreshing
            }
        }
    }
    
}

// MARK: - YHRefreshSpringHeader
open class YHRefreshSpringHeader: YHRefreshHeader {
    
    override var state: YHRefreshState {
        didSet {
            
            switch state {
            
            case .normal:
                
                activityIndicator.stopAnimating()
                
                springView.isHidden = false
                
                if oldState == .refreshing {
                    UIView.animate(withDuration: yh_AnimationDuration, animations: {
                        self.scrollView?.contentInset.top -= yh_SpringHeaderHeight
                    })
                }
                
            case .refreshing:
                
                springView.isHidden = true
                
                activityIndicator.startAnimating()
                
                UIView.animate(withDuration: yh_AnimationDuration, animations: {
                    self.scrollView?.contentInset.top += yh_SpringHeaderHeight
                }, completion: { _ in
                    self.handler?()
                    
                    if let selector = self.selector {
                        _ = self.target?.perform(selector)
                    }
                })
                
            default:break
                
            }
            
            oldState = state
        }
    }
    
    override init(frame: CGRect) {
        var frame = frame
        frame = CGRect(x: 0, y: -yh_SpringHeaderHeight, width: yh_ScreenW, height: yh_SpringHeaderHeight)
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        backgroundColor = UIColor.clear
        
        addSubview(springView)
        addSubview(activityIndicator)
        
        springView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: springView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: springView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        springView.addConstraint(NSLayoutConstraint(item: springView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: yh_SpringHeaderHeight))
        springView.addConstraint(NSLayoutConstraint(item: springView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: yh_RefreshHeaderHeight))
        
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let scrollView = scrollView else {
            return;
        }
        
        if scrollView.isDragging {
            springView.progress = 0
        }
        
        let factor: CGFloat =  1
        
        if scrollView.contentOffset.y <= -scrollView.contentInset.top - yh_SpringHeaderHeight, state != .refreshing{
            state = .refreshing
        }
        
        if state != .refreshing, scrollView.contentOffset.y <= -scrollView.contentInset.top - yh_RefreshHeaderHeight * factor {
            let progress = -(scrollView.contentOffset.y + scrollView.contentInset.top + yh_RefreshHeaderHeight * factor)/(yh_SpringHeaderHeight - yh_RefreshHeaderHeight * factor)
            springView.progress = progress
        }
    }
    
    fileprivate lazy var springView: YHRefreshSpringView = YHRefreshSpringView()
    
    class YHRefreshSpringView: UIView {
        
        var factor: CGFloat = 2.8
        
        var endFactor1: CGFloat = 0.4
        var endFactor2: CGFloat = 0.8
        
        var progress: CGFloat = 0.0 {
            didSet {
                if progress > 1 || progress < 0 {
                    return
                }
                
                center2.y = frame.height - (frame.height/factor)*(1 + (factor - 1 - endFactor2) * progress)
                radius1 = (min(frame.width, frame.height)/factor) * (1 - (1 - endFactor1) * progress) //(0.6 * pow((progress! - 1),10) + 0.4)
                center1.y = frame.height - (frame.height/factor)*(1 - (1 - endFactor1) * progress)
                radius2 = (min(frame.width, frame.height)/factor) * (1 - (1 - endFactor2) * progress)
                
                setNeedsDisplay()
                
            }
        }
        
        fileprivate var center1: CGPoint!
        fileprivate var center2: CGPoint!
        fileprivate var radius1: CGFloat!
        fileprivate var radius2: CGFloat!
        
        fileprivate var arcPoint1: CGPoint!
        fileprivate var arcPoint2: CGPoint!
        
        fileprivate var arcPoint3: CGPoint!
        fileprivate var arcPoint4: CGPoint!
        
        fileprivate var controlPiont: CGPoint!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        fileprivate func setup() {
            backgroundColor = UIColor.clear
            
            radius1 = min(frame.width, frame.height)/factor
            radius2 = min(frame.width, frame.height)/factor
            
            center1 = CGPoint(x: frame.width/2, y: frame.height*(factor - 1)/factor)
            center2 = CGPoint(x: frame.width/2, y: frame.height*(factor - 1)/factor)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setup()
        }
        
        var sizeFactor: CGFloat = 1.3
        
        override func draw(_ rect: CGRect) {
            guard let imagePath = Bundle(for:type(of: self)).path(forResource: "/YHRefresh.bundle/YHRefresh_load.png", ofType: nil) else {
                return
            }
            
            let ctx = UIGraphicsGetCurrentContext()
            ctx?.addArc(center: CGPoint(x: center1.x, y: center1.y), radius: radius1, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            ctx?.setFillColor(UIColor.gray.cgColor)
            ctx?.fillPath()
            
            ctx?.addArc(center: CGPoint(x: center2.x, y: center2.y), radius: radius2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            ctx?.setFillColor(UIColor.gray.cgColor)
            ctx?.fillPath()
            
            if !isSameCerter() {
                
                calculateTangent()
                
                ctx?.move(to: CGPoint(x: arcPoint1.x, y: arcPoint1.y))
                //            CGContextAddQuadCurveToPoint(ctx, controlPiont.x + radius2, controlPiont.y, arcPoint3.x, arcPoint3.y)
                ctx?.addLine(to: CGPoint(x: arcPoint3.x, y: arcPoint3.y))
                ctx?.addLine(to: CGPoint(x: arcPoint4.x, y: arcPoint4.y))
                //            CGContextAddQuadCurveToPoint(ctx, controlPiont.x - radius2, controlPiont.y, arcPoint2.x, arcPoint2.y)
                ctx?.addLine(to: CGPoint(x: arcPoint2.x, y: arcPoint2.y))
                
                ctx?.closePath()
                ctx?.fillPath()
            }
            
            let image = UIImage(contentsOfFile: imagePath)
            image?.draw(in: CGRect(x: center2.x - radius2 * (sizeFactor / 2), y: center2.y - radius2 * (sizeFactor / 2), width: sizeFactor * radius2, height: sizeFactor * radius2))
            
        }
        
        fileprivate func isSameCerter() -> Bool {
            return center1 == center2
        }
        
        fileprivate func calculateTangent() {
            
            let centerDistance = sqrt(pow((center1.x - center2.x), 2) + pow((center1.y - center2.y), 2))
            let radiusGap = abs(radius1 - radius2)
            let angle = acos(radiusGap / centerDistance)
            
            arcPoint1 = CGPoint(x: radius1 * sin(angle) + center1.x, y: -radius1 * cos(angle) + center1.y)
            arcPoint2 = CGPoint(x: -radius1 * sin(angle) + center1.x, y: -radius1 * cos(angle) + center1.y)
            arcPoint3 = CGPoint(x: radius2 * sin(angle) + center2.x, y: -radius2 * cos(angle) + center2.y)
            arcPoint4 = CGPoint(x: -radius2 * sin(angle) + center2.x, y: -radius2 * cos(angle) + center2.y)
            
            let a = centerDistance > 2 * (radius1 + radius2)
            let b = center1.y + abs(centerDistance - radius1 - radius2)
            let c = abs(center2.y + center1.y)/2
            let controlY = a ? b: c
            
            controlPiont = CGPoint(x: abs(center2.x + center1.x)/2, y: controlY)
            
        }
    }
    
}

// MARK: - YHRefreshGifHeader
open class YHRefreshGifHeader: YHRefreshHeader {
    
    override var state: YHRefreshState {
        didSet {
            
            switch state {
            
            case .normal:
                
                messageLabel.text = titles(forState: .normal, statement: yh_Titles[0])
                
                if oldState == .refreshing {
                    UIView.animate(withDuration: yh_AnimationDuration, animations: {
                        self.scrollView?.contentInset.top -= yh_RefreshHeaderHeight
                    })
                    gifView.stopAnimating()
                }
                
                if oldState == .willRefresh {
                    gifView.stopAnimating()
                }
                
            case .willRefresh:
                
                messageLabel.text = titles(forState: .willRefresh, statement: yh_Titles[1])
                
                if let images = stateImages[state.rawValue], let duration = stateDurations[state.rawValue] {
                    if images.count == 1 {
                        gifView.image = images.first
                    } else {
                        gifView.animationImages = images
                        gifView.animationDuration = duration
                        gifView.startAnimating()
                    }
                }
                
            case .refreshing:
                
                messageLabel.text = yh_Titles[2] + "\n" + yh_Titles[5] + yh_Titles[6] + "\(Date().stringFromDate("HH: mm"))"
                updateTime = Date()
                
                if let images = stateImages[state.rawValue], let duration = stateDurations[state.rawValue] {
                    if images.count == 1 {
                        gifView.image = images.first
                    } else {
                        gifView.animationImages = images
                        gifView.animationDuration = duration
                        gifView.startAnimating()
                    }
                }
                
                UIView.animate(withDuration: yh_AnimationDuration, animations: {
                    self.scrollView?.contentInset.top += yh_RefreshHeaderHeight
                }, completion: { _ in
                    self.handler?()
                    
                    if let selector = self.selector {
                        _ = self.target?.perform(selector)
                    }
                })
                
            default: break
                
            }
            
            oldState = state
        }
    }
    
    override init(frame: CGRect) {
        var frame = frame
        frame = CGRect(x: 0, y: -yh_RefreshHeaderHeight, width: yh_ScreenW, height: yh_RefreshHeaderHeight)
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        backgroundColor = UIColor.clear
        
        addSubview(gifView)
        addSubview(messageLabel)
        
        gifView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: gifView, attribute: .trailing, relatedBy: .equal, toItem: messageLabel, attribute: .leading, multiplier: 1, constant: -yh_ViewMargin))
        addConstraint(NSLayoutConstraint(item: gifView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let scrollView = scrollView else {
            return
        }
        
        if scrollView.isDragging {
            if scrollView.contentOffset.y > -scrollView.contentInset.top - yh_RefreshHeaderHeight, state != .normal, state != .refreshing {
                state = .normal
            } else if scrollView.contentOffset.y <= -scrollView.contentInset.top - yh_RefreshHeaderHeight, state != .willRefresh, state != .refreshing {
                state = .willRefresh
            }
        } else {
            if state == .willRefresh {
                state = .refreshing
            }
        }
        
        if state == .normal {
            pullingPercent = (scrollView.contentOffset.y + scrollView.contentInset.top) / (-yh_RefreshHeaderHeight)
            
            if let images = stateImages[state.rawValue], pullingPercent<=1, pullingPercent>=0 {
                if images.count == 1 {
                    gifView.image = images.first
                } else {
                    gifView.image = images[Int(CGFloat(images.count - 1) * pullingPercent)]
                }
            }
        }
        
    }
    
    fileprivate var pullingPercent: CGFloat!
    
    fileprivate lazy var gifView = UIImageView()
    
    fileprivate lazy var stateImages = [String: [UIImage]]()
    
    fileprivate lazy var stateDurations = [String: TimeInterval]()
    
    open func setGifHeader(_ images:[UIImage],duration:TimeInterval,state:YHRefreshState) {
        stateImages[state.rawValue] = images
        stateDurations[state.rawValue] = duration
    }
    
    open func setGifHeader(_ images:[UIImage],state:YHRefreshState) {
        stateImages[state.rawValue] = images
        stateDurations[state.rawValue] = Double(images.count) * 0.1
    }
    
}

// MARK: - YHRefreshMaterialHeader
open class YHRefreshMaterialHeader: YHRefreshHeader,UIGestureRecognizerDelegate {
    
    open var shouldStayOnWindow: Bool = false
    
    override var state: YHRefreshState {
        didSet {
            
            switch state {
            
            case .normal:
                
                guard let _ = scrollView else {
                    remove()
                    return
                }
                
                if frame.origin.y == -yh_RefreshHeaderHeight {
                    return
                }
                
                materialView.layer.removeAllAnimations()
                
                if !shouldStayOnWindow {
                    UIView.animate(withDuration: yh_AnimationDuration, animations: {
                        self.frame.origin.y = -yh_RefreshHeaderHeight
                    }, completion: { _ in
                        self.animating = false
                    })
                } else {
                    displayLink = CADisplayLink(target: self, selector: #selector(self.materailViewBackToNormal))
                    displayLink!.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
                }
                
            case .refreshing:
                let ani = CABasicAnimation(keyPath: yh_RefreshRotationKey)
                ani.toValue = 2 * Double.pi
                ani.duration = 0.75
                ani.repeatCount = MAXFLOAT
                ani.isRemovedOnCompletion = false
                animating = true
                materialView.layer.add(ani, forKey: "")
                
                self.handler?()
                
                if let selector = self.selector {
                    _ = self.target?.perform(selector)
                }
                
            default:break
                
            }
            
            oldState = state
        }
    }
    
    @objc fileprivate func materailViewBackToNormal() {
        frame.origin.y -= (yh_MaterialMaxOffset + yh_RefreshHeaderHeight)/CGFloat(yh_AnimationDuration)/60
        if frame.origin.y <= -yh_RefreshHeaderHeight {
            displayLink!.invalidate()
            displayLink!.remove(from: RunLoop.current, forMode: RunLoop.Mode.common)
            displayLink = nil
            animating = false
        }
    }
    
    fileprivate lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panResponse(_:)))
        pan.delegate = self
        return pan
    }()
    
    override init(frame: CGRect) {
        var frame = frame
        frame = CGRect(x: 0, y: -yh_RefreshHeaderHeight, width: yh_ScreenW, height: yh_RefreshHeaderHeight)
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if scrollView != nil {
            scrollView!.bounces = false
        }
    }
    
    fileprivate func setup() {
        
        backgroundColor = UIColor.clear
        
        addSubview(materialView)
        
        materialView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: materialView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: materialView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        materialView.addConstraint(NSLayoutConstraint(item: materialView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: yh_RefreshHeaderHeight))
        materialView.addConstraint(NSLayoutConstraint(item: materialView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: yh_RefreshHeaderHeight))
        
        self.addObserver(self, forKeyPath: yh_RefreshFrameKey, options: [], context: nil)
    }
    
    @objc func panResponse(_ pan:UIPanGestureRecognizer) {
        
        if animating {
            return
        }
        
        guard let scrollView = scrollView else {
            return;
        }
        
        frame.origin.y = min((!shouldStayOnWindow ? -yh_RefreshHeaderHeight: (shouldOutted ? outerMargin: -yh_RefreshHeaderHeight)) + pan.translation(in: scrollView).y, yh_MaterialMaxOffset + scrollView.contentInset.top)
        
        if pan.state == .ended, frame.origin.y == yh_MaterialMaxOffset + scrollView.contentInset.top {
            state = .refreshing
        }
        
        if pan.state == .ended, frame.origin.y < yh_MaterialMaxOffset + scrollView.contentInset.top {
            state = .normal
        }
    }
    
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let scrollView = scrollView, gestureRecognizer.isEqual(panGesture) {
            if panGesture.translation(in: scrollView).y < 0 {
                scrollView.removeGestureRecognizer(panGesture)
            }
        }
        return true
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let object = object, let keyPath = keyPath else {
            return
        }
        
        guard let scrollView = scrollView else {
            remove()
            return
        }
        
        if shouldStayOnWindow {
            if (object as AnyObject).isEqual(self), keyPath == yh_RefreshFrameKey {
                if frame.origin.y > 0, scrollView.contentOffset.y <= scrollView.contentInset.top, !shouldOutted, !animating, !scrollView.isDragging {
                    shouldOutted = true
                    let view = self;
                    let newFrame = convert(bounds, to: nil)
                    outerMargin = newFrame.origin.y - panGesture.translation(in: scrollView).y
                    self.removeFromSuperview()
                    UIApplication.shared.keyWindow!.addSubview(view)
                    frame = newFrame
                }
                
                if shouldOutted, convert(bounds, to: nil).origin.y < scrollView.contentInset.top + scrollView.convert(scrollView.bounds, to: nil).origin.y {
                    shouldOutted = false
                    let view = self;
                    let newFrame = convert(bounds, to: scrollView)
                    self.removeFromSuperview()
                    scrollView.addSubview(view)
                    frame = newFrame
                }
                
                if !shouldOutted, animating, convert(bounds, to: nil).origin.y < scrollView.contentInset.top - frame.height + scrollView.convert(scrollView.bounds, to: nil).origin.y, frame.origin.y != -yh_RefreshHeaderHeight {
                    frame.origin.y = -yh_RefreshHeaderHeight
                }
            }
        }
        
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            if let gestureRecognizers = scrollView.gestureRecognizers, !gestureRecognizers.contains(panGesture) {
                scrollView.addGestureRecognizer(panGesture)
            }
        }
    }
    
    fileprivate func remove() {
        if let _ = displayLink {
            displayLink!.invalidate()
            displayLink!.remove(from: RunLoop.current, forMode: RunLoop.Mode.common)
            displayLink = nil
        }
        removeFromSuperview()
    }
    
    deinit {
        remove()
        self.removeObserver(self, forKeyPath: yh_RefreshFrameKey)
    }
    
    fileprivate var shouldOutted: Bool = false
    fileprivate var outerMargin: CGFloat!
    fileprivate var animating: Bool = false
    fileprivate var displayLink: CADisplayLink?
    fileprivate lazy var materialView: YHRefreshMaterialView = YHRefreshMaterialView()
    
    class YHRefreshMaterialView: UIView {
        
        var progress: CGFloat = 0.0 {
            didSet {
                if progress > 1 || progress < 0 {
                    return
                }
                
                setNeedsDisplay()
            }
        }
        
        fileprivate var circleCenter: CGPoint!
        fileprivate var radius: CGFloat!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        fileprivate func setup() {
            backgroundColor = UIColor.clear
            
            radius = min(frame.width, frame.height)/2
            circleCenter = CGPoint(x: frame.width/2, y: frame.height/2)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setup()
        }
        
        var sizeFactor: CGFloat = 1.3
        
        override func draw(_ rect: CGRect) {
            
            let ctx = UIGraphicsGetCurrentContext()
            ctx?.addArc(center: CGPoint(x: circleCenter.x, y: circleCenter.y), radius: radius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            ctx?.setFillColor(UIColor.gray.cgColor)
            ctx?.fillPath()
            
            let imagePath = Bundle(for:type(of: self)).path(forResource: "/YHRefresh.bundle/YHRefresh_load.png", ofType: nil)
            let image = UIImage(contentsOfFile: imagePath!)
            
            image?.draw(in: CGRect(x: circleCenter.x - radius * (sizeFactor / 2), y: circleCenter.y - radius * (sizeFactor / 2), width: sizeFactor * radius, height: sizeFactor * radius))
            
        }
    }
}

// MARK: - YHRefreshFooter
open class YHRefreshFooter: YHRefreshComponent {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        state = YHRefreshState.normal
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let view = newSuperview as? UIScrollView {
            scrollView?.removeObserver(self, forKeyPath: yh_RefreshContentOffsetKey)
            scrollView?.removeObserver(self, forKeyPath: yh_RefreshContentSizeKey)
            
            scrollView = view
            
            frame = CGRect(x: 0, y: scrollView!.contentSize.height, width: yh_ScreenW, height: yh_RefreshHeaderHeight)
            
            scrollView!.addObserver(self, forKeyPath: yh_RefreshContentOffsetKey, options: [], context: nil)
            scrollView!.addObserver(self, forKeyPath: yh_RefreshContentSizeKey, options: [], context: nil)
        }
    }
    
    open class func footer(_ target:AnyObject?,selector:Selector?) -> Self {
        let footer = self.init()
        footer.target = target
        footer.selector = selector
        return footer
    }
    
    open class func footer(_ handler:@escaping (() -> ())) -> Self {
        let footer = self.init()
        footer.handler = handler
        return footer
    }
    
    open func showNoMoreData() {
        state = .noMoreData
    }
    
}

// MARK: - YHRefreshNormalFooter
open class YHRefreshNormalFooter: YHRefreshFooter {
    
    override var state: YHRefreshState {
        didSet {
            
            switch state {
            
            case .normal:
                
                loadingView.isHidden = true
                arrowView.isHidden = false
                messageLabel.text = titles(forState: .normal, statement: yh_Titles[3])
                
                loadingView.layer.removeAllAnimations()
                
                UIImageView.animate(withDuration: yh_AnimationDuration, animations: {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi - 0.0001))
                })
                
                if oldState == .refreshing {
                    UIView.animate(withDuration: yh_AnimationDuration, animations: {
                        self.scrollView?.contentInset.bottom -= yh_RefreshFooterHeight
                    })
                }
                
            case .willRefresh:
                
                messageLabel.text = titles(forState: .willRefresh, statement: yh_Titles[1])
                
                UIImageView.animate(withDuration: yh_AnimationDuration, animations: {
                    self.arrowView.transform = CGAffineTransform.identity
                })
                
            case .refreshing:
                
                loadingView.isHidden = false
                arrowView.isHidden = true
                messageLabel.text = yh_Titles[2] + "\n" + yh_Titles[5] + yh_Titles[6] + "\(Date().stringFromDate("HH: mm"))"
                updateTime = Date()
                
                let ani = CABasicAnimation(keyPath: yh_RefreshRotationKey)
                ani.toValue = 2 * Double.pi
                ani.duration = 0.75
                ani.repeatCount = MAXFLOAT
                ani.isRemovedOnCompletion = false
                loadingView.layer.add(ani, forKey: "")
                
                UIView.animate(withDuration: yh_AnimationDuration, animations: {
                    self.scrollView?.contentInset.bottom += yh_RefreshFooterHeight
                }, completion: { _ in
                    self.handler?()
                    
                    if let selector = self.selector {
                        _ = self.target?.perform(selector)
                    }
                })
                
            case .noMoreData :
                
                scrollView?.contentInset.bottom += yh_RefreshFooterHeight
                activityIndicator.stopAnimating()
                arrowView.isHidden = true
                loadingView.isHidden = true
                messageLabel.isHidden = false
                messageLabel.text = yh_Titles[4]
            }
            
            oldState = state
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        backgroundColor = UIColor.clear
        
        addSubview(arrowView)
        addSubview(loadingView)
        addSubview(messageLabel)
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: arrowView, attribute: .trailing, relatedBy: .equal, toItem: messageLabel, attribute: .leading, multiplier: 1, constant: -yh_ViewMargin))
        addConstraint(NSLayoutConstraint(item: arrowView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: arrowView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: arrowView, attribute: .centerY, multiplier: 1, constant: 0))
        
        arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi + 0.0001))
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let _ = scrollView else {
            return
        }
        
        if keyPath == yh_RefreshContentSizeKey {
            if scrollView!.contentSize.height >= yh_ScreenH - scrollView!.contentInset.bottom - scrollView!.contentInset.top {
                frame = CGRect(x: 0, y: scrollView!.contentSize.height, width: yh_ScreenW, height: yh_RefreshFooterHeight)
            } else {
                frame = CGRect(x: 0, y: yh_ScreenH - scrollView!.contentInset.bottom - scrollView!.contentInset.top, width: yh_ScreenW, height: yh_RefreshFooterHeight)
            }
        }
        
        if state == .noMoreData {
            return
        }
        
        if keyPath == yh_RefreshContentOffsetKey {
            if let dragging = scrollView?.isDragging {
                if dragging == true {
                    if scrollView!.contentSize.height >= yh_ScreenH - scrollView!.contentInset.bottom - scrollView!.contentInset.top {
                        if scrollView!.contentOffset.y < scrollView!.contentSize.height - yh_ScreenH + scrollView!.contentInset.bottom + yh_RefreshFooterHeight, state != .normal , state != .refreshing {
                            state = .normal
                        } else if scrollView!.contentOffset.y >= scrollView!.contentSize.height - yh_ScreenH + scrollView!.contentInset.bottom + yh_RefreshFooterHeight, state != .willRefresh, state != .refreshing {
                            state = .willRefresh
                        }
                        
                    } else {
                        if scrollView!.contentOffset.y < yh_RefreshFooterHeight - scrollView!.contentInset.top, state != .refreshing {
                            state = .normal
                        } else if scrollView!.contentOffset.y >= yh_RefreshFooterHeight - scrollView!.contentInset.top, state != .willRefresh, state != .refreshing {
                            state = .willRefresh
                        }
                    }
                } else {
                    if state == .willRefresh {
                        state = .refreshing
                    }
                }
            }
        }
    }
    
}

// MARK: - YHRefreshAutoFooter
open class YHRefreshAutoFooter: YHRefreshFooter {
    
    override var state: YHRefreshState {
        didSet {
            switch state {
            
            case .normal:
                
                activityIndicator.stopAnimating()
                
                if oldState == .refreshing {
                    UIView.animate(withDuration: yh_AnimationDuration, animations: {
                        self.scrollView?.contentInset.bottom -= yh_RefreshFooterHeight
                    })
                }
                
            case .refreshing:
                
                activityIndicator.startAnimating()
                
                UIView.animate(withDuration: yh_AnimationDuration, animations: {
                    self.scrollView?.contentInset.bottom += yh_RefreshFooterHeight
                }, completion: { _ in
                    self.handler?()
                    
                    if let selector = self.selector {
                        _ = self.target?.perform(selector)
                    }
                })
                
            case .noMoreData :
                
                scrollView?.contentInset.bottom += yh_RefreshFooterHeight
                activityIndicator.stopAnimating()
                arrowView.isHidden = true
                loadingView.isHidden = true
                messageLabel.isHidden = false
                messageLabel.text = yh_Titles[4]
                
            default: break
                
            }
            
            oldState = state
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        backgroundColor = UIColor.clear
        
        addSubview(activityIndicator)
        addSubview(messageLabel)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.isHidden = true
        addConstraints([
            NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        ])
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let scrollView = scrollView else {
            return
        }
        
        if keyPath == yh_RefreshContentSizeKey {
            isHidden = scrollView.contentSize.height < yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top
            frame = CGRect(x: 0, y: scrollView.contentSize.height, width: yh_ScreenW, height: yh_RefreshFooterHeight)
        }
        
        if state == .noMoreData {
            return
        }
        
        if scrollView.contentSize.height != 0, scrollView.contentOffset.y > 0, scrollView.contentOffset.y > scrollView.contentSize.height - yh_ScreenH + scrollView.contentInset.bottom, state != .refreshing {
            state = .refreshing
        }
    }
    
}

// MARK: - YHRefreshGifFooter
open class YHRefreshGifFooter: YHRefreshFooter {
    
    override var state: YHRefreshState {
        didSet {
            
            switch state {
            
            case .normal:
                
                messageLabel.text = titles(forState: .normal, statement: yh_Titles[3])
                
                if oldState == .refreshing {
                    UIView.animate(withDuration: yh_AnimationDuration, animations: {
                        self.scrollView?.contentInset.bottom -= yh_RefreshFooterHeight
                    })
                    gifView.stopAnimating()
                }
                
                if oldState == .willRefresh {
                    gifView.stopAnimating()
                }
                
            case .willRefresh:
                
                messageLabel.text = titles(forState: .willRefresh, statement: yh_Titles[1])
                
                if let images = stateImages[state.rawValue] {
                    if images.count == 1 {
                        gifView.image = images.first
                    } else {
                        gifView.animationImages = images
                        gifView.animationDuration = stateDurations[state.rawValue]!
                        gifView.startAnimating()
                    }
                }
                
            case .refreshing:
                
                messageLabel.text = yh_Titles[2] + "\n" + yh_Titles[5] + yh_Titles[6] + "\(Date().stringFromDate("HH: mm"))"
                updateTime = Date()
                
                if let images = stateImages[state.rawValue], let duration = stateDurations[state.rawValue] {
                    if images.count == 1 {
                        gifView.image = images.first
                    } else {
                        gifView.animationImages = images
                        gifView.animationDuration = duration
                        gifView.startAnimating()
                    }
                }
                
                UIView.animate(withDuration: yh_AnimationDuration, animations: {
                    self.scrollView?.contentInset.bottom += yh_RefreshFooterHeight
                }, completion: { _ in
                    self.handler?()
                    
                    if let selector = self.selector {
                        _ = self.target?.perform(selector)
                    }
                })
                
            default: break
                
            }
            
            oldState = state
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        
        backgroundColor = UIColor.clear
        
        addSubview(gifView)
        addSubview(messageLabel)
        
        gifView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: gifView, attribute: .trailing, relatedBy: .equal, toItem: messageLabel, attribute: .leading, multiplier: 1, constant: -yh_ViewMargin))
        addConstraint(NSLayoutConstraint(item: gifView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let scrollView = scrollView else{
            return
        }
        
        if keyPath == yh_RefreshContentSizeKey {
            if scrollView.contentSize.height >= yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top {
                frame = CGRect(x: 0, y: scrollView.contentSize.height, width: yh_ScreenW, height: yh_RefreshFooterHeight)
            } else {
                frame = CGRect(x: 0, y: yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top, width: yh_ScreenW, height: yh_RefreshFooterHeight)
            }
        }
        
        if state == .noMoreData {
            return
        }
        
        if keyPath == yh_RefreshContentOffsetKey {
            if scrollView.isDragging {
                if scrollView.contentSize.height >= yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top {
                    if scrollView.contentOffset.y < scrollView.contentSize.height - yh_ScreenH + scrollView.contentInset.bottom + yh_RefreshFooterHeight, state != .normal , state != .refreshing {
                        state = .normal
                    } else if scrollView.contentOffset.y >= scrollView.contentSize.height - yh_ScreenH + scrollView.contentInset.bottom + yh_RefreshFooterHeight, state != .willRefresh, state != .refreshing {
                        state = .willRefresh
                    }
                    
                } else {
                    if scrollView.contentOffset.y < yh_RefreshFooterHeight - scrollView.contentInset.top , state != .refreshing {
                        state = .normal
                    } else if scrollView.contentOffset.y >= yh_RefreshFooterHeight - scrollView.contentInset.top , state != .willRefresh, state != .refreshing {
                        state = .willRefresh
                    }
                }
            } else {
                if state == .willRefresh {
                    state = .refreshing
                }
            }
            
            if state == .normal {
                if scrollView.contentSize.height >= yh_ScreenH - scrollView.contentInset.bottom - scrollView.contentInset.top {
                    pullingPercent = (scrollView.contentOffset.y - scrollView.contentSize.height + yh_ScreenH - scrollView.contentInset.bottom) / yh_RefreshFooterHeight
                } else {
                    pullingPercent = (scrollView.contentOffset.y + scrollView.contentInset.top) / yh_RefreshFooterHeight
                }
                
                if let images = stateImages[state.rawValue], pullingPercent<=1, pullingPercent>=0 {
                    if images.count == 1 {
                        gifView.image = images.first
                    } else {
                        gifView.image = images[Int(CGFloat(images.count - 1) * pullingPercent)]
                    }
                }
            }
        }
        
    }
    
    fileprivate var pullingPercent: CGFloat!
    
    fileprivate lazy var gifView = UIImageView()
    
    fileprivate lazy var stateImages = [String: [UIImage]]()
    
    fileprivate lazy var stateDurations = [String: TimeInterval]()
    
    open func setGifFooter(_ images:[UIImage],duration:TimeInterval,state:YHRefreshState) {
        stateImages[state.rawValue] = images
        stateDurations[state.rawValue] = duration
    }
    
    open func setGifFooter(_ images:[UIImage],state:YHRefreshState) {
        stateImages[state.rawValue] = images
        stateDurations[state.rawValue] = Double(images.count) * 0.1
    }
    
}

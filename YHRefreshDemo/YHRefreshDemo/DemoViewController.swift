//
//  TableViewController.swift
//  Test5
//
//  Created by Detailscool on 16/4/2.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

class DemoViewController: UITableViewController {
    
    var numbers = [Int]()
    
    var s = 0
    
    var style : YHRefreshStyle
    
    init(style:YHRefreshStyle) {
        self.style = style
        super.init(style: UITableViewStyle.Plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Test
        /*
        tableView.rowHeight = 10;
        tableView.tableFooterView = UIView()
        tableView.contentInset.bottom = 50
        let bottomView = UIView(frame: CGRect(x: 0, y: yh_ScreenH - 50, width: yh_ScreenW, height: 50))
        bottomView.backgroundColor = UIColor.redColor()
        UIApplication.sharedApplication().keyWindow!.addSubview(bottomView)
         */
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        for i in s..<s+20 {
            numbers.append(i)
        }
        
        switch style{
            
        case .NormalHeader :
            tableView.yh_header = YHRefreshNormalHeader.header(self, selector: #selector(DemoViewController.load)) as! YHRefreshNormalHeader
            
        case .SpringHeader :
            tableView.yh_header = YHRefreshSpringHeader.header(self, selector: #selector(DemoViewController.load)) as! YHRefreshSpringHeader
            
        case .GifHeader :
            let header = YHRefreshGifHeader.header(self, selector: #selector(DemoViewController.load)) as! YHRefreshGifHeader
            var refreshingImages = [UIImage]()
            for i in 1...3 {
                let image = UIImage(named: String(format:"dropdown_loading_0%zd", i))
                refreshingImages.append(image!)
            }
            
            var nomalImages = [UIImage]()
            for i in 1...60 {
                let image = UIImage(named: String(format:"dropdown_anim__000%zd", i))
                nomalImages.append(image!)
            }
            
            header.setGifHeader(nomalImages, state: YHRefreshState.Normal)
            header.setGifHeader(refreshingImages, state: YHRefreshState.WillRefresh)
            header.setGifHeader(refreshingImages, state: YHRefreshState.Refreshing)
            
            tableView.yh_header = header
            
        case .MaterialHeader :
            let header = YHRefreshMaterialHeader.header(self, selector: #selector(DemoViewController.load)) as! YHRefreshMaterialHeader
            header.shouldStayOnWindow = true
            tableView.yh_header = header
            
        case .NormalFooter :
            tableView.yh_footer = YHRefreshNormalFooter.footer(self, selector: #selector(DemoViewController.load)) as! YHRefreshNormalFooter
            
        case .AutoFooter :
            tableView.yh_footer = YHRefreshAutoFooter.footer(self, selector: #selector(DemoViewController.load)) as! YHRefreshAutoFooter
            
        case .GifFooter :
            let footer = YHRefreshGifFooter.footer(self, selector: #selector(DemoViewController.load)) as! YHRefreshGifFooter
            var refreshingImages = [UIImage]()
            for i in 1...3 {
                let image = UIImage(named: String(format:"dropdown_loading_0%zd", i))
                refreshingImages.append(image!)
            }
            
            var nomalImages = [UIImage]()
            for i in 1...60 {
                let image = UIImage(named: String(format:"dropdown_anim__000%zd", i))
                nomalImages.append(image!)
            }
            
            footer.setGifFooter(nomalImages, state: YHRefreshState.Normal)
            footer.setGifFooter(refreshingImages, state: YHRefreshState.WillRefresh)
            footer.setGifFooter(refreshingImages, state: YHRefreshState.Refreshing)
            
            tableView.yh_footer = footer
            
        }
        
//        tableView.yh_footer?.showNoMoreData()
    }
    
    func load() {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
           
            self.s += 20
            
            for i in self.s..<self.s+20 {
                self.numbers.append(i)
            }
            
            self.tableView.reloadData()
            
            switch self.style {
                
            case .NormalHeader :
                self.tableView.yh_header?.endRefreshing()
                
            case .SpringHeader :
                self.tableView.yh_header?.endRefreshing()
                
            case .GifHeader :
                self.tableView.yh_header?.endRefreshing()
                
            case .MaterialHeader :
                self.tableView.yh_header?.endRefreshing()
    
            case .NormalFooter :
                self.tableView.yh_footer?.endRefreshing()
                
            case .AutoFooter :
                self.tableView.yh_footer?.endRefreshing()
                
            case .GifFooter :
                self.tableView.yh_footer?.endRefreshing()
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier")
        cell!.textLabel?.text = "\(indexPath.row)"
        cell?.textLabel?.textColor = UIColor.whiteColor()
        return cell!
        
    }
    
    func colorforIndex(index: Int) -> UIColor {
        
        let itemCount = numbers.count - 1
        let color = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: color, green: 0.0, blue: 1.0, alpha: 1.0)
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor =  colorforIndex(indexPath.row)
        
    }
    
}

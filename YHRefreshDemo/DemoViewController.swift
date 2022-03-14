//
//  DemoViewController.swift
//  YHRefresh
//
//  Created by HenryLee on 16/8/30.
//  Copyright © 2016年 HenryLee. All rights reserved.
//

import UIKit
import YHRefresh

class DemoViewController: UITableViewController {

    var numbers = [Int]()
    
    var s = 0
    
    var style : YHRefreshStyle
    
    init(style:YHRefreshStyle) {
        self.style = style
        super.init(style: .plain)
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        for i in s..<s+20 {
            numbers.append(i)
        }
        
        switch style{
            
        case .normalHeader :
            tableView.yh_header = YHRefreshNormalHeader.header(self, selector: #selector(DemoViewController.loadData))
            
        case .springHeader :
            tableView.yh_header = YHRefreshSpringHeader.header(self, selector: #selector(DemoViewController.loadData))
            
        case .gifHeader :
            let header = YHRefreshGifHeader.header(self, selector: #selector(DemoViewController.loadData))
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
            
            header.setGifHeader(nomalImages, state: YHRefreshState.normal)
            header.setGifHeader(refreshingImages, state: YHRefreshState.willRefresh)
            header.setGifHeader(refreshingImages, state: YHRefreshState.refreshing)
            
            tableView.yh_header = header
            
        case .materialHeader :
            let header = YHRefreshMaterialHeader.header(self, selector: #selector(DemoViewController.loadData))
            header.shouldStayOnWindow = true
            tableView.yh_header = header
            
        case .normalFooter :
            tableView.yh_footer = YHRefreshNormalFooter.footer(self, selector: #selector(DemoViewController.loadData))
            
        case .autoFooter :
            tableView.yh_footer = YHRefreshAutoFooter.footer(self, selector: #selector(DemoViewController.loadData))
            
        case .gifFooter :
            let footer = YHRefreshGifFooter.footer(self, selector: #selector(DemoViewController.loadData))
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
            
            footer.setGifFooter(nomalImages, state: YHRefreshState.normal)
            footer.setGifFooter(refreshingImages, state: YHRefreshState.willRefresh)
            footer.setGifFooter(refreshingImages, state: YHRefreshState.refreshing)
            
            tableView.yh_footer = footer
            
        }
        
        //        tableView.yh_footer?.showNoMoreData()
    }
    
    @objc func loadData() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
            
            self.s += 20
            
            for i in self.s..<self.s+20 {
                self.numbers.append(i)
            }
            
            self.tableView.reloadData()
            
            switch self.style {
                
            case .normalHeader :
                self.tableView.yh_header?.endRefreshing()
                
            case .springHeader :
                self.tableView.yh_header?.endRefreshing()
                
            case .gifHeader :
                self.tableView.yh_header?.endRefreshing()
                
            case .materialHeader :
                self.tableView.yh_header?.endRefreshing()
                
            case .normalFooter :
                self.tableView.yh_footer?.endRefreshing()
                
            case .autoFooter :
                self.tableView.yh_footer?.endRefreshing()
                
            case .gifFooter :
                self.tableView.yh_footer?.endRefreshing()
            }
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        cell!.textLabel?.text = "\(indexPath.row)"
        cell?.textLabel?.textColor = UIColor.white
        return cell!
        
    }
    
    func colorforIndex(_ index: Int) -> UIColor {
        
        let itemCount = numbers.count - 1
        let color = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: color, green: 0.0, blue: 1.0, alpha: 1.0)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor =  colorforIndex(indexPath.row)
        
    }

}

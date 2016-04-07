//
//  TableViewController.swift
//  Test5
//
//  Created by Detailscool on 16/4/2.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var numbers = [Int]()
    
    var s = 0
    
    var style : RefreshStyle
    
    init(style:RefreshStyle) {
        self.style = style
        super.init(style: UITableViewStyle.Plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        for i in s..<s+20 {
            
            numbers.append(i)
        }
        
        switch style{
            
        case .NormalHeader :
            
            tableView.yh_header = YHRefreshNormalHeader.header(self, selector: "load") as! YHRefreshNormalHeader
            
        case .SpringHeader :
            
            tableView.yh_header = YHRefreshSpringHeader.header(self, selector: "load") as! YHRefreshSpringHeader
            
        case .NormalFooter :
            
            tableView.yh_footer = YHRefreshNormalFooter.footer(self, selector: "load") as! YHRefreshNormalFooter
            
        case .AutoFooter :
            
            tableView.yh_footer = YHRefreshAutoFooter.footer(self, selector: "load") as! YHRefreshAutoFooter
            
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
                
            case .NormalFooter :
                
                self.tableView.yh_footer?.endRefreshing()
                
            case .AutoFooter :
                
                self.tableView.yh_footer?.endRefreshing()
                
            }
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numbers.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier")
        
        cell!.textLabel?.text = "\(indexPath.row)"
        // Configure the cell...
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

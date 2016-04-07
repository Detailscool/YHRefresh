//
//  GuideViewController.swift
//  Test5
//
//  Created by Detailscool on 16/4/6.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

enum RefreshStyle : String {
    case NormalHeader = "NormalHeader"
    case SpringHeader = "SpringHeader"
    case NormalFooter = "NormalFooter"
    case AutoFooter = "AutoFooter"
}

class GuideViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "back")
    }

  
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
            
        case 0 :
            pushViewController(.NormalHeader)
        case 1 :
            pushViewController(.SpringHeader)
        case 2 :
             pushViewController(.NormalFooter)
        case 3 :
             pushViewController(.AutoFooter)
        default:break
            
        }
        
    }
    
    func pushViewController(style:RefreshStyle) {
        
        let vc = TableViewController(style: style)
        vc.title = vc.style.rawValue
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func back() {
    
        navigationController?.popViewControllerAnimated(true)
    }

}

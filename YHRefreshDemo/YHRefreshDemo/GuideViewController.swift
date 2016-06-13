//
//  GuideViewController.swift
//  Test5
//
//  Created by Detailscool on 16/4/6.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

enum YHRefreshStyle : String {
    case NormalHeader = "NormalHeader"
    case SpringHeader = "SpringHeader"
    case GifHeader = "GifHeader"
    case NormalFooter = "NormalFooter"
    case AutoFooter = "AutoFooter"
    case GifFooter = "GifFooter"
}

class GuideViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GuideViewController.back))
    }

  
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
            
        case 0 :
            pushViewController(.NormalHeader)
        case 1 :
            pushViewController(.SpringHeader)
        case 2 :
            pushViewController(.GifHeader)
        case 3 :
             pushViewController(.NormalFooter)
        case 4 :
             pushViewController(.AutoFooter)
        case 5 :
            pushViewController(.GifFooter)
        default:break
            
        }
        
    }
    
    func pushViewController(style:YHRefreshStyle) {
        
        let vc = DemoViewController(style: style)
        vc.title = vc.style.rawValue
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func back() {
    
        navigationController?.popViewControllerAnimated(true)
    }

}

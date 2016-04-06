//
//  GuideViewController.swift
//  Test5
//
//  Created by Detailscool on 16/4/6.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

enum RefreshStyle : Int {
    case NormalHeader = 0
    case SpringHeader = 1
    case NormalFooter = 2
    case AutoFooter = 3
}


class GuideViewController: UITableViewController {

  
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
            
        case 0 :
            navigationController?.pushViewController(TableViewController(style: .NormalHeader), animated: true)
        case 1 :
            navigationController?.pushViewController(TableViewController(style: .SpringHeader), animated: true)
        case 2 :
            navigationController?.pushViewController(TableViewController(style: .NormalFooter), animated: true)
        case 3 :
            navigationController?.pushViewController(TableViewController(style: .AutoFooter), animated: true)
        default:break
        
        }
        
    }

}

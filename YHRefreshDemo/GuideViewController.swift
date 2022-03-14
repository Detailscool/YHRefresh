//
//  GuideViewController.swift
//  Test5
//
//  Created by Detailscool on 16/4/6.
//  Copyright © 2016年 Detailscool. All rights reserved.
//

import UIKit

enum YHRefreshStyle : String {
    case normalHeader = "NormalHeader"
    case springHeader = "SpringHeader"
    case gifHeader = "GifHeader"
    case materialHeader = "MaterialHeader"
    case normalFooter = "NormalFooter"
    case autoFooter = "AutoFooter"
    case gifFooter = "GifFooter"
}

class GuideViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(GuideViewController.back))
    }

  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0 :
            pushViewController(.normalHeader)
        case 1 :
            pushViewController(.springHeader)
        case 2 :
            pushViewController(.gifHeader)
        case 3 :
            pushViewController(.materialHeader)
        case 4 :
             pushViewController(.normalFooter)
        case 5 :
             pushViewController(.autoFooter)
        case 6 :
            pushViewController(.gifFooter)
        default:break
        }
    }
    
    func pushViewController(_ style:YHRefreshStyle) {
        let vc = DemoViewController(style: style)
        vc.title = vc.style.rawValue
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func back() {
       _ = navigationController?.popViewController(animated: true)
    }

}

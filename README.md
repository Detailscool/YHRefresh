# YHRefresh

###Introduction 
Inspired By `MJRefresh`
#####A refreshing helper written in Swift, which can be used to refresh easily.
#####一款简单易用的Swift版上拉或者下拉刷新...

###Components
![](http://ww2.sinaimg.cn/mw690/9a2346e2gw1f2oeuztvzoj20hy09a0tf.jpg)
 
##Usage
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.yh_header = YHRefreshNormalHeader.header(self, selector: "load") as! YHRefreshNormalHeader
        tableView.yh_header.beginRefreshing
    }
    
    func load() {
        
        //模拟网络请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            
            /*网络回调处理*/
            
            self.tableView.reloadData()
            self.tableView.yh_header?.endRefreshing()
            
        }
    }

##Effect
>①YHRefreshNormalHeader<br><br>
![](http://ww4.sinaimg.cn/mw690/9a2346e2gw1f2oeq6qwpbg20ab0iiwg9.gif)

>②YHRefreshSpringHeader<br><br>
![](http://ww3.sinaimg.cn/mw690/9a2346e2gw1f2oeq84xd9g20ab0ii0vt.gif)

>③YHRefreshNormalFooter<br><br>
![](http://ww1.sinaimg.cn/mw690/9a2346e2gw1f2oeq945pkg20ab0iiwgh.gif)

>④YHRefreshAutoFooter<br><br>
![](http://ww4.sinaimg.cn/mw690/9a2346e2gw1f2oeqawm9vg20ab0iiq71.gif)


##Requirements
* Swift 2.0


##License

Routable for iOS is available under the MIT license. See the LICENSE file for more info.


# YHRefresh

###Introduction 
Inspired By `MJRefresh`
#####A refreshing helper written in Swift, which can be used to refresh easily.Still working on making it more perfectly.Looking forward to any positive suggestion 
#####一款简单易用的Swift版上拉或者下拉刷新...还在努力不断完善中...欢迎任何建设性PR

###Components
![](http://ww2.sinaimg.cn/mw690/9a2346e2gw1f2oeuztvzoj20hy09a0tf.jpg)

###Cocoapods
edit Podfile 编辑Podfile文件： 
``` bash 
  use_frameworks!
  
  pod 'YHRefresh', '~> 0.0.4’
```
then run in terminal 在终端运行：
``` bash 
  pod install --no-repo-update
```
##Usage
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.yh_header = YHRefreshNormalHeader.header(self, selector: "load") as! YHRefreshNormalHeader
        tableView.yh_header.beginRefreshing()
    }
    
    func load() {
        
        //模拟网络请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            
            self.tableView.yh_header?.endRefreshing()
            
            /*网络回调处理*/
            
            self.tableView.reloadData()
            
        }
    }
    
    -----------------------------------分割线-----------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.yh_footer = YHRefreshNormalFooter.footer(self, selector: "loadMore") as! YHRefreshNormalFooter
        
    }
    
    func loadMore() {
        
        //模拟网络请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            
            self.tableView.yh_footer?.endRefreshing()
            
            /*网络回调处理*/
            
            self.tableView.reloadData()
            
            /*条件判断是否已经数据最大,若是显示没有更多数据*/
            self.tableView.yh_footer?.showNoMoreData()
            
        }
    }
    -----------------------------------分割线-----------------------------------
    注：header和footer可以同时用，但请回避两者同时刷新~！

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

Copyright (c) 2016 YuanHui Lee detailsli@gmail.com. See the LICENSE file for more info.


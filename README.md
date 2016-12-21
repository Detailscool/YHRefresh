# YHRefresh

###Introduction 
Inspired By `MJRefresh`
#####A refreshing helper written in Swift, which can be used to refresh easily.Still working on making it more perfectly.Looking forward to any positive suggestion 
#####Swift 3.0 Supporting Now...
#####一款简单易用的Swift版上拉或者下拉刷新...还在努力不断完善中...欢迎任何建设性PR
#####现已支持Swift 3.0 新增类安卓Material刷新

###Components
![](http://ww3.sinaimg.cn/mw1024/9a2346e2gw1f51ztblwehj20j1073gm7.jpg)

###Cocoapods
edit Podfile 编辑Podfile文件： 
``` bash 
  use_frameworks!
  pod 'YHRefresh', '~> 0.1.4’
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
	
	      /*网络回调处理*/
	    
	      /*刷新数据*/
	      self.tableView.reloadData()
	      /*结束刷新*/
	      self.tableView.yh_header?.endRefreshing()
    
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
        
 	      /*网络回调处理*/
 	    
	      /*刷新数据*/
	      self.tableView.reloadData()
	      /*结束刷新*/
	      self.tableView.yh_footer?.endRefreshing()
	    
	      /*条件判断是否已经数据最大,若是显示没有更多数据*/
 	      //self.tableView.yh_footer?.showNoMoreData()

        }
    }
    -----------------------------------分割线-----------------------------------
    注：header和footer可以同时用，但请回避两者同时刷新~！

##Effect
>①YHRefreshNormalHeader<br><br>
![](http://ww2.sinaimg.cn/mw1024/9a2346e2jw1f52us5ae1wg208h0f943j.gif)

>②YHRefreshSpringHeader<br><br>
![](http://ww1.sinaimg.cn/mw1024/9a2346e2gw1f52us2n93ig208i0f7n1e.gif)

>③YHRefreshGifHeader<br><br>
![](http://ww4.sinaimg.cn/mw1024/9a2346e2gw1f4yfcyypjeg208h0fcdmt.gif)

>④YHRefreshNormalFooter<br><br>
![](http://ww2.sinaimg.cn/mw1024/9a2346e2jw1f52wcf4mq6g208i0fajxb.gif)

>⑤YHRefreshAutoFooter<br><br>
![](http://ww4.sinaimg.cn/mw1024/9a2346e2jw1f52wcgn3psg208i0fa0xm.gif)

>⑥YHRefreshGifFooter<br><br>
![](http://ww1.sinaimg.cn/mw1024/9a2346e2gw1f4yfd1c1pag208h0fcjuj.gif)

##Requirements
* Swift 3.0
* Xcode 8.0++

##License

Copyright (c) 2016 YuanHui Lee detailsli@gmail.com. See the LICENSE file for more info.


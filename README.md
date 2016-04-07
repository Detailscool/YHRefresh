# YHRefresh
Inspired By `MJRefresh`
#####A refreshing helper written in Swift, which can be used to refresh easily.
#####一款简单易用的Swift版上拉或者下拉刷新...稍迟上Gif图
    
    var numbers = [Int]()
    var s = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in s..<s+20 {
            numbers.append(i)
        }
        
        tableView.yh_header = YHRefreshNormalHeader.header(self, selector: "load") as! YHRefreshNormalHeader
        tableView.yh_header.beginRefreshing
    }
    
    func load() {
        
        //模拟网络请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            
            self.s += 20
            for i in self.s..<self.s+20 {
                self.numbers.append(i)
            }
            
            self.tableView.reloadData()
            self.tableView.yh_header?.endRefreshing()
            
        }
    }

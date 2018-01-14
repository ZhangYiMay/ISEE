

import UIKit

struct MyRegex {
    let regex: NSRegularExpression?
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    func match(_ input: String) -> Bool {
        if let matches = regex?.matches(in: input, options: [], range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        }
        else {
            return false
        }
    }
}

class NoticeListController: UITableViewController, XMLParserDelegate, UISearchBarDelegate {
    
    let refreshController = UIRefreshControl()
    var searchController = UISearchController.init()
    
    var initial_count_trans_flag: Bool? {
        didSet {
            print("bool:\(self.initial_count_trans_flag)")
        }
    }
    
    var result_string: String?
    var final_result_string: String = ""
    var elementName: String?
    var attribute:[String: String]?
    
    var notice_today: [String] = []
    var notice_former: [String] = []
    var notice_all: [String] = []
    var notice_date: [String] = []
    var notice_date_today: [String] = []
    var notice_date_former: [String] = []
    var notice_link: [String] = []
    var notice_link_today: [String] = []
    var notice_link_former: [String] = []
    var notice_top: [String] = []
    var date_top: [String] = []
    var link_top: [String] = []
    
    var searchArrayDate: [String] = []
    var searchArrayLink: [String] = []
    var beginSearch: Bool = false
    var indexNotice: Array<Dictionary<String, Any>> = []
    var searchResults: Array<Dictionary<String, Any>> = []
    
    var waitView = UIActivityIndicatorView.init()
    var backWaitView = UIView.init()
    var waitLable = UILabel.init()
    
    var titleName: String = "" {
        didSet {
            self.title = titleName
        }
    }
    
    var noticePath: String? {
        didSet {
            //getNotice(noticePath)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init()
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            //controller.view.backgroundColor = UIColor.init(red: 0, green: 1, blue: 1, alpha: 0.5)
            controller.searchBar.delegate = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = true
            //search bar config
            controller.searchBar.searchBarStyle = UISearchBarStyle.default
            controller.searchBar.placeholder = "搜索"
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        let path: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
        let documentDir = path[0] as! String
        let noticeFilePath = documentDir + "/notice/"
        //let noticeFilePath = documentDir + "/notice/"
        //let linkFilePath = documentDir + "/link/"
        
        let manager = FileManager.default
        if manager.fileExists(atPath: noticeFilePath) {
            self.notice_top = try! manager.contentsOfDirectory(atPath: noticeFilePath)
            for item in self.notice_top {
                let datePath = noticeFilePath + "\(item)/date"
                if manager.fileExists(atPath: datePath) {
                    let dateArray = try! manager.contentsOfDirectory(atPath: datePath)
                    self.date_top.append(dateArray[0])
                }
                let linkPath = noticeFilePath + "/\(item)/link"
                if manager.fileExists(atPath: linkPath) {
                    
                    let linkArray = try! manager.contentsOfDirectory(atPath: linkPath)
                    self.link_top.append(linkArray[0])
                }
                
            }
        }
        //show wait progress
        backWaitView = UIView.init(frame: CGRect.init(x: self.view.frame.width / 2 - 50, y: self.view.frame.height / 2 - 50, width: 100, height: 100))
        backWaitView.backgroundColor = UIColor.lightGray
        backWaitView.layer.cornerRadius = 8
        backWaitView.isHidden = false
        self.view.addSubview(backWaitView)
        waitView.frame = CGRect.init(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 40, width: 60, height: 60)
        waitView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.view.addSubview(waitView)
        waitView.hidesWhenStopped = true
        waitView.startAnimating()
        waitLable = UILabel.init(frame: CGRect.init(x: self.view.frame.width / 2 - 50, y: self.view.frame.height / 2 + 20, width: 100, height: 25))
        waitLable.text = "请稍等..."
        waitLable.textColor = UIColor.white
        waitLable.font = UIFont.systemFont(ofSize: 16)
        waitLable.textAlignment = NSTextAlignment.center
        waitLable.isHidden = false
        self.view.addSubview(waitLable)
        //waitView = UIActivityIndicatorView.init(frame: CGRect.init(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60))
        //get notice online in another thread
        let newThread = Thread.init(target: self, selector: #selector(self.getNotice), object: nil)
        newThread.name = "getnoticelist"
        newThread.start()
        //refresh in main thread???
        refreshController.addTarget(self, action: #selector(NoticeListController.refreshData), for: UIControlEvents.valueChanged)
        refreshController.attributedTitle = NSAttributedString(string: "稍等一下哦^_^")
        self.view.addSubview(refreshController)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData() {
        notice_today.removeAll()
        notice_former.removeAll()
        notice_all.removeAll()
        notice_date.removeAll()
        notice_date_today.removeAll()
        notice_date_former.removeAll()
        notice_link.removeAll()
        notice_link_today.removeAll()
        notice_link_former.removeAll()
        getNotice()
        self.tableView.reloadData()
    }
    
    func getDataOnline(_ path: String) {
        let url = URL(string: path)
        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        do {
            result_string = try NSString(contentsOf: url!, encoding: enc) as String
        }catch let error as NSError {
            print("error in data getting:\(error.description)")
        }
        
    }
    
    func getNotice(/*_ noticePath: String?*/) {
        let noticePath = self.noticePath
        if noticePath != nil {
            getDataOnline(self.noticePath!)
            //change & into ********
            if result_string != nil {
                
                final_result_string = result_string!.replacingOccurrences(of: "&", with: "********")
                final_result_string = final_result_string.replacingOccurrences(of: "height=\"3\"background", with: "height=\"3\" background")
                
                let result_data = final_result_string.data(using: String.Encoding.utf8)
                let parser = XMLParser(data: result_data!)
                parser.delegate = self
                parser.parse()
            }
            else {
                print("newThread begin!!")
                DispatchQueue.main.async(execute: { 
                    let alert = UIAlertController(title: "阿欧～好像没连上内网哦～", message: "请确保连上内网", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction.init(title: "我知道了", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    self.refreshController.endRefreshing()
                })
            }
            
            //fill the notice_today and notice_former
            let currentDate = Date()
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "[yyyy-MM-dd]"
            let dateForToday = dateFormat.string(from: currentDate)
            for i in 0 ..< notice_date.count {
                if notice_date[i] == dateForToday {
                    notice_today.append(notice_all[i])
                    notice_date_today.append(notice_date[i])
                    notice_link_today.append(notice_link[i])
                }else {
                    notice_former.append(notice_all[i])
                    notice_date_former.append(notice_date[i])
                    notice_link_former.append(notice_link[i])
                }
            }
            for (index, item) in self.notice_all.enumerated() {
                let tempDir: Dictionary<String, Any> = ["index": index, "name": item]
                indexNotice.append(tempDir)
            }
            //noteListTv.reloadData()
            //transform data to AppDelegate
            if self.initial_count_trans_flag! {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "initial_count"), object: self.notice_date_today.count)
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.refreshController.endRefreshing()
                self.backWaitView.isHidden = true
                self.waitView.stopAnimating()
                self.waitLable.isHidden = true
            })
            //refreshController.endRefreshing()
        }
        
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.attribute = attributeDict
        self.elementName = elementName
        //add title and link
        let linkPattern = "^redir\\.php\\?catalog_id\\=\\d{5,}\\*{8}object_id\\=\\d{5,}$"
        let regex_link = MyRegex(linkPattern)
        if elementName == "a" && attributeDict["title"] != nil && regex_link.match(attributeDict["href"]!) {
            let title = self.attribute!["title"]!
            let finalTitle = title.replacingOccurrences(of: "********", with: "&")
            self.notice_all.append(finalTitle)
            let currentLink = attributeDict["href"]?.replacingOccurrences(of: "********", with: "&")
            self.notice_link.append(currentLink!)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        //add date array
        let datePattern = "^\\[\\d{4}\\-\\d{2}\\-\\d{2}\\]$"
        let regex_date = MyRegex(datePattern)
        if self.elementName == "td" && self.attribute!["width"] != nil && self.attribute!["align"] != nil && self.attribute!["style"] != nil && regex_date.match(string) {
            self.notice_date.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //print("end:\(elementName)")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !beginSearch {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section_view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 40))
        section_view.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 1)
        let label = UILabel.init(frame: CGRect.init(x: 10, y: 3, width: self.view.frame.width, height: 20))
        
        if section == 0 {
            label.text = "我的置顶通知"
        }else if section == 1 {
            label.text = "今天的通知"
        }else {
            label.text = "之前的通知"
        }
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.darkGray
        section_view.addSubview(label)
        
        return section_view
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !beginSearch {
            if section == 0 {
                return "我的置顶通知"
            }
            else {
                if section == 1 {
                    return "今天的通知"
                } else {
                    return "之前的通知"
                }
            }
        }
        else {
            return ""
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !beginSearch {
            if section == 0 {
                return self.notice_top.count
            }
            else {
                if section == 1 {
                    return self.notice_today.count
                }else {
                    return self.notice_former.count
                }
            }
        }else {
            return self.searchArrayDate.count
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "NoticeListCell")
        
        if !beginSearch {
            
            if (indexPath as NSIndexPath).section == 0 {
                cell.textLabel?.text = notice_top[(indexPath as NSIndexPath).row]
                cell.detailTextLabel?.text = date_top[(indexPath as NSIndexPath).row]
                
            }else {
                if (indexPath as NSIndexPath).section == 1 {
                    cell.textLabel?.text = notice_today[(indexPath as NSIndexPath).row]
                    cell.detailTextLabel?.text = notice_date_today[(indexPath as NSIndexPath).row]
                    
                }else {
                    cell.textLabel?.text = notice_former[(indexPath as NSIndexPath).row]
                    cell.detailTextLabel?.text = notice_date_former[(indexPath as NSIndexPath).row]
                }
            }
        }
        else {
            cell.textLabel?.text = self.searchResults[indexPath.row]["name"] as! String
            cell.detailTextLabel?.text = self.searchArrayDate[indexPath.row]
        }
        
        cell.textLabel?.numberOfLines = 0
        tableView.estimatedRowHeight = 20
        tableView.rowHeight = UITableViewAutomaticDimension
        cell.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !beginSearch {
            if (indexPath as NSIndexPath).section == 0 {
//                let dic: Dictionary<String, String> = ["title": self.notice_top[(indexPath as NSIndexPath).row], "link": self.link_top[(indexPath as NSIndexPath).row]]
//                performSegue(withIdentifier: "getNoticeSegue", sender: dic)
                let url = URL.init(string: "http://www.isee.zju.edu.cn/notice/" + self.link_top[indexPath.row])
                UIApplication.shared.openURL(url!)
            }else {
                if (indexPath as NSIndexPath).section == 1 {
//                    let dic: Dictionary<String, String> = ["title": self.notice_today[(indexPath as NSIndexPath).row], "link": self.notice_link_today[(indexPath as NSIndexPath).row]]
//                    performSegue(withIdentifier: "getNoticeSegue", sender: dic)
                    let url = URL.init(string: "http://www.isee.zju.edu.cn/notice/" + self.notice_link_today[indexPath.row])
                    UIApplication.shared.openURL(url!)
                }else {
//                    let dic: Dictionary<String, String> = ["title": self.notice_former[(indexPath as NSIndexPath).row], "link": self.notice_link_former[(indexPath as NSIndexPath).row]]
//                    performSegue(withIdentifier: "getNoticeSegue", sender: dic)
                    let url = URL.init(string: "http://www.isee.zju.edu.cn/notice/" + self.notice_link_former[indexPath.row])
                    UIApplication.shared.openURL(url!)
                }
            }
        }else {
//            let dic: Dictionary<String, String> = ["title": self.searchResults[(indexPath as NSIndexPath).row]["name"] as! String, "link": self.searchArrayLink[(indexPath as NSIndexPath).row]]
//            performSegue(withIdentifier: "getNoticeSegue", sender: dic)
            let url = URL.init(string: "http://www.isee.zju.edu.cn/notice/" + self.searchArrayLink[indexPath.row])
            UIApplication.shared.openURL(url!)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getNoticeSegue" {
            let destVC = segue.destination as! NoticeContentViewController
            let dic = sender as! Dictionary<String, String>
            destVC.noticeTitle = dic["title"]! as String
            destVC.noticeLink = "http://www.isee.zju.edu.cn/notice/" + (dic["link"]! as String)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if !beginSearch {
            if (indexPath as NSIndexPath).section == 0 {
                return "取消置顶"
            }
            else {
                return "置顶"
            }
        }
        else{
            return "置顶"
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        var top_date = ""
        var top_notice = ""
        var top_link = ""
        let path: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
        let documentDir = path[0] as! String
        let noticeFilePath = documentDir + "/notice/"
        //let noticeFilePath = documentDir + "date/notice/"
        //let linkFilePath = documentDir + "date/link/"
        let manager: FileManager = FileManager.default
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            if !beginSearch {
                if (indexPath as NSIndexPath).section == 1 {
                    top_date = self.notice_date_today[indexPath.row]
                    top_link = self.notice_link_today[indexPath.row]
                    top_notice = self.notice_today[indexPath.row]
                    
                    let noticeFileUrl = NSURL(fileURLWithPath: noticeFilePath + top_notice)
                    let dateFileUrl = NSURL(fileURLWithPath: noticeFilePath + top_notice + "/date/" + top_date)
                    let linkFileUrl = NSURL(fileURLWithPath: noticeFilePath + top_notice + "/link/" + top_link)
                    if !(manager.fileExists(atPath: noticeFilePath + top_notice)) {
                        self.notice_top.append(top_notice)
                        self.date_top.append(top_date)
                        self.link_top.append(top_link)
                        try! manager.createDirectory(at: dateFileUrl as URL, withIntermediateDirectories: true, attributes: nil)
                        try! manager.createDirectory(at: noticeFileUrl as URL, withIntermediateDirectories: true, attributes: nil)
                        try! manager.createDirectory(at: linkFileUrl as URL, withIntermediateDirectories: true, attributes: nil)
                    }else {
                        let alertControl = UIAlertController(title: "请不要重复置顶", message: "这条通知已经被置顶过了", preferredStyle: UIAlertControllerStyle.alert)
                        let alertAction = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil)
                        alertControl.addAction(alertAction)
                        self.present(alertControl, animated: true, completion: nil)
                    }
                    
                }else {
                    if (indexPath as NSIndexPath).section == 2 {
                        top_date = self.notice_date_former[indexPath.row]
                        top_link = self.notice_link_former[indexPath.row]
                        top_notice = self.notice_former[indexPath.row]
                        
                        let noticeFileUrl = NSURL(fileURLWithPath: noticeFilePath + top_notice)
                        let dateFileUrl = NSURL(fileURLWithPath: noticeFilePath + top_notice + "/date/" + top_date)
                        let linkFileUrl = NSURL(fileURLWithPath: noticeFilePath + top_notice + "/link/" + top_link)
                        if !(manager.fileExists(atPath: noticeFilePath + top_notice)) {
                            self.notice_top.append(top_notice)
                            self.date_top.append(top_date)
                            self.link_top.append(top_link)
                            try! manager.createDirectory(at: dateFileUrl as URL, withIntermediateDirectories: true, attributes: nil)
                            try! manager.createDirectory(at: noticeFileUrl as URL, withIntermediateDirectories: true, attributes: nil)
                            try! manager.createDirectory(at: linkFileUrl as URL, withIntermediateDirectories: true, attributes: nil)
                        }else {
                            let alertControl = UIAlertController(title: "请不要重复置顶", message: "这条通知已经被置顶过了", preferredStyle: UIAlertControllerStyle.alert)
                            let alertAction = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil)
                            alertControl.addAction(alertAction)
                            self.present(alertControl, animated: true, completion: nil)
                        }
                        
                    }
                    else {
                        
                        //tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                        top_notice = self.notice_top[indexPath.row]
                        notice_top.remove(at: indexPath.row)
                        link_top.remove(at: indexPath.row)
                        date_top.remove(at: indexPath.row)
                        try! manager.removeItem(atPath: noticeFilePath + top_notice)
                        //try! manager.removeItem(atPath: dateFilePath + top_date + "/notice/" + top_notice)
                        //try! manager.removeItem(atPath: dateFilePath + top_date + "/link/" + top_link)
                    }
                }
            }else {
                top_date = self.searchArrayDate[indexPath.row]
                top_link = self.searchArrayLink[indexPath.row]
                top_notice = self.searchResults[indexPath.row]["name"] as! String
                
                let noticeFileUrl = NSURL(fileURLWithPath: noticeFilePath + top_notice)
                let dateFileUrl = NSURL(fileURLWithPath: noticeFilePath + top_notice + "/date/" + top_date)
                let linkFileUrl = NSURL(fileURLWithPath: noticeFilePath + top_notice + "/link/" + top_link)
                if !(manager.fileExists(atPath: noticeFilePath + top_notice)) {
                    self.notice_top.append(top_notice)
                    self.date_top.append(top_date)
                    self.link_top.append(top_link)
                    try! manager.createDirectory(at: dateFileUrl as URL, withIntermediateDirectories: true, attributes: nil)
                    try! manager.createDirectory(at: noticeFileUrl as URL, withIntermediateDirectories: true, attributes: nil)
                    try! manager.createDirectory(at: linkFileUrl as URL, withIntermediateDirectories: true, attributes: nil)
                    let alertControl = UIAlertController(title: "置顶成功", message: "返回即可看到置顶信息", preferredStyle: UIAlertControllerStyle.alert)
                    let alertAction = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil)
                    alertControl.addAction(alertAction)
                    self.searchController.present(alertControl, animated: true, completion: nil)
                }else {
                    let alertControl = UIAlertController(title: "请不要重复置顶", message: "这条通知已经被置顶过了", preferredStyle: UIAlertControllerStyle.alert)
                    let alertAction = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil)
                    alertControl.addAction(alertAction)
                    self.searchController.present(alertControl, animated: true, completion: nil)
                }
            }
            
            tableView.reloadData()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchArrayLink.removeAll()
        self.searchArrayDate.removeAll()
        self.searchResults = self.indexNotice.filter({ (notice) -> Bool in
            
            return (notice["name"] as! String).contains(searchController.searchBar.text!)
        })
        for index in searchResults {
            self.searchArrayLink.append(self.notice_link[index["index"] as! Int])
            self.searchArrayDate.append(self.notice_date[index["index"] as! Int])
        }
        self.beginSearch = true
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.beginSearch = false
        self.searchResults.removeAll()
        self.searchArrayLink.removeAll()
        self.searchArrayDate.removeAll()
        self.tableView.reloadData()
    }
    
}



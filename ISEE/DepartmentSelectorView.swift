

import UIKit

class DepartmentSelectorView: UITableViewController, XMLParserDelegate {
    
    let department = ["全部","信息与电子工程系","电子工程系","微电子学院","信息与电子工程实验教学中心人员","机关人员"]
    let department_title = ["全部","信通所","电子所","微电子所","教学中心人员","机关人员"]
    var waitView = UIView.init()
    var label_wait = UILabel.init()
    var img_wait: UIImageView?
    let waitViewWidth: CGFloat = 100
    let waitViewHeight: CGFloat = 100
    let labelOffsetX: CGFloat = 10
    let labelOffsetY: CGFloat = 70
    let labelWidth: CGFloat = 80
    let labelHeight: CGFloat = 15
    //////////////////////////////
    var string_info_online: String = ""
    var elementName: String?
    var elementAttribute: [String: String]?
    var teacherName: [String] = []//姓名
    var teacherPhoto: [String] = []//照片的链接
    var teacherTitle: [String] = []//教师职称
    var teacherJob: [String] = []//教师所在的系
    var teacherPhone: [String] = []//教师电话
    var teacherDir: [String] = []//研究方向
    var teacherMail: [String] = []//邮箱
    var teacherAddr: [String] = [] //办公室
    var teacherPageLink: [String] = [] //主页链接
    var info_flag: Array<Dictionary<String, Any>> = []
    var dir_flag: Array<Dictionary<String, Any>> = []
    var final_dir_flag: Array<Dictionary<String, Any>> = []
    var final_info_flag: Array<Dictionary<String, Any>> = []
    var phone_flag_bool: Bool = false
    var mail_flag_bool: Bool = false
    var addr_flag_bool: Bool = false
    var card_info: Array<Dictionary<String, Any>> = []
    //refresh controller
    var refreshController = UIRefreshControl.init()
    var alertView = UIView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "院系选择"
        self.tableView.tableFooterView = UIView.init()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        ///------refresh--------
        refreshController.addTarget(self, action: #selector(DepartmentSelectorView.refreshInfo), for: UIControlEvents.valueChanged)
        refreshController.attributedTitle = NSAttributedString.init(string: "重新上网抓取教师信息，更新过程请勿离开！！")
        self.view.addSubview(refreshController)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return department.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "department")
        cell.textLabel?.text = department[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.card_info.removeAll()
        let AllPath: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
        let onePath = AllPath[0] as! String
        let teacherInfoFilePathXintong = onePath + "/ISEE/teachers/xintong.txt"
        let teacherInfoFilePathDianzi = onePath + "/ISEE/teachers/dianzi.txt"
        let teacherInfoFilePathWeidianzi = onePath + "/ISEE/teachers/weidianzi.txt"
        let teacherInfoFilePathShiyan = onePath + "/ISEE/teachers/shiyan.txt"
        let teacherInfoFilePathJiguan = onePath + "/ISEE/teachers/jiguan.txt"
        //从本地获取信息
        let card_info_read_xintong = NSArray.init(contentsOfFile: teacherInfoFilePathXintong)
        let card_info_read_dianzi = NSArray.init(contentsOfFile: teacherInfoFilePathDianzi)
        let card_info_read_weidianzi = NSArray.init(contentsOfFile: teacherInfoFilePathWeidianzi)
        let card_info_read_shiyan = NSArray.init(contentsOfFile: teacherInfoFilePathShiyan)
        let card_info_read_jiguan = NSArray.init(contentsOfFile: teacherInfoFilePathJiguan)
        //都有数据了才算是更新成功
        let refreshOK = card_info_read_xintong != nil && card_info_read_dianzi != nil && card_info_read_weidianzi != nil && card_info_read_shiyan != nil && card_info_read_jiguan != nil
        
        if indexPath.row == 0 {
            
            if refreshOK {
                self.card_info = card_info_read_xintong as! Array<Dictionary<String, Any>>
                //加上电子所
                self.card_info = self.card_info + (card_info_read_dianzi as! Array<Dictionary<String, Any>>)
                //加上微电子所
                self.card_info = self.card_info + (card_info_read_weidianzi as! Array<Dictionary<String, Any>>)
                //加上实验老师
                self.card_info = self.card_info + (card_info_read_shiyan as! Array<Dictionary<String, Any>>)
                //加上机关老师
                self.card_info = self.card_info + (card_info_read_jiguan as! Array<Dictionary<String, Any>>)
            }else {
                let alert = UIAlertController.init(title: "连上网后下拉刷新", message: "刷新之后即可不联网进入教师列表", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }else if indexPath.row == 1 {
            //信通所4页
//            let AllPath: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
//            let onePath = AllPath[0] as! String
//            let teacherInfoFilePathXintong = onePath + "/ISEE/teachers/xintong.txt"
//            let card_info_read = NSArray.init(contentsOfFile: teacherInfoFilePathXintong)
            if refreshOK {
                self.card_info = card_info_read_xintong as! Array<Dictionary<String, Any>>
            }else {
                let alert = UIAlertController.init(title: "连上网后下拉刷新", message: "刷新之后即可不联网进入教师列表", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }else if indexPath.row == 2 {
            //电子所5页
//            let AllPath: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
//            let onePath = AllPath[0] as! String
//            let teacherInfoFilePathDianzi = onePath + "/ISEE/teachers/dianzi.txt"
//            let card_info_read = NSArray.init(contentsOfFile: teacherInfoFilePathDianzi)
            if refreshOK {
                self.card_info = card_info_read_dianzi as! Array<Dictionary<String, Any>>
            }else {
                let alert = UIAlertController.init(title: "连上网后下拉刷新", message: "刷新之后即可不联网进入教师列表", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }else if indexPath.row == 3 {
            //微电子6页
//            let AllPath: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
//            let onePath = AllPath[0] as! String
//            let teacherInfoFilePathWeidianzi = onePath + "/ISEE/teachers/weidianzi.txt"
//            let card_info_read = NSArray.init(contentsOfFile: teacherInfoFilePathWeidianzi)
            if refreshOK {
                self.card_info = card_info_read_weidianzi as! Array<Dictionary<String, Any>>
            }else {
                let alert = UIAlertController.init(title: "连上网后下拉刷新", message: "刷新之后即可不联网进入教师列表", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }else if indexPath.row == 4 {
            //实验教学中心2页
//            let AllPath: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
//            let onePath = AllPath[0] as! String
//            let teacherInfoFilePathShiyan = onePath + "/ISEE/teachers/shiyan.txt"
//            let card_info_read = NSArray.init(contentsOfFile: teacherInfoFilePathShiyan)
            if refreshOK {
                self.card_info = card_info_read_shiyan as! Array<Dictionary<String, Any>>
            }else {
                let alert = UIAlertController.init(title: "连上网后下拉刷新", message: "刷新之后即可不联网进入教师列表", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }else {
            //机关人员2页
//            let AllPath: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
//            let onePath = AllPath[0] as! String
//            let teacherInfoFilePathJiguan = onePath + "/ISEE/teachers/jiguan.txt"
//            let card_info_read = NSArray.init(contentsOfFile: teacherInfoFilePathJiguan)
            if refreshOK {
                self.card_info = card_info_read_jiguan as! Array<Dictionary<String, Any>>
            }else {
                let alert = UIAlertController.init(title: "连上网后下拉刷新", message: "刷新之后即可不联网进入教师列表", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        //传值
        let vc = TeachersListViewController()
        vc.navigation_title = department_title[indexPath.row]
        vc.card_info = self.card_info
        self.navigationController?.pushViewController(vc as UIViewController, animated: true)
        
    }
    
    func refreshInfo() {
        refreshController.beginRefreshing()
//        alertView = UIView.init(frame: CGRect.init(x: self.view.frame.width / 2 - 50, y: self.view.frame.height / 2 - 25, width: 100, height: 50))
//        alertView.backgroundColor = UIColor.gray
//        alertView.isHidden = false
//        self.view.addSubview(alertView)
        let newThread = Thread.init(target: self, selector: #selector(self.getWriteTeacherInfo), object: nil)
        newThread.name = "refresh"
        newThread.start()
        //getWriteTeacherInfo()
    }
    //start label
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        self.elementName = elementName
        self.elementAttribute = attributeDict
        if self.elementName == "img" {
            //姓名和照片，一定都有的吧
            self.teacherName.append(attributeDict["alt"]!)
            self.teacherPhoto.append(attributeDict["src"]!)
        }
        phone_flag_bool = false
    }
    
    //content
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //print("elementName:\(self.elementName!)")
        //print("attribute:\(self.elementAttribute!)")
        //print("content:\(string)")
        //职称，一定有的吧
        if self.elementName == "td" && self.elementAttribute?["width"] == "10%" && self.elementAttribute?["height"] == "120" && self.elementAttribute?["align"] == "center" && self.elementAttribute?["bgcolor"] == "#FFFFFF" && string != "" {
            let new_string = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if new_string != "" {
                self.teacherTitle.append(new_string)
            }
        }
        //所在的所，都有的吧
        if self.elementName == "td" && self.elementAttribute?["width"] == "15%" && self.elementAttribute?["align"] == "center" && self.elementAttribute?["bgcolor"] == "#FFFFFF" && string != "" {
            let new_string = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if new_string != "" {
                self.teacherJob.append(new_string)
            }
        }
        //研究方向，有的有，有的没有，这里要改！！！！！
        if self.elementName == "td" && self.elementAttribute?["width"] == "20%" && self.elementAttribute?["align"] == "center" && self.elementAttribute?["bgcolor"] == "#FFFFFF" && string != "" {
            let new_string = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if new_string != "" {
                self.teacherDir.append(new_string)
                let dic: Dictionary<String, Any> = ["name":self.teacherName.last!, "dir": true]
                self.dir_flag.append(dic)
            }else {
                let dic: Dictionary<String, Any> = ["name":self.teacherName.last!, "dir": false]
                self.dir_flag.append(dic)
            }
        }
        //电话 邮箱 办公室 有的有，有的没有
        if self.elementName == "br" && string != "" {
            //print(string)
            var new_string = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            new_string = new_string.trimmingCharacters(in: CharacterSet.controlCharacters)
            //print(new_string)
            let mailPattern = "^.*@.*$"
            let phonePattern = "[0-9-()]{7,18}"
            let addrPattern = "[\\u4e00-\\u9fa5]"
            let mail_regex = MyRegex(mailPattern)
            let phone_regex = MyRegex(phonePattern)
            let addr_regex = MyRegex(addrPattern)
            if new_string != "" && mail_regex.match(new_string) {
                self.teacherMail.append(new_string)
            }
            if new_string != "" && phone_regex.match(new_string) {
                self.teacherPhone.append(new_string)
            }
            if new_string != "" && addr_regex.match(new_string) {
                self.teacherAddr.append(new_string)
            }
            //phone mail addr flag
            self.phone_flag_bool = phone_regex.match(string)
            self.mail_flag_bool = mail_regex.match(string)
            self.addr_flag_bool = addr_regex.match(string)
            if self.teacherName != [] {
                let dic: Dictionary<String, Any> = ["name": self.teacherName.last!, "phone": self.phone_flag_bool, "mail": self.mail_flag_bool, "addr": self.addr_flag_bool]
                info_flag.append(dic)
            }
        }
        let personLinkPattern = "^http://mypage\\.zju\\.edu.cn/.*$"
        let regex = MyRegex(personLinkPattern)
        
        let namePattern = "[\\u4e00-\\u9fa5]"//汉字
        let EnamePattern = "^([A-Za-z]+\\s?)*[A-Za-z]$"
        let regex_name = MyRegex(namePattern)
        let regex_Ename = MyRegex(EnamePattern)
        if self.elementName == "a" && (regex.match((self.elementAttribute?["href"]!)!)) && (regex_name.match(string) || string == "Thomas Honold") {
            //print("start: \(elementName)")
            //print("content: \(string)")
            self.teacherPageLink.append((self.elementAttribute?["href"])!)
        }
    }
    //end label
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //print("end: \(elementName)")
    }
    func dataPostDispose() {
        for name in self.teacherName {
            var bool_phone: Bool = false
            var bool_mail: Bool = false
            var bool_addr: Bool = false
            var bool_dir: Bool = false
            for item in self.info_flag {
                if (item["name"] as! String) == name {
                    bool_phone = bool_phone || (item["phone"] as! Bool)
                    bool_mail = bool_mail || (item["mail"] as! Bool)
                    bool_addr = bool_addr || (item["addr"] as! Bool)
                }
            }
            for item in self.dir_flag {
                if (item["name"] as! String) == name {
                    bool_dir = bool_dir || (item["dir"] as! Bool)
                }
            }
            let dic = ["name": name, "phone": bool_phone, "mail": bool_mail, "addr": bool_addr,"dir": bool_dir] as [String : Any]
            final_info_flag.append(dic)
        }
        //final info
        var addr_index = 0
        var phone_index = 0
        var mail_index = 0
        var dir_index = 0
        var phone_temp: String = ""
        var mail_temp: String = ""
        var addr_temp: String = ""
        var dir_temp: String = ""
        //print(self.teacherPhone)
        //print(final_info_flag)
        for (index, item_dic) in final_info_flag.enumerated() {
            if item_dic["phone"] as! Bool {
                //print("phoneindex:\(phone_index)")
                phone_temp = self.teacherPhone[phone_index]
                phone_index = phone_index + 1
            }else {
                phone_temp = "暂无"
            }
            if item_dic["mail"] as! Bool {
                mail_temp = self.teacherMail[mail_index]
                mail_index = mail_index + 1
            }else {
                mail_temp = "暂无"
            }
            if item_dic["addr"] as! Bool {
                addr_temp = self.teacherAddr[addr_index]
                addr_index = addr_index + 1
            }else {
                addr_temp = "暂无"
            }
            if item_dic["dir"] as! Bool {
                dir_temp = self.teacherDir[dir_index]
                dir_index = dir_index + 1
            }else {
                dir_temp = "暂无"
            }
            
            let info_for_one: Dictionary<String, Any> = ["name": item_dic["name"]!, "phone": phone_temp, "mail": mail_temp, "addr": addr_temp, "photoLink": self.teacherPhoto[index], "title": self.teacherTitle[index], "department": self.teacherJob[index], "Direction": dir_temp, "pageLink": ""]
            self.card_info.append(info_for_one)
            //print(info_for_one)
        }
    }
    
    func clear() {
        teacherName.removeAll()
        teacherPhoto.removeAll()
        teacherTitle.removeAll()
        teacherJob.removeAll()
        teacherPhone.removeAll()
        teacherDir.removeAll()
        teacherMail.removeAll()
        teacherAddr.removeAll()
        teacherPageLink.removeAll()
        info_flag.removeAll()
        final_info_flag.removeAll()
        dir_flag.removeAll()
    }
    
    func getInfoOnline(path: String) {
        clear()
        if path != "" {
            let url: URL = URL.init(string: path)!
            let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
            do {
                string_info_online = try NSString(contentsOf: url, encoding: enc) as String
            }catch let error as NSError {
                print("error:\(error.description)")
            }
            
            //print(string_info_online)
            if string_info_online != "" {
                string_info_online = string_info_online.replacingOccurrences(of: "&", with: "****")
                string_info_online = string_info_online.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let result_data = string_info_online.data(using: String.Encoding.utf8)
                if result_data != nil {
                    let parser = XMLParser(data: result_data!)
                    parser.delegate = self
                    parser.parse()
                }
            }else {
                let alert = UIAlertController.init(title: "好像没有联网哦", message: "连上网重新进一遍就可以啦", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        dataPostDispose()
    }
    
    func getWriteTeacherInfo() {
        //file path
        let AllPath: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
        let onePath = AllPath[0] as! String
        let teacherInfoFilePathXintong = onePath + "/ISEE/teachers/xintong.txt"
        let teacherInfoFilePathDianzi = onePath + "/ISEE/teachers/dianzi.txt"
        let teacherInfoFilePathWeidianzi = onePath + "/ISEE/teachers/weidianzi.txt"
        let teacherInfoFilePathShiyan = onePath + "/ISEE/teachers/shiyan.txt"
        let teacherInfoFilePathJiguan = onePath + "/ISEE/teachers/jiguan.txt"
        //delete the former one
        let manager = FileManager.default
        if manager.fileExists(atPath: teacherInfoFilePathXintong) {
            try! manager.removeItem(atPath: teacherInfoFilePathXintong)
        }
        if manager.fileExists(atPath: teacherInfoFilePathDianzi) {
            try! manager.removeItem(atPath: teacherInfoFilePathDianzi)
        }
        if manager.fileExists(atPath: teacherInfoFilePathWeidianzi) {
            try! manager.removeItem(atPath: teacherInfoFilePathWeidianzi)
        }
        if manager.fileExists(atPath: teacherInfoFilePathShiyan) {
            try! manager.removeItem(atPath: teacherInfoFilePathShiyan)
        }
        if manager.fileExists(atPath: teacherInfoFilePathJiguan) {
            try! manager.removeItem(atPath: teacherInfoFilePathJiguan)
        }
        
        var card_info_for_write: NSArray = []
        
        //信通所4页
        self.card_info.removeAll()
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?catalog_id=15&cmd=user&zhiwu=1")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=2&zhicheng=&zhiwu=1&tebie=&catalog_id=15")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=3&zhicheng=&zhiwu=1&tebie=&catalog_id=15")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=4&zhicheng=&zhiwu=1&tebie=&catalog_id=15")
        card_info_for_write = NSArray(array: card_info)
        card_info_for_write.write(toFile: teacherInfoFilePathXintong, atomically: true)
        //电子所5页
        self.card_info.removeAll()
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?catalog_id=15&cmd=user&zhiwu=2")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=2&zhicheng=&zhiwu=2&tebie=&catalog_id=15")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=3&zhicheng=&zhiwu=2&tebie=&catalog_id=15")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=4&zhicheng=&zhiwu=2&tebie=&catalog_id=15")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=5&zhicheng=&zhiwu=2&tebie=&catalog_id=15")
        card_info_for_write = NSArray(array: card_info)
        card_info_for_write.write(toFile: teacherInfoFilePathDianzi, atomically: true)
        //微电子6页
        self.card_info.removeAll()
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?catalog_id=15&cmd=user&zhiwu=4")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=2&zhicheng=&zhiwu=4&tebie=&catalog_id=15")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=3&zhicheng=&zhiwu=4&tebie=&catalog_id=15")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=4&zhicheng=&zhiwu=4&tebie=&catalog_id=15")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=5&zhicheng=&zhiwu=4&tebie=&catalog_id=15")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=6&zhicheng=&zhiwu=4&tebie=&catalog_id=15")
        card_info_for_write = NSArray(array: card_info)
        card_info_for_write.write(toFile: teacherInfoFilePathWeidianzi, atomically: true)
        //实验教学中心2页
        self.card_info.removeAll()
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?catalog_id=15&cmd=user&zhiwu=8")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=2&zhicheng=&zhiwu=8&tebie=&catalog_id=15")
        card_info_for_write = NSArray(array: card_info)
        card_info_for_write.write(toFile: teacherInfoFilePathShiyan, atomically: true)
        //机关人员2页
        self.card_info.removeAll()
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?catalog_id=15&cmd=user&zhiwu=16")
        getInfoOnline(path: "http://www.isee.zju.edu.cn/usersearch.php?cmd=user&page=2&zhicheng=&zhiwu=16&tebie=&catalog_id=15")
        card_info_for_write = NSArray(array: card_info)
        card_info_for_write.write(toFile: teacherInfoFilePathJiguan, atomically: true)
        DispatchQueue.main.async { 
            self.refreshController.endRefreshing()
            //self.alertView.isHidden = true
        }
        //refreshController.endRefreshing()
    }
    
}

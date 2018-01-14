

import UIKit
import UserNotifications

class ShowNoticeName: UITableViewController, XMLParserDelegate {
    
    let noticeBachalor = ["本科生总支","本科生教学"];
    let noticePoster = ["研究生总支","研究生教学"];
    let linkBachalor = ["http://www.isee.zju.edu.cn/notice/redir.php?catalog_id=26306","http://www.isee.zju.edu.cn/notice/redir.php?catalog_id=532900"]
    let linkPoster = ["http://www.isee.zju.edu.cn/notice/redir.php?catalog_id=33305","http://www.isee.zju.edu.cn/notice/redir.php?catalog_id=26308"]
    var selectedLink: String = ""
    var listTitle: String = ""
    var setNoticePos: [String: Int] = ["section" : 6, "row" : 6]
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
    //////////////////////////////
    var myView = UIView.init()
    var myLabel = UILabel.init()
    var myImgView = UIImageView.init()
    /////add  gesture
    var imgView = UIImageView.init()
    var gesture = UITapGestureRecognizer.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.tableFooterView = UIView.init()
        
        let headView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.4))
        headView.backgroundColor = UIColor.init(red: 135/255, green: 206/255, blue: 250/255, alpha: 0.8)
        imgView = UIImageView.init(frame: CGRect.init(x: headView.frame.width/2 - 60, y: headView.frame.height/2 - 80, width: 120, height: 120))
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 60
        imgView.image = UIImage(named: "isee.png")
        
        //添加手势
        imgView.isUserInteractionEnabled = true
        gesture = UITapGestureRecognizer.init(target: self, action: #selector(self.gotoISEEWeb))
        imgView.addGestureRecognizer(gesture)
        headView.addSubview(imgView)
        ///
        let label_qinfen = UILabel.init(frame: CGRect.init(x: headView.frame.width / 2 - 120, y: headView.frame.height / 2 + 60, width: 240, height: 30))
        label_qinfen.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0)
        label_qinfen.text = "勤奋又乐观    by ISEEers" 
        label_qinfen.textAlignment = NSTextAlignment.center
        label_qinfen.textColor = UIColor.white
        label_qinfen.font = UIFont.boldSystemFont(ofSize: 20)
        headView.addSubview(label_qinfen)
        self.tableView.tableHeaderView = headView
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(red: 135/255, green: 206/255, blue: 250/255, alpha: 0.5)
        self.navigationController?.navigationBar.tintColor = UIColor.init(red: 0.55, green: 0, blue: 0, alpha: 1)
        //self.tableView.backgroundView = UIImageView.init(image: UIImage(named: "flower.jpg"))
        //store alert row of tableview
        let AllPath: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
        let onePath = AllPath[0] as! String
        
        let notificationFilePath = onePath + "/ISEE/notification/"
        let manager = FileManager.default
        
        if manager.fileExists(atPath: notificationFilePath) {
            do {
                
                let contentArray = try manager.contentsOfDirectory(atPath: notificationFilePath)
                //print("content:\(contentArray)")
                if contentArray != [] {
                    let content = contentArray[0]
                    
                    let contentInt = Int(content)
                    self.setNoticePos["section"] = contentInt! / 10
                    self.setNoticePos["row"] = contentInt! % 10
                    self.tableView.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name.init("link"), object: self.setNoticePos["section"]! == 0 ? linkBachalor[self.setNoticePos["row"]!] : linkPoster[self.setNoticePos["row"]!])
                }
                
            }catch let error as NSError {
                print("content array error:\(error)")
            }
        }
        //catch teacher info online and store at file
        //ISEE/teachers/目录下存储的是各个学院的信息，如果不存在这个路径则创建一个
        let teacherInfoFilePath = onePath + "/ISEE/teachers/"
        let directoryExit = manager.fileExists(atPath: teacherInfoFilePath)
        if !directoryExit {
            try! manager.createDirectory(atPath: teacherInfoFilePath, withIntermediateDirectories: true, attributes: nil)
        }
        //try! manager.removeItem(atPath: teacherInfoFilePath + "xintong.txt")
        //判断是否是第一次启动，如果是的话则从网上获取数据并写入本地
        let firstLauched = UserDefaults.standard.bool(forKey: "firstLauched")
        print(firstLauched)
        if firstLauched {
            //notice view
            myView = UIView.init(frame: CGRect.init(x: self.view.frame.width / 2 - 100, y: self.view.frame.height / 2 - 50, width: 200, height: 100))
            myView.layer.masksToBounds = true
            myView.layer.cornerRadius = 10
            myView.backgroundColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
            myLabel = UILabel.init(frame: CGRect.init(x: myView.frame.minX + 10, y: myView.frame.maxY - 50, width: 180, height: 40))
            myLabel.text = "第一次启动，需要半分钟获取网络信息..."
            myLabel.font = UIFont.systemFont(ofSize: 15)
            myLabel.numberOfLines = 0
            myLabel.textAlignment = NSTextAlignment.center
            myImgView = UIImageView.init(frame: CGRect.init(x: self.view.frame.width / 2 - 15, y: self.myView.frame.minY + 15, width: 30, height: 30))
            myImgView.layer.masksToBounds = true
            myImgView.layer.cornerRadius = 15
            myImgView.image = UIImage.init(named: "face_xx.png")
            self.view.addSubview(myView)
            self.view.addSubview(myLabel)
            self.view.addSubview(myImgView)
            //thread
            let newThread = Thread.init(target: self, selector: #selector(self.getWriteTeacherInfo), object: nil)
            newThread.name = "new"
            newThread.start()
        }
    }
    
    func gotoISEEWeb() {
        let url = URL.init(string: "http://www.isee.zju.edu.cn")
        UIApplication.shared.openURL(url!)
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
                //线程改变UI（回到主线程）
                DispatchQueue.main.async(execute: {
                    self.myView.isHidden = true
                    self.myLabel.isHidden = true
                    self.myImgView.isHidden = true
                })
                let alert = UIAlertController.init(title: "师资信息初始化失败", message: "请连网，进入师资队伍页面下拉刷新", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                print("errorCatch:\(error.description)")
            }
            //print("###\(string_info_online)")
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
                
            }
            
        }
        dataPostDispose()
    }
    
    func getWriteTeacherInfo() {
        print("new thread!!")
        let manager = FileManager.default
        
        //file path
        let AllPath: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
        let onePath = AllPath[0] as! String
        let teacherInfoFilePathXintong = onePath + "/ISEE/teachers/xintong.txt"
        let teacherInfoFilePathDianzi = onePath + "/ISEE/teachers/dianzi.txt"
        let teacherInfoFilePathWeidianzi = onePath + "/ISEE/teachers/weidianzi.txt"
        let teacherInfoFilePathShiyan = onePath + "/ISEE/teachers/shiyan.txt"
        let teacherInfoFilePathJiguan = onePath + "/ISEE/teachers/jiguan.txt"
        var card_info_for_write: NSArray = []
        //delete former one,if exist
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
        //线程改变UI（回到主线程）
        DispatchQueue.main.async(execute: {
            self.myView.isHidden = true
            self.myLabel.isHidden = true
            self.myImgView.isHidden = true
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "  "
        }else {
            if section == 0 {
                return nil
            }
            else {
                return nil
            }
        }
    }
    //view of section
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let section_view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 0))
        //section_view.backgroundColor = UIColor.init(red: 1, green: 0.85, blue: 0.73, alpha: 0.5)
        section_view.backgroundColor = UIColor.white
        return section_view
    }*/
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.noticeBachalor.count
        }else {
            if section == 1 {
                return self.noticePoster.count
            }
            else {
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "NoticeName")
        if (indexPath as NSIndexPath).section == 0 {
            cell.textLabel?.text = noticeBachalor[(indexPath as NSIndexPath).row]
        }else {
            if (indexPath as NSIndexPath).section == 1 {
                cell.textLabel?.text = noticePoster[(indexPath as NSIndexPath).row]
            }
            else {
                cell.textLabel?.text = "师资队伍"
            }
        }
        cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 18)
        //cell.backgroundColor = UIColor.init(red: 1, green: 0.94, blue: 0.84, alpha: 0.5)
        if indexPath.section == self.setNoticePos["section"] && indexPath.row == self.setNoticePos["row"] {
            //cell.backgroundColor = UIColor.init(red: 1, green: 0.94, blue: 0.84, alpha: 0.5)
            cell.textLabel?.textColor = UIColor.init(red: 184/255, green: 134/255, blue: 11/255, alpha: 1)
        }
        if indexPath.section != 2 && indexPath.row == 0 {
            //cell.imageView?.image = UIImage.init(named: "icon_ben_25.png")
        }else if indexPath.section != 2 && indexPath.row == 1 {
            //cell.imageView?.image = UIImage.init(named: "icon_book.png")
        }else {
            //cell.imageView?.image = UIImage.init(named: "icon_find_25.png")
        }
        //cell.imageView?.layer.masksToBounds = true
        //cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.backgroundColor = UIColor.init(red: 135/255, green: 206/255, blue: 250/255, alpha: 0.8)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 2 {
            //self.performSegue(withIdentifier: "gotoTeachers", sender: nil)
            self.navigationController?.pushViewController(DepartmentSelectorView() as UIViewController, animated: true)
        }else {
            if (indexPath as NSIndexPath).section == 0 {
                self.selectedLink = linkBachalor[(indexPath as NSIndexPath).row]
                self.listTitle = noticeBachalor[(indexPath as NSIndexPath).row]
            }
            else {
                self.selectedLink = linkPoster[(indexPath as NSIndexPath).row]
                self.listTitle = noticePoster[(indexPath as NSIndexPath).row]
            }
            if indexPath.section == self.setNoticePos["section"] && indexPath.row == self.setNoticePos["row"] {
                self.performSegue(withIdentifier: "gotoList", sender: ["link": self.selectedLink, "flag": true])
            }else {
                self.performSegue(withIdentifier: "gotoList", sender: ["link": self.selectedLink, "flag": false])
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if indexPath.section != 2 {
            if self.setNoticePos["section"] == indexPath.section && self.setNoticePos["row"] == indexPath.row {
                return "取消通知提醒"
            }else {
                return "开启通知提醒"
            }
        }
        else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if indexPath.section != 2 {
            let AllPath: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
            let onePath = AllPath[0] as! String
            let notificationFilePath = onePath + "/ISEE/notification/"
            let manager = FileManager.default
            
            if editingStyle == UITableViewCellEditingStyle.delete {
                
                if indexPath.section == self.setNoticePos["section"] && indexPath.row == self.setNoticePos["row"] {
                    //cancel the former setting
                    self.setNoticePos["section"] = 6 //default
                    self.setNoticePos["row"] = 6 //default
                    let path = notificationFilePath + "\(indexPath.section)" + "\(indexPath.row)"
                    try! manager.removeItem(atPath: path)
                    
                    tableView.cellForRow(at: indexPath)?.textLabel?.textColor = UIColor.black
                    //tableView.cellForRow(at: indexPath)?.endEditing(true)
                    //tableView.endEditing(true)
                    NotificationCenter.default.post(name: NSNotification.Name.init("link"), object: "")
                    //update
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "initial_count"), object: 0)
                    
                }else {
                    if self.setNoticePos["section"] == 6 && self.setNoticePos["row"] == 6 {
                        //no other settings been set
                        self.setNoticePos["section"] = indexPath.section
                        self.setNoticePos["row"] = indexPath.row
                        let path = notificationFilePath + "\(indexPath.section)" + "\(indexPath.row)"
                        //print("store:\(path)")
                        try! manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                        
                        tableView.cellForRow(at: indexPath)?.textLabel?.textColor = UIColor.init(red: 184/255, green: 134/255, blue: 11/255, alpha: 1)
                        tableView.cellForRow(at: indexPath)?.setEditing(false, animated: true)
                        NotificationCenter.default.post(name: NSNotification.Name.init("link"), object: indexPath.section == 0 ? linkBachalor[indexPath.row] : linkPoster[indexPath.row])
                        //update
                        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "initial_count"), object: 0)
                        
                    }else {
                        //you set other setting before
                        let alert = UIAlertController.init(title: "抱歉～您只能设置一个通知点", message: "请先取消原有的通知点设置，然后再设置本条通知", preferredStyle: UIAlertControllerStyle.alert)
                        //let alertAction = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                        let alertAction = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: { (action) in
                            tableView.cellForRow(at: indexPath)?.endEditing(true)
                            tableView.endEditing(true)
                        })
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let VC = segue.destination as! NoticeListController
        let result: Dictionary<String, Any> = sender as! Dictionary<String, Any>
        VC.noticePath = result["link"] as! String?
        VC.initial_count_trans_flag = result["flag"] as! Bool?
        VC.titleName = self.listTitle
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
//        let personLinkPattern = "^http://mypage\\.zju\\.edu.cn/.*$"
//        let regex = MyRegex(personLinkPattern)
//        
//        let namePattern = "[\\u4e00-\\u9fa5]"//汉字
//        let EnamePattern = "^([A-Za-z]+\\s?)*[A-Za-z]$"
//        let regex_name = MyRegex(namePattern)
//        let regex_Ename = MyRegex(EnamePattern)
//        if self.elementName == "a" && regex_name.match(string) && (regex.match((self.elementAttribute?["href"]!)!)) {
//            self.teacherPageLink.append((self.elementAttribute?["href"])!)
//        }
    }
    //end label
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //print("end: \(elementName)")
    }
}

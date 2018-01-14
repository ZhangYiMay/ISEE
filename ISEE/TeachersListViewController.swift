
import UIKit

class TeachersListViewController: UITableViewController, XMLParserDelegate, UISearchBarDelegate {
    
    var card_info: Array<Dictionary<String, Any>> = []
    var navigation_title = ""
    
    //search controller
    var searchController =  UISearchController.init()
    var searchResult: Array<Dictionary<String, Any>> = []
    var searchCondition: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = navigation_title
        self.tableView.tableFooterView = UIView.init()
        //self.tableView.rowHeight = 100
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //search controller settings
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.delegate = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = true
            controller.searchBar.searchBarStyle = UISearchBarStyle.default
            controller.searchBar.placeholder = "输入姓名或研究方向"
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        //test
        //print("number:\(self.card_info.count), content:\(self.card_info)")
        
//        print("number:\(self.teacherTitle.count) : \(self.teacherTitle)")
//        print("number:\(self.teacherJob.count) : \(self.teacherJob)")
//        print("number:\(self.teacherDir.count) : \(self.teacherDir)")
//        print("number:\(self.teacherName.count) : \(self.teacherName)")
//        print("number:\(self.teacherPhoto.count) : \(self.teacherPhoto)")
//        print("number:\(self.teacherMail.count) : \(self.teacherMail)")
//        print("number:\(self.teacherPhone.count) : \(self.teacherPhone)")
//        print("number:\(self.teacherAddr.count) : \(self.teacherAddr)")
//        print("number:\(self.dir_flag.count): \(self.dir_flag)")
//        print("number:\(self.teacherPageLink.count): \(self.teacherPageLink)")
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchCondition {
            return searchResult.count
        }else {
            return card_info.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "teacherListCell")
        
        if self.searchCondition {
            let oneCard = self.searchResult[indexPath.row]
            cell.textLabel?.text = oneCard["name"] as! String?
            cell.detailTextLabel?.text = oneCard["Direction"] as! String
        }else {
            let oneCard = self.card_info[indexPath.row]
            cell.textLabel?.text = oneCard["name"] as! String?
            cell.detailTextLabel?.text = oneCard["Direction"] as! String
        }
        
        cell.textLabel?.textAlignment = NSTextAlignment.left
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.detailTextLabel?.textColor = UIColor.gray
        cell.textLabel?.numberOfLines = 0
        //cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TeacherInfoCard()
        if self.searchCondition {
            vc.card_info = self.searchResult[indexPath.row]
        }else {
            vc.card_info = self.card_info[indexPath.row]
        }
        
        self.navigationController?.pushViewController(vc as UIViewController, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchCondition = true
        self.searchResult.removeAll()
        self.searchResult = self.card_info.filter({(card_info_item) -> Bool in
            return ((card_info_item["name"] as! String).contains(searchController.searchBar.text!) || ((card_info_item["Direction"] as! String).contains(searchController.searchBar.text!)))
        })
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchCondition = false
        self.searchResult.removeAll()
        self.tableView.reloadData()
    }
}

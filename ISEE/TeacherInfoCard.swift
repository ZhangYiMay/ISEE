
import UIKit

class TeacherInfoCard: UITableViewController {
    
    var card_title = ""
    var info: [String] = []
    var photoLink: String?
    var card_info: Dictionary<String, Any>? {
        didSet {
            //print("card_info:\(card_info)")
            //info.append(self.card_info?["name"] as! String)
            info.append(self.card_info?["title"] as! String)
            info.append(self.card_info?["department"] as! String)
            info.append(self.card_info?["phone"] as! String)
            info.append(self.card_info?["mail"] as! String)
            info.append(self.card_info?["addr"] as! String)
            info.append(self.card_info?["Direction"] as! String)
            self.photoLink = card_info?["photoLink"] as! String
        }
    }
    let sec = ["职称","院系","电话","邮箱","办公室",""]
    var photoView = UIImageView.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = card_title
        self.tableView.tableFooterView = UIView.init()
        
        let viewUp = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.3))
        viewUp.backgroundColor = UIColor.white
        let viewSky = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height * 0.26))
        viewSky.backgroundColor = UIColor.init(red: 135/255, green: 206/255, blue: 250/255, alpha: 0.8)
        viewUp.addSubview(viewSky)
        let photoBg = UIImageView.init(frame: CGRect.init(x: self.view.frame.width - 103, y: self.view.frame.height * 0.3 - 87, width: 87, height: 87))
        photoBg.backgroundColor = UIColor.gray
        viewUp.addSubview(photoBg)
        photoView = UIImageView.init(frame: CGRect.init(x: self.view.frame.width - 100, y: self.view.frame.height * 0.3 - 85, width: 85, height: 85))
        photoView.backgroundColor = UIColor.gray
        //photoView.layer.masksToBounds = true
        //photoView.layer.cornerRadius = 50
        let newThread = Thread.init(target: self, selector: #selector(self.getPhotoOnline), object: nil)
        newThread.start()
        viewUp.addSubview(photoView)
        let label_name = UILabel.init(frame: CGRect.init(x: 15, y: self.view.frame.height * 0.3 - 85 + 30, width: self.view.frame.width - 100, height: 20))
        label_name.text = self.card_info?["name"] as! String
        label_name.font = UIFont.boldSystemFont(ofSize: 20)
        //label_name.textAlignment = NSTextAlignment.center
        viewUp.addSubview(label_name)
        self.tableView.tableHeaderView = viewUp
    }
    
    func getPhotoOnline() {
        let url = NSURL(string: "http://www.isee.zju.edu.cn" + self.photoLink!)
        let photoData = NSData.init(contentsOf: url as! URL)
        if photoData != nil {
            DispatchQueue.main.async(execute: { 
                self.photoView.image = UIImage.init(data: photoData as! Data)
            })
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: "detailInfo")
        cell.textLabel?.text = self.info[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = self.sec[indexPath.row]
        tableView.estimatedRowHeight = 20
        tableView.rowHeight = UITableViewAutomaticDimension
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


import UIKit

class NoticeContentViewController: UIViewController, XMLParserDelegate {
    
    var result_string: String?
    var notice = ""
    var elementName: String = ""
    var attribute : Dictionary<String, String> = [:]
    
    
    //var test = "<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=gb2312\" /><title>研究生科【校内通知】 - 浙江大学信息与电子工程学系</title><script type=\"text/javascript\" src=\"/template/js/cgFixPng.js\"></script><!--[if lt IE 7 ]><script type=\"text/javascript\" src=\"/template/js/cgFixPng.js\"></script><script type=\"text/javascript\">cgFixPng.fix('div, img, a, li, .png, h2, h1');</script><![endif]--><script>window.onload=function(){var pic_array=document.images;var pic_num=pic_array.length;var width=660;     var height=420;  offset_height;var offset_width;var nh=1;for (var i=0;i<pic_num;i++){offset_height = pic_array[i].offsetHeight;offset_width = pic_array[i].offsetWidth;if(offset_width>width && offset_height >= height){nh = width/offset_width;pic_array[i].height = offset_height*nh;pic_array[i].width = width;}}}</script></head>"
    
    @IBOutlet weak var label_title: UILabel!
    
    @IBOutlet weak var linkBtn: UIButton!
    
    @IBAction func getLinkOnline(_ sender: AnyObject) {
        let url = URL(string: noticeLink!)
        UIApplication.shared.openURL(url!)
    }
    
    @IBOutlet weak var noticeContentTv: UITextView!
    
    var noticeLink: String? {
        didSet {
            if noticeLink != nil {
                
                //linkBtn.titleLabel?.text = noticeLink!
                getNoticeContent(self.noticeLink!)
            }
            
        }
    }
    
    var noticeTitle: String? {
        didSet {
            //self.label_title.text = noticeTitle!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.init(red: 1, green: 1, blue: 240/255, alpha: 1)
        self.title = "通知内容"
        self.noticeContentTv.isEditable = false
        self.label_title.numberOfLines = 0
        self.label_title.text = noticeTitle!
        self.label_title.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0)
        
        //getNoticeContent(self.noticeLink!)
        self.noticeContentTv.text = notice
        self.noticeContentTv.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNoticeContent(_ path: String) {
        //print(path)
        let url = URL(string: path)
        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        do {
            result_string = try NSString(contentsOf: url!, encoding: enc) as String
        }catch let error as NSError {
            print("error in content getting:\(error.description)")
        }
        //print(result_string!)
        //print("---------end--------")
        
        if result_string != nil {
            //注释掉可恶的函数中的特殊字符<
            result_string = result_string?.replacingOccurrences(of: "i<pic_num", with: "")
            result_string = result_string?.replacingOccurrences(of: "offset_width>width && offset_height >= height", with: "")
            
            //print(result_string!)
            //print("------------end------------")
            let result_data = result_string?.data(using: String.Encoding.utf8)
            if result_data != nil {
                let parser = XMLParser(data: result_data!)
                parser.delegate = self
                parser.parse()
                //print(notice)
                
            }
        }else {
            let alert = UIAlertController(title: "啊欧～这个网页不能被解析～", message: "请直接戳下方链接进网页查看内容", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction.init(title: "我知道了", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        //print("elementName:\(elementName)")
        //print("attribute:\(attributeDict)")
        self.elementName = elementName
        self.attribute = attributeDict
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //print("content:\(string)")
        if self.elementName == "td" || (self.elementName == "span" && self.attribute != [:]) {
            notice = notice + string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //print("end:\(elementName)")
        
    }
}

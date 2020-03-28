import UIKit
import WebKit

class ViewController: UIViewController , WKUIDelegate,  WKScriptMessageHandler{

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var containerView: UIView!

    //뒤로가기
    @IBAction func back(_ sender: Any) {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    //앞으로가기
    @IBAction func forward(_ sender: Any) {
        if self.webView.canGoForward {
            self.webView.goForward()
        }
    }
    
    override func loadView() {
        super.loadView()

        //웹뷰가 전체 영역 차지함
//        webView = WKWebView(frame: self.view.frame)
//        webView.uiDelegate = self
//        webView.navigationDelegate = self
//        self.view = self.webView
        
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        
        //native -> js call
        //문서 시작시에만 가능한, 환경설정으로 사용함, source 부분에 함수 대신 html직접 삽입 가능
        let userScript = WKUserScript(source:"redHeader()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        
        //js -> native call
        //name의 값을 지정하여, js에서 webkit.messageHandlers.NAME.postMessage(""); 와 연동되는것
        //userContentController 함수에서 처리한다
        contentController.add(self, name: "callbackHandler")
        
        config.userContentController = contentController
        
//        webView = WKWebView(frame: self.containerView.frame, configuration: config)//웹뷰크기를 컨테이너뷰에 크기에 맞춘다
        webView = WKWebView(frame: self.view.frame, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        //self.view = self.webView!
        self.view.addSubview(webView)
    }
    
    //JS -> Native call
    @available(iOS 8.0, *)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            print(message.body)
            myAlert(title: "js -> Native call", message: message.body as! String)
            abc()
        }
    }
    
    func abc() {
        print("abc call")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let goUrl: String = "http://49.161.33.13:8080/api/ios_webview"
//        let goUrl: String = "http://daum.net"

//        loadWebPage("http://paikdabang.com/store/")
//        loadWebPage(goUrl)
        
        //첫 페이지 설정 : loadWebPage와 동일기능 참고
        self.request(url: goUrl)
    }
    
    //현재 webView에서 받아온 URL 페이지를 로드한다. 방법1
    func loadWebPage(_ url: String) {
        let myUrl = URL(string: url)
        let myRequest = URLRequest(url: myUrl!)
        webView.load(myRequest)
    }

    //현재 webView에서 받아온 URL 페이지를 로드한다. 방법2
    func request(url: String) {
        self.webView.load(URLRequest(url: URL(string: url)!))
        self.webView.navigationDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //alert 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: {(action) in completionHandler()}))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //confirm 처리
    
    //confirm 처리2
    
    //href="_blank" 처리
    
    //중복적으로 리로드 방지
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    //myAlert
    func myAlert(title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        //handler 는 처리후에 실행될 콜백함수 인데 후처리 없어서 nil , 알럿 OK버튼 클릭시 후처리 할 수 있음.
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

//searchBar에서 검색하면 searchBar에 입력된 주소를 요청한다.
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.request(url: searchBar.text!)
        
        //다른곳을 터치하면 키보드가 내려갈 수 있도록 한다.
//        self.view.endEdition(true)
    }
}

//현재 웹페이지의 URL을 searchBar에 띄워준다.
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.searchBar.text = webView.url?.absoluteString
    }
}



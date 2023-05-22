//
//  StripeTermsOfServiceViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/1/23.
//

import UIKit
import WebKit

class StripeTermsOfServiceViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.load(URLRequest(url: URL(string: "https://stripe.com/legal/connect-account")!))
        
        }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    

}

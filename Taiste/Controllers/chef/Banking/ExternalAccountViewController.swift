//
//  ExternalAccountViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/23/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase


class ExternalAccountViewController: UIViewController {

    let db = Firestore.firestore()
    
    //ExternalAccount View
    @IBOutlet weak var bankName: UITextField!
    @IBOutlet weak var accountHolderName: UITextField!
    @IBOutlet weak var accountNumber: UITextField!
    @IBOutlet weak var routingNumber: UITextField!
    
    var stripeAccountId = ""
    var externalAccountId = ""
    var externalAccount : ExternalAccount?
    
    var newInfoOrEditedInfo = ""
    var newAccountOrEditedAccount = ""
    
    var individualOrBusiness = ""
    var individualBankingInfo : IndividualBankingInfo?
    var businessBankingInfo : BusinessBankingInfo?
    
    
    
    @IBOutlet weak var bankingSaveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        if individualOrBusiness == "Individual" {
            if individualBankingInfo?.externalAccount != nil {
                bankName.text = individualBankingInfo!.externalAccount!.bankName
                accountHolderName.text = individualBankingInfo!.externalAccount!.accountHolder
                accountNumber.text = individualBankingInfo!.externalAccount!.accountNumber
                routingNumber.text = individualBankingInfo!.externalAccount!.routingNumber
            }
        } else if individualOrBusiness == "Business" {
            if businessBankingInfo?.externalAccount != nil {
                bankName.text = businessBankingInfo!.externalAccount!.bankName
                accountHolderName.text = businessBankingInfo!.externalAccount!.accountHolder
                accountNumber.text = businessBankingInfo!.externalAccount!.accountNumber
                routingNumber.text = businessBankingInfo!.externalAccount!.routingNumber
            }
        }
        // Do any additional setup after loading the view.
    }
    
    private func createExternalAccount(stripeAccountId: String) {
        let json: [String: Any] = ["stripeAccountId" : "\(stripeAccountId)", "account_holder" : "\(self.externalAccount!.accountHolder)", "account_number": "\(self.externalAccount!.accountNumber)", "routing_number" : "\(self.externalAccount!.routingNumber)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/create-bank-account")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let externalAccount = json["externalAccount"],
                let self = self else {
            // Handle error
            return
            }
            DispatchQueue.main.async {
                let data : [String:Any] = ["id" : stripeAccountId, "externalAccount" : "\(externalAccount)"]
                self.db.collection("Chef").document("\(Auth.auth().currentUser!.email!)").collection("BankingInfo").document(UUID().uuidString).setData(data)
            }
        })
        task.resume()
    }
    
    private func deleteExternalAccount(stripeAccountId: String, externalAccount: String) {
        let json: [String: Any] = ["stripeAccountId" : "\(stripeAccountId)", "externalAccountId" : "\(externalAccount)"]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/delete-bank-account")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let self = self else {
            // Handle error
            return
            }
            
        })
        task.resume()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func bankingSaveButtonPressed(_ sender: Any) {
        if bankName.text == "" {
            self.showToast(message: "Please enter your bank name.", font: .systemFont(ofSize: 12))
        } else if accountHolderName.text == "" {
            showToast(message: "Please enter the account holder's name.", font: .systemFont(ofSize: 12))
        } else if accountNumber.text == "" {
            showToast(message: "Please enter your account number.", font: .systemFont(ofSize: 12))
        } else if routingNumber.text == "" || routingNumber.text!.count != 9 {
            showToast(message: "Please enter a valid routing number.", font: .systemFont(ofSize: 12))
        } else {
            if newAccountOrEditedAccount == "new" {
                var externalAccount = ExternalAccount(bankName: self.bankName.text!, accountHolder: self.accountHolderName.text!, accountNumber: self.accountNumber.text!, routingNumber: self.routingNumber.text!, id: "")
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController  {
                    
                    if self.individualOrBusiness == "Individual" {
                        self.individualBankingInfo!.externalAccount = externalAccount
                        vc.external = "Individual"
                        vc.individualBankingInfo = self.individualBankingInfo!
                    } else {
                        self.businessBankingInfo!.externalAccount = externalAccount
                        vc.external = "Business"
                        vc.businessBankingInfo = self.businessBankingInfo!
                    }
                    self.present(vc, animated: true, completion: nil)
                }
                
            } else {
                
                var stripeAccountId = ""
                var externalAccountId = ""
                if individualOrBusiness == "Individual" {
                    stripeAccountId = individualBankingInfo!.stripeAccountId
                    externalAccountId = individualBankingInfo!.externalAccount!.id
                } else {
                    stripeAccountId = businessBankingInfo!.stripeAccountId
                    externalAccountId = businessBankingInfo!.externalAccount!.id
                }
                
                var externalAccount = ExternalAccount(bankName: self.bankName.text!, accountHolder: self.accountHolderName.text!, accountNumber: self.accountNumber.text!, routingNumber: self.routingNumber.text!, id: externalAccountId)
                
                let alert = UIAlertController(title: "Are you sure you want to continue? This will delete your external account.", message: nil, preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
                    
                    
                    self.deleteExternalAccount(stripeAccountId: stripeAccountId, externalAccount: externalAccountId)
                    self.createExternalAccount(stripeAccountId: stripeAccountId)
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController  {
                        
                        if self.individualOrBusiness == "Individual" {
                            self.individualBankingInfo!.externalAccount = externalAccount
                            vc.external = "Individual"
                            vc.individualBankingInfo = self.individualBankingInfo!
                        } else {
                            self.businessBankingInfo!.externalAccount = externalAccount
                            vc.external = "Business"
                            vc.businessBankingInfo = self.businessBankingInfo!
                        }
                        self.present(vc, animated: true, completion: nil)
                    }
                }))
                
                
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
                    
                    alert.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func bankingDeleteButtonPressed(_ sender: Any) {
    }
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height-180, width: (self.view.frame.width), height: 70))
        toastLabel.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.numberOfLines = 4
        toastLabel.layer.cornerRadius = 1;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

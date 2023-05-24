//
//  PersonViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/23/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

class OwnersViewController: UIViewController {
    
    let db = Firestore.firestore()
    

    @IBOutlet weak var owner1Label: UILabel!
    @IBOutlet weak var owner2Label: UILabel!
    @IBOutlet weak var owner3Label: UILabel!
    @IBOutlet weak var owner4Label: UILabel!
    
    
    var newInfoOrEditedInfo = ""
    var newAccountOrEditedAccount = ""
    var representativeId = ""
    var personId = ""
    var stripeAccountId = ""
    var representativeOrOwner = ""
    
    var businessBankingInfo : BusinessBankingInfo?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if businessBankingInfo != nil {
            if businessBankingInfo!.owner1 != nil {
                if businessBankingInfo!.owner1!.firstName != "" {
                owner1Label.text = "\(businessBankingInfo!.owner1!.firstName) \(businessBankingInfo!.owner1!.lastName)"
            }
        }
            if businessBankingInfo!.owner2 != nil {
                if businessBankingInfo!.owner2!.firstName != "" {
                    owner2Label.text = "\(businessBankingInfo!.owner2!.firstName) \(businessBankingInfo!.owner2!.lastName)"
                }
            }
            if businessBankingInfo!.owner3 != nil {
                if businessBankingInfo!.owner3!.firstName != "" {
                    owner3Label.text = "\(businessBankingInfo!.owner3!.firstName) \(businessBankingInfo!.owner3!.lastName)"
                }
            }
            if businessBankingInfo!.owner4 != nil {
                if businessBankingInfo!.owner4!.firstName != "" {
                    owner4Label.text = "\(businessBankingInfo!.owner4!.firstName) \(businessBankingInfo!.owner4!.lastName)"
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPresse(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

    @IBAction func owner1ButtonPressed(_ sender: Any) {
        if newAccountOrEditedAccount == "new" && businessBankingInfo?.owner1 == nil {
            businessBankingInfo!.owner1 = Representative(isPersonAnOwner: "", isPersonAnExectutive: "", firstName: "", lastName: "", month: "", day: "", year: "", streetAddress: "", city: "", state: "", zipCode: "", emailAddress: "", phoneNumber: "", last4OfSSN: "", id: "")
        }
        
        if newAccountOrEditedAccount == "new" && businessBankingInfo?.externalAccount == nil {
            businessBankingInfo!.externalAccount = ExternalAccount(bankName: "", accountHolder: "", accountNumber: "", routingNumber: "", id: "")
        }
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
          
            vc.businessBankingInfo = businessBankingInfo!
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representativeOrOwner = "owner1"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func owner2ButtonPressed(_ sender: Any) {
        if newAccountOrEditedAccount == "new" && businessBankingInfo?.owner2 == nil {
            businessBankingInfo!.owner1 = Representative(isPersonAnOwner: "", isPersonAnExectutive: "", firstName: "", lastName: "", month: "", day: "", year: "", streetAddress: "", city: "", state: "", zipCode: "", emailAddress: "", phoneNumber: "", last4OfSSN: "", id: "")
        }
        
        if newAccountOrEditedAccount == "new" && businessBankingInfo?.externalAccount == nil {
            businessBankingInfo!.externalAccount = ExternalAccount(bankName: "", accountHolder: "", accountNumber: "", routingNumber: "", id: "")
        }
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
          
            vc.businessBankingInfo = businessBankingInfo!
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representativeOrOwner = "owner2"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func owner3ButtonPressed(_ sender: Any) {
        if newAccountOrEditedAccount == "new" && businessBankingInfo?.owner3 == nil {
            businessBankingInfo!.owner1 = Representative(isPersonAnOwner: "", isPersonAnExectutive: "", firstName: "", lastName: "", month: "", day: "", year: "", streetAddress: "", city: "", state: "", zipCode: "", emailAddress: "", phoneNumber: "", last4OfSSN: "", id: "")
        }
        
        if newAccountOrEditedAccount == "new" && businessBankingInfo?.externalAccount == nil {
            businessBankingInfo!.externalAccount = ExternalAccount(bankName: "", accountHolder: "", accountNumber: "", routingNumber: "", id: "")
        }
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
          
            vc.businessBankingInfo = businessBankingInfo!
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representativeOrOwner = "owner3"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func owner4ButtonPressed(_ sender: Any) {
        if newAccountOrEditedAccount == "new" && businessBankingInfo?.owner4 == nil {
            businessBankingInfo!.owner1 = Representative(isPersonAnOwner: "", isPersonAnExectutive: "", firstName: "", lastName: "", month: "", day: "", year: "", streetAddress: "", city: "", state: "", zipCode: "", emailAddress: "", phoneNumber: "", last4OfSSN: "", id: "")
        }
        
        if newAccountOrEditedAccount == "new" && businessBankingInfo?.externalAccount == nil {
            businessBankingInfo!.externalAccount = ExternalAccount(bankName: "", accountHolder: "", accountNumber: "", routingNumber: "", id: "")
        }
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
          
            vc.businessBankingInfo = businessBankingInfo!
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representativeOrOwner = "owner4"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if newAccountOrEditedAccount == "new" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController  {
                vc.external = "Business"
                vc.businessBankingInfo = self.businessBankingInfo!
                self.present(vc, animated: true)
            }
        } else {
            var b = 0
            if businessBankingInfo?.owner1 != nil {
                b = 1
            }
            if businessBankingInfo?.owner2 != nil {
                b = 2
            }
            if businessBankingInfo?.owner3 != nil {
                b = 3
            }
            if businessBankingInfo?.owner4 != nil {
                b = 4
            }
            if b == 0 {
                showToast(message: "Please add atleast 1 owner.", font: .systemFont(ofSize: 12))
            }
            for i in 0..<b {
                var end = ""
                
                if i == 0 {
                    if b - 1 == i { end = "end" }
                    createPerson(representative: businessBankingInfo!.owner1!, last: end)
                } else if i == 1 {
                    if b - 1 == i { end = "end" }
                    createPerson(representative: businessBankingInfo!.owner2!, last: end)
                } else if i == 2 {
                    if b - 1 == i { end = "end" }
                    createPerson(representative: businessBankingInfo!.owner3!, last: end)
                } else if i == 3 {
                    if b - 1 == i { end = "end" }
                    createPerson(representative: businessBankingInfo!.owner4!, last: end)
                }
                
            }
            
        }
    }
    
    private func createPerson(representative: Representative, last: String) {
        var rep = ""
        
        var name = ""
        if businessBankingInfo != nil {
            if businessBankingInfo!.representative != nil {
               name = "\(businessBankingInfo!.representative!.firstName) \(businessBankingInfo!.representative!.lastName) \(businessBankingInfo!.representative!.last4OfSSN)"
            }
        }
        if name != "\(representative.firstName) \(representative.lastName) \(representative.last4OfSSN)" {
               
        let json : [String:Any] = ["account_Id" : "\(representative.id)", "first_name" : "\(representative.firstName)", "last_name" : "\(representative.lastName)", "dob_day" : "\(representative.day)", "dob_month" : "\(representative.month)", "dob_year" : "\(representative.year)", "line_1" : "\(representative.streetAddress)", "line_2" : "", "postal_code" : "\(representative.zipCode)", "city" : "\(representative.city)", "state" : "\(representative.state)", "email" : "\(representative.emailAddress)", "phone" : "\(representative.phoneNumber)", "id_number" : "\(representative.last4OfSSN)" , "title" : "Owner", "representative" : false, "owner" : "Yes", "executive" : "\(representative.isPersonAnExectutive)"]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/create-person")!)
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
                
                DispatchQueue.main.async {
                    if last == "end" {
                        
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Owners") as? OwnersViewController  {
                            
                            vc.businessBankingInfo = self.businessBankingInfo!
                            self.present(vc, animated: true)
                        }
                    }
                    
                    }
            })
            task.resume()
    
        }
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
    
}

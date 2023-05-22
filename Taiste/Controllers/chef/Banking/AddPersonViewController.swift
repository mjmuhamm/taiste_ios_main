//
//  AddPersonViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/1/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth



class AddPersonViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var newInfoOrEditedInfo = "new"
    var newAccountOrEditedAccount = "new"
    var bankingOrPerson = ""
    var individualOrBanking = ""
    var representativeOrOwner = ""
    
    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var disclaimerLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var personView: UIView!
    @IBOutlet weak var externalAccountView: UIView!
    
    //Person View
    @IBOutlet weak var isPersonAnOwnerYes: UIButton!
    @IBOutlet weak var isPersonAnOwnerNo: UIButton!
    @IBOutlet weak var isPersonAnExectutiveYes: UIButton!
    @IBOutlet weak var isPersonAnExectutiveNo: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var month: UITextField!
    @IBOutlet weak var day: UITextField!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var streetAddress: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var last4OfSSN: UITextField!
    
    //ExternalAccount View
    @IBOutlet weak var bankName: UITextField!
    @IBOutlet weak var accountHolderName: UITextField!
    @IBOutlet weak var accountNumber: UITextField!
    @IBOutlet weak var routingNumber: UITextField!
    
    var representative : Representative?
    var externalAccount : ExternalAccount?
    
    @IBOutlet weak var bankingSaveButton: UIButton!
    @IBOutlet weak var personSaveButton: UIButton!
    
    
    private var isPersonAnOwner = "Yes"
    private var isPersonAnExectutive = "Yes"
    
    var stripeAccountId = ""
    var externalAccountId = ""
    var personId = ""
    var representativeId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if newAccountOrEditedAccount == "edit" {
//            bankingSaveButton.isEnabled = false
            personSaveButton.isEnabled = false
        } else {
            bankingSaveButton.isEnabled = true
            personSaveButton.isEnabled = true
        }
        if newInfoOrEditedInfo.prefix(4) == "edit" && representativeOrOwner == "owner"  {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
        
        if bankingOrPerson == "banking" {
            personView.isHidden = true
            externalAccountView.isHidden = false
        } else {
            personView.isHidden = false
            externalAccountView.isHidden = true
        }
        
        
        if representative != nil {
            if representativeOrOwner == "representative" {
                disclaimerLabel.text = "The representative will be the manager of this account and must be an owner or executive of the business."
                personLabel.text = "Representative"
            } else if representativeOrOwner == "owner" {
                disclaimerLabel.text = "All owners with more than 25% ownership must be reported."
                personLabel.text = "Owner"
            }
            if representative!.isPersonAnOwner == "Yes" {
            isPersonAnOwnerYes.setTitleColor(UIColor.white, for: .normal)
            isPersonAnOwnerYes.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
            isPersonAnOwnerNo.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            isPersonAnOwnerNo.backgroundColor = UIColor.white
            isPersonAnOwner = "Yes"
            } else {
                isPersonAnOwnerNo.setTitleColor(UIColor.white, for: .normal)
                isPersonAnOwnerNo.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                isPersonAnOwnerYes.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                isPersonAnOwnerYes.backgroundColor = UIColor.white
                isPersonAnOwner = "No"
            }
            if representative!.isPersonAnExectutive == "Yes" {
                isPersonAnExectutiveYes.setTitleColor(UIColor.white, for: .normal)
                isPersonAnExectutiveYes.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                isPersonAnExectutiveNo.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                isPersonAnExectutiveNo.backgroundColor = UIColor.white
                isPersonAnExectutive = "Yes"
            } else {
                isPersonAnExectutiveNo.setTitleColor(UIColor.white, for: .normal)
                isPersonAnExectutiveNo.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                isPersonAnExectutiveYes.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                isPersonAnExectutiveYes.backgroundColor = UIColor.white
                isPersonAnExectutive = "No"
            }
            firstName.text = representative!.firstName
            lastName.text = representative!.lastName
            month.text = representative!.month
            day.text = representative!.day
            year.text = representative!.year
            streetAddress.text = representative!.streetAddress
            city.text = representative!.city
            state.text = representative!.state
            zipCode.text = representative!.zipCode
            emailAddress.text = representative!.emailAddress
            phoneNumber.text = representative!.phoneNumber
            last4OfSSN.text = representative!.last4OfSSN
        }
        
        if externalAccount != nil {
            bankName.text = externalAccount!.bankName
            accountHolderName.text = externalAccount!.accountHolder
            accountNumber.text = externalAccount!.accountNumber
            routingNumber.text = externalAccount!.routingNumber
            self.personLabel.text = "Banking"
        }
        

        // Do any additional setup after loading the view.
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
    
    private func createExternalAccount(stripeAccountId: String) {
        let json: [String: Any] = ["stripeAccountId" : "\(stripeAccountId)", "account_holder" : "\(self.externalAccount!.accountHolder)", "account_number": "\(self.externalAccount!.accountNumber)", "routing_number" : "\(self.externalAccount!.routingNumber)", "account_type" : "\(individualOrBanking)"]
        
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
        
    private func createPerson() {
        var rep = "No"
        if representativeOrOwner == "representative" {
            rep = "Yes"
        }
        let json : [String:Any] = ["account_Id" : "\(stripeAccountId)", "first_name" : "\(firstName.text!)", "last_name" : "\(lastName.text!)", "dob_day" : "\(day.text!)", "dob_month" : "\(month.text!)", "dob_year" : "\(year.text!)", "line_1" : "\(streetAddress.text!)", "line_2" : "", "postal_code" : "\(zipCode.text!)", "city" : "\(city.text!)", "state" : "\(state.text!)", "email" : "\(emailAddress.text!)", "phone" : "\(phoneNumber.text!)", "id_number" : "\(last4OfSSN.text!)" , "title" : "Owner", "representative" : "\(rep)", "owner" : "Yes", "executive" : "\(isPersonAnExectutive)"]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/create-person")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                    let id = json["id"] as? String,
                      
                    let self = self else {
                // Handle error
                return
                }
                
                DispatchQueue.main.async {
                    
                    }
            })
            task.resume()
    
        
    }
    
    private func deletePerson(stripeId: String, personId: String) {
        let json : [String:Any] = ["stripeAccountId" : "\(stripeId)", "personId" : "\(personId)"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/delete-person")!)
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
                
                }
        })
        task.resume()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    //Person
    @IBAction func isPersonAnOwnerYesPressed(_ sender: Any) {
            isPersonAnOwnerYes.setTitleColor(UIColor.white, for: .normal)
            isPersonAnOwnerYes.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
            isPersonAnOwnerNo.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            isPersonAnOwnerNo.backgroundColor = UIColor.white
        isPersonAnOwner = "Yes"
        
    }
    
    @IBAction func isPersonAnOwnerNoPressed(_ sender: Any) {
            isPersonAnOwnerNo.setTitleColor(UIColor.white, for: .normal)
            isPersonAnOwnerNo.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
            isPersonAnOwnerYes.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            isPersonAnOwnerYes.backgroundColor = UIColor.white
            isPersonAnOwner = "No"
    }
    
    @IBAction func isPersonAnExecutiveYesPressed(_ sender: Any) {
        isPersonAnExectutiveYes.setTitleColor(UIColor.white, for: .normal)
        isPersonAnExectutiveYes.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        isPersonAnExectutiveNo.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        isPersonAnExectutiveNo.backgroundColor = UIColor.white
        isPersonAnExectutive = "Yes"
    }
    
    @IBAction func isPersonAnExecutiveNoPressed(_ sender: Any) {
        isPersonAnExectutiveNo.setTitleColor(UIColor.white, for: .normal)
        isPersonAnExectutiveNo.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        isPersonAnExectutiveYes.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        isPersonAnExectutiveYes.backgroundColor = UIColor.white
        isPersonAnExectutive = "No"
        
    }
    //Person Save Button
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if firstName.text == "" {
            self.showToast(message: "Please enter your first name.", font: .systemFont(ofSize: 12))
        } else if lastName.text == "" {
            self.showToast(message: "Please enter your last name.", font: .systemFont(ofSize: 12))
        } else if month.text == "" {
            self.showToast(message: "Please enter your birth month.", font: .systemFont(ofSize: 12))
        } else if day.text == "" {
            self.showToast(message: "Please enter your birth day.", font: .systemFont(ofSize: 12))
        } else if year.text == "" {
            self.showToast(message: "Please enter your birth year.", font: .systemFont(ofSize: 12))
        } else if streetAddress.text == "" || city.text == "" || state.text == "" || zipCode.text == "" {
            self.showToast(message: "Please enter your street address.", font: .systemFont(ofSize: 12))
        } else if emailAddress.text == "" || !isValidEmail(emailAddress.text!){
            self.showToast(message: "Please enter your email address.", font: .systemFont(ofSize: 12))
        } else if phoneNumber.text == "" || phoneNumber.text?.count != 10 {
            self.showToast(message: "Please enter your phone number", font: .systemFont(ofSize: 12))
        } else if last4OfSSN.text == "" || last4OfSSN.text?.count != 9 {
            self.showToast(message: "Please enter your ssn", font: .systemFont(ofSize: 12))
        } else {
            representative = Representative(isPersonAnOwner: isPersonAnOwner, isPersonAnExectutive: isPersonAnExectutive, firstName: firstName.text!, lastName: lastName.text!, month: month.text!, day: day.text!, year: year.text!, streetAddress: streetAddress.text!, city: city.text!, state: state.text!, zipCode: zipCode.text!, emailAddress: emailAddress.text!, phoneNumber: phoneNumber.text!, last4OfSSN: last4OfSSN.text!, id: "")
            
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController  {
                if self.representativeOrOwner == "representative" {
                    vc.representative = self.representative
                    vc.addRepresentativeLabel.text = "\(firstName.text!) \(lastName.text!)"
                    if self.newAccountOrEditedAccount == "edit" {
                        deletePerson(stripeId: stripeAccountId, personId: representativeId)
                        createPerson()
                    }
                    if isPersonAnOwner == "Yes" {
                        if let index = vc.owners.firstIndex(where: { "\($0.firstName) \($0.lastName) \($0.last4OfSSN)" == "\(self.representative!.firstName) \(self.representative!.lastName) \(self.representative!.last4OfSSN)" }) {
                            
                            vc.owners[index] = self.representative!
                            if index == 0 {
                                vc.addOwnerLabel.text = "\(self.firstName.text!) \(self.lastName.text!)"
                                vc.businessSaveConstraint.constant = 41.5
                            } else if index == 1 {
                                vc.addOwner2Stack.isHidden = false
                                vc.addOwner2Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                                vc.businessSaveConstraint.constant = 80.5
                            } else if index == 2 {
                                vc.addOwner3Stack.isHidden = false
                                vc.addOwner3Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                                vc.businessSaveConstraint.constant = 101.5
                            } else {
                                vc.addOwner4Stack.isHidden = false
                                vc.addOwner4Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                                vc.businessSaveConstraint.constant = 147.5
                                vc.addOwnerButton.isHidden = true
                            }
                        } else {
                            
                            vc.owners.append(self.representative!)
                            if vc.owners.count == 1 {
                                vc.addOwnerLabel.text = "\(self.firstName.text!) \(self.lastName.text!)"
                                vc.businessSaveConstraint.constant = 41.5
                            } else if vc.owners.count == 2 {
                                vc.addOwner2Stack.isHidden = false
                                vc.addOwner2Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                                vc.businessSaveConstraint.constant = 80.5
                            } else if vc.owners.count == 3 {
                                vc.addOwner3Stack.isHidden = false
                                vc.addOwner3Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                                vc.businessSaveConstraint.constant = 101.5
                            } else {
                                vc.addOwner4Stack.isHidden = false
                                vc.addOwner4Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                                vc.businessSaveConstraint.constant = 147.5
                                vc.addOwnerButton.isHidden = true
                            }
                        }
                    }
                } else {
                    if self.newAccountOrEditedAccount == "edit" {
                        deletePerson(stripeId: stripeAccountId, personId: representative!.id)
                        createPerson()
                    }
                    if self.newInfoOrEditedInfo == "new" {
                    vc.owners.append(self.representative!)
                        if vc.owners.count == 1 {
                            vc.addOwnerLabel.text = "\(self.firstName.text!) \(self.lastName.text!)"
                            vc.businessSaveConstraint.constant = 41.5
                        } else if vc.owners.count == 2 {
                            vc.addOwner2Stack.isHidden = false
                            vc.addOwner2Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                            vc.businessSaveConstraint.constant = 80.5
                        } else if vc.owners.count == 3 {
                            vc.addOwner3Stack.isHidden = false
                            vc.addOwner3Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                            vc.businessSaveConstraint.constant = 101.5
                        } else {
                            vc.addOwner4Stack.isHidden = false
                            vc.addOwner4Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                            vc.businessSaveConstraint.constant = 147.5
                            vc.addOwnerButton.isHidden = true
                        }
                    } else {
                        if newInfoOrEditedInfo.suffix(1) == "0" {
                            vc.addOwnerLabel.text = "\(self.firstName.text!) \(self.lastName.text!)"
                            vc.businessSaveConstraint.constant = 41.5
                        } else if newInfoOrEditedInfo.suffix(1) == "1" {
                            vc.addOwner2Stack.isHidden = false
                            vc.addOwner2Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                            vc.businessSaveConstraint.constant = 80.5
                        } else if newInfoOrEditedInfo.suffix(1) == "2" {
                            vc.addOwner3Stack.isHidden = false
                            vc.addOwner3Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                            vc.businessSaveConstraint.constant = 101.5
                        } else {
                            vc.addOwner4Stack.isHidden = false
                            vc.addOwner4Label.text = "\(self.firstName.text!) \(self.lastName.text!)"
                            vc.businessSaveConstraint.constant = 147.5
                            vc.addOwnerButton.isHidden = true
                        }
                        vc.owners[Int(self.newInfoOrEditedInfo.suffix(1))!] = self.representative!
                    }
                }
                    self.present(vc, animated: true, completion: nil)
            }
        }
        
        
        
    }
    
    //Banking
    @IBAction func bankingSaveButtonPressed(_ sender: Any) {
        
        if newAccountOrEditedAccount == "edit" {
            let alert = UIAlertController(title: "Please make sure that there are no pending deposits before continuing.", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (handler) in
                    if self.bankName.text == "" {
                        self.showToast(message: "Please enter your bank name", font: .systemFont(ofSize: 12))
                    } else if self.accountHolderName.text == "" {
                        self.showToast(message: "Please enter the account holder", font: .systemFont(ofSize: 12))
                    } else if self.accountNumber.text == "" {
                        self.showToast(message: "Please enter your account number", font: .systemFont(ofSize: 12))
                    } else if self.routingNumber.text == "" {
                        self.showToast(message: "Please enter your routing number", font: .systemFont(ofSize: 12))
                    } else {
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController  {
                        vc.externalAccountInfo = ExternalAccount(bankName: self.bankName.text!, accountHolder: self.accountHolderName.text!, accountNumber: self.accountNumber.text!, routingNumber: self.routingNumber.text!, id: "")
                        if self.individualOrBanking == "individual" {
                            vc.addAccountText.text = "****\(self.accountNumber.text!.suffix(4))"
                        } else {
                            vc.bAddAccountText.text = "****\(self.accountNumber.text!.suffix(4))"
                        }
                            
                        self.deleteExternalAccount(stripeAccountId: self.stripeAccountId,externalAccount: self.externalAccountId)
                        self.createExternalAccount(stripeAccountId: self.stripeAccountId)
                        self.present(vc, animated: true, completion: nil)
                    }
                        
                    }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (handler) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            if bankName.text == "" {
                self.showToast(message: "Please enter your bank name", font: .systemFont(ofSize: 12))
            } else if accountHolderName.text == "" {
                self.showToast(message: "Please enter the account holder", font: .systemFont(ofSize: 12))
            } else if accountNumber.text == "" {
                self.showToast(message: "Please enter your account number", font: .systemFont(ofSize: 12))
            } else if routingNumber.text == "" {
                self.showToast(message: "Please enter your routing number", font: .systemFont(ofSize: 12))
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController  {
                vc.externalAccountInfo = ExternalAccount(bankName: bankName.text!, accountHolder: accountHolderName.text!, accountNumber: accountNumber.text!, routingNumber: routingNumber.text!, id: "")
                if individualOrBanking == "individual" {
                    vc.addAccountText.text = "****\(accountNumber.text!.suffix(4))"
                } else {
                    vc.bAddAccountText.text = "****\(accountNumber.text!.suffix(4))"
                }
                    self.present(vc, animated: true, completion: nil)
            }
                
                
            }
        }
        
        
    }
    
    @IBAction func delerteButtonPressed(_ sender: UIButton) {
        if newAccountOrEditedAccount == "new" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController  {
                    if let index = vc.owners.firstIndex(where: { "\($0.firstName) \($0.lastName) \($0.last4OfSSN)" == "\(self.representative!.firstName) \(self.representative!.lastName) \($0.last4OfSSN)" }) {
                        vc.owners.remove(at: index)
                        if vc.owners.count == 0 {
                            vc.addOwnerLabel.text = "Add Owner"
                        } else if vc.owners.count == 1 {
                            vc.addOwnerLabel.text = "\(vc.owners[0].firstName) \(vc.owners[0].lastName)"
                            vc.addOwner2Stack.isHidden = true
                            vc.businessSaveConstraint.constant = 41.5
                        } else if vc.owners.count == 2 {
                            vc.addOwnerLabel.text = "\(vc.owners[0].firstName) \(vc.owners[0].lastName)"
                            vc.addOwner2Label.text = "\(vc.owners[1].firstName) \(vc.owners[1].lastName)"
                            vc.addOwner3Stack.isHidden = true
                            vc.businessSaveConstraint.constant = 80.5
                        } else if vc.owners.count == 3 {
                            vc.addOwnerLabel.text = "\(vc.owners[0].firstName) \(vc.owners[0].lastName)"
                            vc.addOwner2Label.text = "\(vc.owners[1].firstName) \(vc.owners[1].lastName)"
                            vc.addOwner3Label.text = "\(vc.owners[2].firstName) \(vc.owners[2].lastName)"
                            vc.addOwner4Stack.isHidden = true
                            vc.addOwnerButton.isHidden = false
                            vc.businessSaveConstraint.constant = 101.5
                        }
                    }
                self.present(vc, animated: true, completion: nil)
                }
                
                
        } else {
            let alert = UIAlertController(title: "Are you sure you want to delete this person?", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (handler) in
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController  {
                            if let index = vc.owners.firstIndex(where: { $0.id == self.representative!.id}) {
                                vc.owners.remove(at: index)
                                if vc.owners.count == 0 {
                                    vc.addOwnerLabel.text = "Add Owner"
                                } else if vc.owners.count == 1 {
                                    vc.addOwnerLabel.text = "\(vc.owners[0].firstName) \(vc.owners[0].lastName)"
                                    vc.addOwner2Stack.isHidden = true
                                    vc.businessSaveConstraint.constant = 41.5
                                } else if vc.owners.count == 2 {
                                    vc.addOwnerLabel.text = "\(vc.owners[0].firstName) \(vc.owners[0].lastName)"
                                    vc.addOwner2Label.text = "\(vc.owners[1].firstName) \(vc.owners[1].lastName)"
                                    vc.addOwner3Stack.isHidden = true
                                    vc.businessSaveConstraint.constant = 80.5
                                } else if vc.owners.count == 3 {
                                    vc.addOwnerLabel.text = "\(vc.owners[0].firstName) \(vc.owners[0].lastName)"
                                    vc.addOwner2Label.text = "\(vc.owners[1].firstName) \(vc.owners[1].lastName)"
                                    vc.addOwner3Label.text = "\(vc.owners[2].firstName) \(vc.owners[2].lastName)"
                                    vc.addOwner4Stack.isHidden = true
                                    vc.addOwnerButton.isHidden = false
                                    vc.businessSaveConstraint.constant = 101.5
                                }
                        }
                    self.deletePerson(stripeId: self.stripeAccountId, personId: self.representative!.id)
                        self.dismiss(animated: true)
                        }
                }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (handler) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
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


func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)

    
}

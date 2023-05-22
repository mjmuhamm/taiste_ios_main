//
//  ChefBankingViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 4/29/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import MaterialComponents

class ChefBankingViewController: UIViewController {
    
    let db = Firestore.firestore()

    @IBOutlet weak var individualButton: MDCButton!
    @IBOutlet weak var businessButton: MDCButton!
    
    @IBOutlet weak var individualView: UIView!
    @IBOutlet weak var businessView: UIView!
    
    //Individual
    @IBOutlet weak var iAcceptButton: UIButton!
    @IBOutlet weak var iAcceptCircle: UIImageView!
    @IBOutlet weak var mccCode: UITextField!
    @IBOutlet weak var businessUrl: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var month: UITextField!
    @IBOutlet weak var day: UITextField!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var streetAddress: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var addAccountText: UILabel!
    @IBOutlet weak var last4ofSSN: UITextField!
    
    //Business
    @IBOutlet weak var bIAcceptButton: UIButton!
    @IBOutlet weak var bMCCCode: UITextField!
    @IBOutlet weak var bBusinessURL: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var bIAcceptCircle: UIImageView!
    @IBOutlet weak var bStreetAddress: UITextField!
    @IBOutlet weak var bCity: UITextField!
    @IBOutlet weak var bState: UITextField!
    @IBOutlet weak var bZipCode: UITextField!
    @IBOutlet weak var bAddAccountText: UILabel!
    @IBOutlet weak var companyPhone: UITextField!
    @IBOutlet weak var companyTaxId: UITextField!
    @IBOutlet weak var addRepresentativeLabel: UILabel!
    
    @IBOutlet weak var addOwnerButton: UIButton!
    
    @IBOutlet weak var addOwner1Stack: UIStackView!
    @IBOutlet weak var addOwnerLabel: UILabel!
    
    @IBOutlet weak var addOwner2Stack: UIStackView!
    @IBOutlet weak var addOwner2Label: UILabel!
    
    @IBOutlet weak var addOwner3Stack: UIStackView!
    @IBOutlet weak var addOwner3Label: UILabel!
    
    @IBOutlet weak var addOwner4Stack: UIStackView!
    @IBOutlet weak var addOwner4Label: UILabel!
    
    @IBOutlet weak var businessSaveConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var bankingOrPerson = "person"
    private var individualOrBanking = "business"
    private var representativeOrOwner = "owner"
    var newInfoOrEditedInfo = "new"
    var newAccountOrEditedAccount = "new"
    
    private var termsOfServiceAccept = ""
    
    var externalAccountInfo : ExternalAccount?
    var representative : Representative?
    var owners : [Representative] = []
    
    private var stripeAccountId = ""
    private var externalAccountId = ""
    private var representativeId = ""
    private var personId = ""
    
    @IBOutlet weak var bSaveButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    var ownerTransfer : Representative?
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        
        
        print("wift address \(getWiFiAddress())")

        if newAccountOrEditedAccount == "new" {
            bSaveButton.setTitle("Continue", for: .normal)
            saveButton.setTitle("Continue", for: .normal)
        } else {
            loadBankingInfo()
            bSaveButton.setTitle("Save", for: .normal)
            saveButton.setTitle("Save", for: .normal)
        }
        // Do any additional setup after loading the view.
    }
    
    private func loadBankingInfo() {
        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BankingInfo").getDocuments { documents, error in
            if error == nil {
            if documents != nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let accountType = data["accountType"] as? String, let externalAccountId = data["externalAccountId"] as? String, let stripeAccountId = data["stripeAccountId"] as? String {
                        
                        self.externalAccountId = externalAccountId
                        self.stripeAccountId = stripeAccountId
                        self.deleteAccountButton.isHidden = false
                        if accountType == "Individual" {
                            self.termsOfServiceAccept = "Yes"
                            self.individualView.isHidden = false
                            self.businessView.isHidden = true
                            self.iAcceptCircle.image = UIImage(systemName: "circle.fill")
                            self.individualButton.setTitleColor(UIColor.white, for: .normal)
                            self.individualButton.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                            self.businessButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                            self.businessButton.backgroundColor = UIColor.white
                            self.loadIndividualBankingInfo(stripeAccountId: stripeAccountId)
                            self.loadExternalAccount(stripeAccountId: stripeAccountId, externalAccountId: externalAccountId)
                        } else {
                            if let representativeId = data["representativeId"] as? String {
                                
                            self.termsOfServiceAccept = "Yes"
                            self.individualView.isHidden = true
                            self.businessView.isHidden = false
                            self.bIAcceptCircle.image = UIImage(systemName: "circle.fill")
                            self.businessButton.setTitleColor(UIColor.white, for: .normal)
                            self.businessButton.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                            self.individualButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                            self.individualButton.backgroundColor = UIColor.white
                            self.loadBusinessBankingInfo(stripeAccountId: stripeAccountId)
                            self.loadExternalAccount(stripeAccountId: stripeAccountId, externalAccountId: externalAccountId)
                            self.loadPerson(stripeAccountId: stripeAccountId, personId: representativeId, representative: "yes")
                            }
                        }
                        
                    }
                }
            } else {
                self.newAccountOrEditedAccount = "new"
                self.deleteAccountButton.isHidden = true
            }
            }
        }
    }
    
    private func loadIndividualBankingInfo(stripeAccountId: String) {
        
        let json: [String: Any] = ["stripeAccountId" : stripeAccountId]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/retrieve-individual-account")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let mcc = json["mcc"] as? String,
                  let url = json["url"] as? String,
                  let firstName = json["first_name"] as? String,
                  let lastName = json["last_name"] as? String,
                  let phone = json["phone"],
                  let email = json["email"] as? String,
                  let dobDay = json["dob_day"],
                  let dobMonth = json["dob_month"],
                  let dobYear = json["dob_year"],
                  let line1 = json["line1"] as? String,
                  let postalCode = json["postal_code"],
                  let state = json["state"] as? String,
                  let city = json["city"] as? String,
                   
                
                let self = self else {
            // Handle error
            return
            }
            
            DispatchQueue.main.async {
                print("individual load happening")
                self.mccCode.text = mcc
                self.businessUrl.text = url
                self.firstName.text = firstName
                self.lastName.text = lastName
                self.phoneNumber.text = "\(phone)"
                self.email.text = email
                self.day.text = "\(dobDay)"
                self.month.text = "\(dobMonth)"
                self.year.text = "\(dobYear)"
                self.streetAddress.text = line1
                self.city.text = city
                self.state.text = state
                self.zipCode.text = "\(postalCode)"
                self.last4ofSSN.text = "**********"
                self.last4ofSSN.isEnabled = false
                
                }
        })
        task.resume()
    }
    
    private func loadBusinessBankingInfo(stripeAccountId: String) {
        
            
            let json: [String: Any] = ["stripeAccountId" : stripeAccountId]
            
        
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/retrieve-business-account")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                      let mcc = json["mcc"] as? String,
                      let url = json["url"] as? String,
                      let companyName = json["name"] as? String,
                      let companyPhone = json["phone"],
                      let companyLine1 = json["company_line1"] as? String,
                      let postalCode = json["company_postal_code"],
                      let state = json["company_state"] as? String,
                      let city = json["company_city"] as? String,
                      let persons = json["persons"] as? [[String:Any]],
                       
                    
                    let self = self else {
                // Handle error
                return
                }
                
                DispatchQueue.main.async {
//                    print("persons \(persons)")
                    
                    for i in 0..<persons.count {
                        self.loadPerson(stripeAccountId: stripeAccountId, personId: "\(persons[i]["id"]!)", representative: "no")
                    }
                    
                    self.bMCCCode.text = mcc
                    self.bBusinessURL.text = url
                    self.companyPhone.text = "\(companyPhone)"
                    self.companyName.text = companyName
                    self.bStreetAddress.text = companyLine1
                    self.bCity.text = city
                    self.bState.text = state
                    self.bZipCode.text = "\(postalCode)"
                    self.companyTaxId.text = "**********"
                    self.companyTaxId.isEnabled = false
                    
                    }
            })
            task.resume()
        
    }
    
    private func loadPerson(stripeAccountId: String, personId: String, representative: String) {
                
        let json: [String: Any] = ["stripeAccountId" : stripeAccountId, "personId" : personId]
                
            
                let jsonData = try? JSONSerialization.data(withJSONObject: json)
                // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
                var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/retrieve-person")!)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.httpBody = jsonData
                let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                    guard let data = data,
                        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                          let firstName = json["first_name"] as? String,
                          let lastName = json["last_name"] as? String,
                          let email = json["email"] as? String,
                          let phoneNumber = json["phone_number"],
                          let day = json["dob_day"],
                          let month = json["dob_month"],
                          let year = json["dob_year"],
                          let streetAddress = json["street_address"] as? String,
                          let zipCode = json["zip_code"],
                          let state = json["state"] as? String,
                          let city = json["city"] as? String,
                          let executive = json["executive"],
                          let owner = json["owner"],
                           
                        let self = self else {
                    // Handle error
                    return
                    }
                    
                    DispatchQueue.main.async {
                        if representative == "yes" {
                            self.representative = Representative(isPersonAnOwner: "\(owner)", isPersonAnExectutive: "\(executive)", firstName: firstName, lastName: lastName, month: "\(month)", day: "\(day)", year: "\(year)", streetAddress: streetAddress, city: city, state: state, zipCode: "\(zipCode)", emailAddress: email, phoneNumber: "\(phoneNumber)", last4OfSSN: "*********", id: personId)
                            self.addRepresentativeLabel.text = "\(firstName) \(lastName)"
                            
                            if "\(owner)" == "1" {
                                if let index = self.owners.firstIndex(where: { "\($0.firstName) \($0.lastName) \($0.last4OfSSN)" == "\(self.representative!.firstName) \(self.representative!.lastName) \($0.last4OfSSN)" }) {
                                    self.owners[index] = self.representative!
                                    if index == 0 {
                                    self.addOwnerLabel.text = "\(self.owners[0].firstName) \(self.owners[0].lastName)"
                                } else if self.owners.count == 1 {
                                    self.addOwner2Label.text = "\(self.owners[1].firstName) \(self.owners[1].lastName)"
                                } else if self.owners.count == 2 {
                                    self.addOwner3Label.text = "\(self.owners[2].firstName) \(self.owners[2].lastName)"
                                } else if self.owners.count == 3 {
                                    self.addOwner3Label.text = "\(self.owners[3].firstName) \(self.owners[3].lastName)"
                                }
                                } else {
                                    self.owners.append(self.representative!)
                                    if self.owners.count == 1 {
                                    self.addOwnerLabel.text = "\(self.owners[0].firstName) \(self.owners[0].lastName)"
                                        self.addOwner1Stack.isHidden = false
                                        self.addOwner2Stack.isHidden = true
                                        self.addOwner3Stack.isHidden = true
                                        self.addOwner4Stack.isHidden = true
                                    self.businessSaveConstraint.constant = 41.5
                                } else if self.owners.count == 2 {
                                    self.addOwnerLabel.text = "\(self.owners[0].firstName) \(self.owners[0].lastName)"
                                    self.addOwner2Label.text = "\(self.owners[1].firstName) \(self.owners[1].lastName)"
                                    self.addOwner1Stack.isHidden = false
                                    self.addOwner2Stack.isHidden = false
                                    self.addOwner3Stack.isHidden = true
                                    self.addOwner4Stack.isHidden = true
                                    self.businessSaveConstraint.constant = 80.5
                                } else if self.owners.count == 3 {
                                    self.addOwnerLabel.text = "\(self.owners[0].firstName) \(self.owners[0].lastName)"
                                    self.addOwner2Label.text = "\(self.owners[1].firstName) \(self.owners[1].lastName)"
                                    self.addOwner3Label.text = "\(self.owners[2].firstName) \(self.owners[2].lastName)"
                                    self.addOwner1Stack.isHidden = false
                                    self.addOwner2Stack.isHidden = false
                                    self.addOwner3Stack.isHidden = false
                                    self.addOwner4Stack.isHidden = true
                                    self.businessSaveConstraint.constant = 101.5
                                } else if self.owners.count == 4 {
                                    self.addOwnerLabel.text = "\(self.owners[0].firstName) \(self.owners[0].lastName)"
                                    self.addOwner2Label.text = "\(self.owners[1].firstName) \(self.owners[1].lastName)"
                                    self.addOwner3Label.text = "\(self.owners[2].firstName) \(self.owners[2].lastName)"
                                    self.addOwner3Label.text = "\(self.owners[3].firstName) \(self.owners[3].lastName)"
                                    self.addOwner1Stack.isHidden = false
                                    self.addOwner2Stack.isHidden = false
                                    self.addOwner3Stack.isHidden = false
                                    self.addOwner4Stack.isHidden = false
                                    self.businessSaveConstraint.constant = 147.5
                                }
                                }
                            }
                            
                        } else {
                                if let index = self.owners.firstIndex(where: { "\($0.firstName) \($0.lastName) \($0.phoneNumber)" == "\(firstName) \(lastName) \(phoneNumber)" }) {} else {
                                    
                                    self.owners.append(Representative(isPersonAnOwner: "\(owner)", isPersonAnExectutive: "\(executive)", firstName: firstName, lastName: lastName, month: "\(month)", day: "\(day)", year: "\(year)", streetAddress: streetAddress, city: city, state: state, zipCode: "\(zipCode)", emailAddress: email, phoneNumber: "\(phoneNumber)", last4OfSSN: "**********", id: personId))
                                    print("owner count \(self.owners)")
                                    if self.owners.count == 1 {
                                    self.addOwnerLabel.text = "\(self.owners[0].firstName) \(self.owners[0].lastName)"
                                        self.addOwner1Stack.isHidden = false
                                        self.addOwner2Stack.isHidden = true
                                        self.addOwner3Stack.isHidden = true
                                        self.addOwner4Stack.isHidden = true
                                    self.businessSaveConstraint.constant = 41.5
                                } else if self.owners.count == 2 {
                                    self.addOwnerLabel.text = "\(self.owners[0].firstName) \(self.owners[0].lastName)"
                                    self.addOwner2Label.text = "\(self.owners[1].firstName) \(self.owners[1].lastName)"
                                    self.addOwner1Stack.isHidden = false
                                    self.addOwner2Stack.isHidden = false
                                    self.addOwner3Stack.isHidden = true
                                    self.addOwner4Stack.isHidden = true
                                    self.businessSaveConstraint.constant = 80.5
                                } else if self.owners.count == 3 {
                                    self.addOwnerLabel.text = "\(self.owners[0].firstName) \(self.owners[0].lastName)"
                                    self.addOwner2Label.text = "\(self.owners[1].firstName) \(self.owners[1].lastName)"
                                    self.addOwner3Label.text = "\(self.owners[2].firstName) \(self.owners[2].lastName)"
                                    self.addOwner1Stack.isHidden = false
                                    self.addOwner2Stack.isHidden = false
                                    self.addOwner3Stack.isHidden = false
                                    self.addOwner4Stack.isHidden = true
                                    self.businessSaveConstraint.constant = 101.5
                                } else if self.owners.count == 4 {
                                    self.addOwnerLabel.text = "\(self.owners[0].firstName) \(self.owners[0].lastName)"
                                    self.addOwner2Label.text = "\(self.owners[1].firstName) \(self.owners[1].lastName)"
                                    self.addOwner3Label.text = "\(self.owners[2].firstName) \(self.owners[2].lastName)"
                                    self.addOwner3Label.text = "\(self.owners[3].firstName) \(self.owners[3].lastName)"
                                    self.addOwner1Stack.isHidden = false
                                    self.addOwner2Stack.isHidden = false
                                    self.addOwner3Stack.isHidden = false
                                    self.addOwner4Stack.isHidden = false
                                    self.businessSaveConstraint.constant = 147.5
                                }
                                }}
                        
                        }
                })
                task.resume()
    }
    
    private func loadExternalAccount(stripeAccountId: String, externalAccountId: String) {
        let json: [String: Any] = ["stripeAccountId" : stripeAccountId, "externalAccountId" : externalAccountId]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/retrieve-external-account")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let bankName = json["bank_name"] as? String,
                  let accountHolder = json["account_holder"] as? String,
                  let routingNumber = json["routing_number"],
                  let accountNumber = json["account_number"],
                let self = self else {
            // Handle error
            return
            }
            
            DispatchQueue.main.async {
                self.externalAccountInfo = ExternalAccount(bankName: bankName, accountHolder: accountHolder, accountNumber: "\(accountNumber)", routingNumber: "\(routingNumber)", id: externalAccountId)
                print("extenral Account \(self.externalAccountInfo)")
                self.addAccountText.text = "****\("\(accountNumber)".suffix(4))"
                
                }
        })
        task.resume()
    }
    
    
    private func saveIndividualAccountInfo() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        let json: [String: Any] = ["mcc": "\(mccCode.text!)", "ip" : "\(getWiFiAddress()!)", "url" :"\(businessUrl.text!)", "date": "\(Int(Date().timeIntervalSince1970))", "first_name" : "\(firstName.text!)", "last_name" : "\(lastName.text!)", "dob_day" : "\(day.text!)", "dob_month" : "\(month.text!)", "dob_year" : "\(year.text!)", "line_1" : "\(streetAddress.text!)", "line_2" : "", "postal_code" : "\(zipCode.text!)", "city" : "\(city.text!)", "state" : "\(state.text!)", "email" : "\(email.text!)", "phone" : "\(phoneNumber.text!)", "ssn" : "\(last4ofSSN.text!)", "account_holder" : "\(externalAccountInfo!.accountHolder)", "routing_number" : "\(externalAccountInfo!.routingNumber)", "account_number" : "\(externalAccountInfo!.accountNumber)"]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/create-individual-account")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let id = json["id"] as? String,
                let externalAccountId = json["external_account"] as? String,
                let self = self else {
            // Handle error
            return
            }
            
            DispatchQueue.main.async {
                if self.newAccountOrEditedAccount == "new" {
                    let data : [String : Any] = ["accountType" : "Individual", "stripeAccountId" : id, "externalAccountId" : externalAccountId]
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BankingInfo").document().setData(data)
                    
                    self.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "ChefBankingToHomeSegue", sender: self)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
                }
        })
        task.resume()
        
    }
    
    private func saveBusinessAccountInfo() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        var vari = false
        if representative!.isPersonAnOwner == "Yes" {
            vari = true
        }
        let json: [String: Any] = ["mcc": "\(bMCCCode.text!)", "ip" : "\(getWiFiAddress()!)", "business_url" :"\(bBusinessURL.text!)", "date": "\(Int(Date().timeIntervalSince1970))", "company_name" : "\(companyName.text!)", "company_city" : "\(bCity.text!)", "company_line1" : "\(bStreetAddress.text!)", "company_line2" : "", "company_postal_code" : "\(bZipCode.text!)", "company_state" : "\(bState.text!)", "company_phone" : "\(companyPhone.text!)", "company_tax_id" : "\(companyTaxId.text!)", "account_holder" : "\(externalAccountInfo!.accountHolder)", "routing_number" : "\(externalAccountInfo!.routingNumber)", "account_number" : "\(externalAccountInfo!.accountNumber)", "representative_first_name" : "\(representative!.firstName)", "representative_last_name" : "\(representative!.lastName)", "representative_dob_day" : "\(representative!.day)", "representative_dob_month" : "\(representative!.month)", "representative_dob_year" : "\(representative!.year)", "representative_line_1" : "\(representative!.streetAddress)", "representative_line_2" : "", "representative_postal_code" : "\(representative!.zipCode)", "representative_city" : "\(representative!.city)", "representative_state" : "\(representative!.state)", "representative_email" : "\(representative!.emailAddress)", "representative_phone": "\(representative!.phoneNumber)", "representative_id_number" : "\(representative!.last4OfSSN)", "representative_title" : "Executive", "representative" : true, "representative_owner" : vari, "representative_executive" : true]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/create-business-account")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let id = json["stripeId"] as? String,
                let externalAccountId = json["bankAccountId"] as? String,
                let representativeId = json["representativeId"] as? String,
                let self = self else {
            // Handle error
            return
            }
            
            DispatchQueue.main.async {
                let data : [String : Any] = ["stripeAccountId" : id, "externalAccountId" : externalAccountId, "representativeId" : representativeId, "accountType" : "Business"]
                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BankingInfo").document().setData(data)
                if self.newAccountOrEditedAccount == "new" {
                    if let index = self.owners.firstIndex(where: { "\($0.firstName) \($0.lastName) \($0.last4OfSSN)" == "\(self.representative!.firstName) \(self.representative!.lastName) \(self.representative!.last4OfSSN)" }) {
                        self.owners.remove(at: index)
                    }
                    if self.owners.count == 0 {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.performSegue(withIdentifier: "ChefBankingToHomeSegue", sender: self)
                    } else {
                    for i in 0..<self.owners.count {
                        self.createPerson(stripeAccountId: id, i: i)
                    }
                    }
                    
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
                }
        })
        task.resume()
        
    }
    
    
    private func createPerson(stripeAccountId: String, i: Int) {
        
            let json : [String:Any] = ["account_id" : "\(stripeAccountId)", "first_name" : "\(owners[i].firstName)", "last_name" : "\(owners[i].lastName)", "dob_day" : "\(owners[i].day)", "dob_month" : "\(owners[i].month)", "dob_year" : "\(owners[i].year)", "line_1" : "\(owners[i].streetAddress)", "line_2" : "", "postal_code" : "\(owners[i].zipCode)", "city" : "\(owners[i].city)", "state" : "\(owners[i].state)", "email" : "\(owners[i].emailAddress)", "phone" : "\(owners[i].phoneNumber)", "id_number" : "\(owners[i].last4OfSSN)" , "title" : "Owner", "representative" : false, "owner" : true, "executive" : false]
            
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
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    if i == self.owners.count - 1 {
                    self.performSegue(withIdentifier: "ChefBankingToHomeSegue", sender: self)
                    }
                    }
            })
            task.resume()
        
        
    }
    
    
    private func updateIndividualAccount() {
        let json: [String: Any] = ["mcc": "\(mccCode.text!)", "url" :"\(businessUrl.text!)", "first_name" : "\(firstName.text!)", "last_name" : "\(lastName.text!)", "dob_day" : "\(day.text!)", "dob_month" : "\(month.text!)", "dob_year" : "\(year.text!)", "line_1" : "\(streetAddress.text!)", "line_2" : "", "postal_code" : "\(zipCode.text!)", "city" : "\(city.text!)", "state" : "\(state.text!)", "email" : "\(email.text!)", "phone" : "\(phoneNumber.text!)"]
        
        
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/update-individual-account")!)
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
                self.performSegue(withIdentifier: "ChefBankingToHomeSegue", sender: self)
            }
        })
        task.resume()
    }
    
    private func updateBusinessAccount() {
        let json: [String: Any] = ["mcc": "\(bMCCCode.text!)", "url" :"\(bBusinessURL.text!)", "company_name" : "\(companyName.text!)", "company_city" : "\(bCity.text!)", "company_line1" : "\(bStreetAddress.text!)", "company_line2" : "", "company_postal_code" : "\(bZipCode.text!)", "company_state" : "\(bState.text!)", "company_phone" : "\(companyPhone.text!)"]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/update-business-account")!)
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
                self.performSegue(withIdentifier: "ChefBankingToHomeSegue", sender: self)
            }
        })
        task.resume()
    }
    
    private func deleteAccount(stripeAccountId: String) {
        let json: [String: Any] = ["stripeAccountId": stripeAccountId]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/delete-account")!)
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
                self.showToast(message: "Account Deleted.", font: .systemFont(ofSize: 12))
            }
        })
        task.resume()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func individualButtonPressed(_ sender: Any) {
        
        if newAccountOrEditedAccount == "edit" {
            
            
                let alert = UIAlertController(title: "Are you sure you want to continue? This will delete your stripe bank account.", message: nil, preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
                    self.deleteAccount(stripeAccountId: self.stripeAccountId)
                    self.bMCCCode.text = ""
                    self.bBusinessURL.text = ""
                    self.companyPhone.text = ""
                    self.companyName.text = ""
                    self.bStreetAddress.text = ""
                    self.bCity.text = ""
                    self.bState.text = ""
                    self.bZipCode.text = ""
                    self.companyTaxId.text = ""
                    self.bAddAccountText.text = ""
                    self.addRepresentativeLabel.text = ""
                    self.representative = nil
                    self.addOwnerLabel.text = ""
                    self.addOwner2Label.text = ""
                    self.addOwner3Label.text = ""
                    self.addOwner4Label.text = ""
                    self.addOwner2Stack.isHidden = true
                    self.addOwner3Stack.isHidden = true
                    self.addOwner4Stack.isHidden = true
                    self.owners.removeAll()
                    self.businessSaveConstraint.constant = 41.5
                    self.companyTaxId.isEnabled = true
                    self.newAccountOrEditedAccount = "new"
                    self.externalAccountInfo = nil
                    
                    self.bIAcceptCircle.image = UIImage(systemName: "circle")
                    self.termsOfServiceAccept = ""
                    self.individualView.isHidden = false
                    self.businessView.isHidden = true
                    self.individualButton.setTitleColor(UIColor.white, for: .normal)
                    self.individualButton.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                    self.businessButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                    self.businessButton.backgroundColor = UIColor.white
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
                   
                        alert.dismiss(animated: true, completion: nil)
                    }))
                
                
                present(alert, animated: true, completion: nil)
                
        } else {
            termsOfServiceAccept = ""
            individualView.isHidden = false
            businessView.isHidden = true
            individualButton.setTitleColor(UIColor.white, for: .normal)
            individualButton.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
            businessButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            businessButton.backgroundColor = UIColor.white
        }
        
        
    }
    
    @IBAction func businessButtonPressed(_ sender: Any) {
        if newAccountOrEditedAccount == "edit" {
            
                let alert = UIAlertController(title: "Are you sure you want to continue? This will delete your stripe bank account.", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
               
                self.deleteAccount(stripeAccountId: self.stripeAccountId)
            self.mccCode.text = ""
            self.businessUrl.text = ""
            self.firstName.text = ""
            self.lastName.text = ""
            self.phoneNumber.text = ""
            self.email.text = ""
            self.day.text = ""
            self.month.text = ""
            self.year.text = ""
            self.streetAddress.text = ""
            self.city.text = ""
            self.state.text = ""
            self.zipCode.text = ""
            self.last4ofSSN.text = ""
            self.last4ofSSN.isEnabled = true
            self.addAccountText.text = ""
            self.externalAccountInfo = nil
            self.newAccountOrEditedAccount = "new"
                
            self.termsOfServiceAccept = ""
                self.iAcceptCircle.image = UIImage(systemName: "circle")
            self.individualView.isHidden = true
            self.businessView.isHidden = false
            self.individualButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            self.individualButton.backgroundColor = UIColor.white
            self.businessButton.setTitleColor(UIColor.white, for: .normal)
            self.businessButton.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                
            alert.dismiss(animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
               
                    alert.dismiss(animated: true, completion: nil)
                }))
            present(alert, animated: true, completion: nil)
            
        } else {
            
            termsOfServiceAccept = ""
            individualView.isHidden = true
            businessView.isHidden = false
            individualButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            individualButton.backgroundColor = UIColor.white
            businessButton.setTitleColor(UIColor.white, for: .normal)
            businessButton.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        }
        
    }
    //Individual
    @IBAction func clickHereToViewButton(_ sender: Any) {
        performSegue(withIdentifier: "ChefBankingToTermsOfServiceSegue", sender: self)
        iAcceptButton.isEnabled = true
    }
    
    @IBAction func iAcceptButtonPressed(_ sender: Any) {
        if termsOfServiceAccept == "" {
            iAcceptCircle.image = UIImage(systemName: "circle.fill")
            termsOfServiceAccept = "Yes"
        } else {
            iAcceptCircle.image = UIImage(systemName: "circle")
            termsOfServiceAccept = ""
        }
        
    }
    
    
    @IBAction func editAccountButton(_ sender: Any) {
        
        print("data \(externalAccountInfo)")
        bankingOrPerson = "banking"
        individualOrBanking = "individual"
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
            if self.externalAccountInfo != nil {
                vc.newInfoOrEditedInfo = "edit"
                vc.externalAccount = self.externalAccountInfo
            }
            vc.bankingOrPerson = self.bankingOrPerson
            vc.individualOrBanking = self.individualOrBanking
            vc.representativeOrOwner = self.representativeOrOwner
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representative = ownerTransfer
            vc.representativeId = self.representativeId
            vc.personId = self.personId
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            
            vc.stripeAccountId = self.stripeAccountId
            self.present(vc, animated: true, completion: nil)
        }
       
//        performSegue(withIdentifier: "ChefBankingToAddPersonSegue", sender: self)
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if termsOfServiceAccept != "Yes" {
            self.showToast(message: "Please accept terms of service.", font: .systemFont(ofSize: 12))
        } else if mccCode.text == "" || mccCode.text!.count != 4 {
            self.showToast(message: "Please enter a valid mcc code.", font: .systemFont(ofSize: 12))
        } else if businessUrl.text == "" || !verifyUrl(urlString: businessUrl.text!) {
            self.showToast(message: "Please enter a valid url.", font: .systemFont(ofSize: 12))
        } else if firstName.text == "" || lastName.text == "" {
            self.showToast(message: "Please enter your first and last names", font: .systemFont(ofSize: 12))
        } else if month.text == "" || day.text == "" || year.text == "" {
            self.showToast(message: "Please enter your date of birth", font: .systemFont(ofSize: 12))
        } else if phoneNumber.text == "" || phoneNumber.text!.count != 10 {
            self.showToast(message: "Please enter a valid phone number", font: .systemFont(ofSize: 12))
        } else if email.text == "" || !isValidEmail(email.text!) {
            self.showToast(message: "Please enter valid email", font: .systemFont(ofSize: 12))
        } else if streetAddress.text == "" || city.text == "" || state.text == "" || zipCode.text == "" {
            self.showToast(message: "Please enter valid street address", font: .systemFont(ofSize: 12))
        } else if externalAccountInfo == nil {
            self.showToast(message: "Please add account info", font: .systemFont(ofSize: 12))
        } else if last4ofSSN.text == "" || last4ofSSN.text!.count != 9 {
            self.showToast(message: "Please enter your ssn.", font: .systemFont(ofSize: 12))
        } else {
            if newAccountOrEditedAccount == "new" {
            saveIndividualAccountInfo()
            } else {
                updateIndividualAccount()
            }
        }
        
    }
    
    //Business
    @IBAction func bClickHereToView(_ sender: Any) {
        performSegue(withIdentifier: "ChefBankingToTermsOfServiceSegue", sender: self)
        bIAcceptButton.isEnabled = true
        
        }
    
    @IBAction func bIAcceptButtonPressed(_ sender: Any) {
        if termsOfServiceAccept == "" {
            bIAcceptCircle.image = UIImage(systemName: "circle.fill")
            termsOfServiceAccept = "Yes"
        } else {
            bIAcceptCircle.image = UIImage(systemName: "circle")
            termsOfServiceAccept = ""
        }
    }
    
    @IBAction func bEditAccountButton(_ sender: Any) {
        bankingOrPerson = "banking"
        individualOrBanking = "business"
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
            if self.externalAccountInfo != nil {
                vc.newInfoOrEditedInfo = "edit"
                vc.externalAccount = self.externalAccountInfo
                
            }
            vc.bankingOrPerson = self.bankingOrPerson
            vc.individualOrBanking = self.individualOrBanking
            vc.representativeOrOwner = self.representativeOrOwner
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representative = ownerTransfer
            vc.representativeId = self.representativeId
            vc.personId = self.personId
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.personLabel.text = "Banking"
            vc.stripeAccountId = self.stripeAccountId
            self.present(vc, animated: true, completion: nil)
        }
        
        
        
    }
    
    @IBAction func addRepresentativeButton(_ sender: Any) {
        bankingOrPerson = "person"
        individualOrBanking = "business"
        representativeOrOwner = "representative"
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
            if self.representative != nil {
                vc.representative = self.representative
                vc.representativeId = self.representativeId
                vc.personId = self.personId
                
            }
            vc.bankingOrPerson = self.bankingOrPerson
            vc.individualOrBanking = self.individualOrBanking
            vc.representativeOrOwner = self.representativeOrOwner
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representative = ownerTransfer
            vc.representativeId = self.representativeId
            vc.personId = self.personId
            vc.personLabel.text = "Representative"
            vc.stripeAccountId = self.stripeAccountId
            vc.representativeOrOwner = "representative"
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addOwnerButtonPressed(_ sender: Any) {
        bankingOrPerson = "person"
        individualOrBanking = "business"
        representativeOrOwner = "owner"
        ownerTransfer = Representative(isPersonAnOwner: "Yes", isPersonAnExectutive: "", firstName: "", lastName: "", month: "", day: "", year: "", streetAddress: "", city: "", state: "", zipCode: "", emailAddress: "", phoneNumber: "", last4OfSSN: "", id: "")
        newInfoOrEditedInfo = "new"
        representativeOrOwner = "owner"
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
            vc.bankingOrPerson = self.bankingOrPerson
            vc.individualOrBanking = self.individualOrBanking
            vc.representativeOrOwner = self.representativeOrOwner
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representative = ownerTransfer
            vc.representativeId = self.representativeId
            vc.personId = self.personId
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func editOwner1Pressed(_ sender: UIButton) {
        if owners.count > 0 {
        bankingOrPerson = "person"
        individualOrBanking = "business"
        representativeOrOwner = "owner"
        ownerTransfer = self.owners[0]
        newInfoOrEditedInfo = "edit0"
        representativeOrOwner = "owner"
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
                
                    vc.bankingOrPerson = self.bankingOrPerson
                    vc.individualOrBanking = self.individualOrBanking
                    vc.representativeOrOwner = self.representativeOrOwner
                    vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
                    vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
                    vc.representative = ownerTransfer
                    vc.representativeId = self.representativeId
                    vc.personId = self.personId
                self.present(vc, animated: true, completion: nil)
            }
        
        }
        
    }
    
    @IBAction func editOwner2Pressed(_ sender: Any) {
        bankingOrPerson = "person"
        individualOrBanking = "business"
        representativeOrOwner = "owner"
        ownerTransfer = self.owners[1]
        newInfoOrEditedInfo = "edit1"
        representativeOrOwner = "owner"
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
            vc.bankingOrPerson = self.bankingOrPerson
            vc.individualOrBanking = self.individualOrBanking
            vc.representativeOrOwner = self.representativeOrOwner
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representative = ownerTransfer
            vc.representativeId = self.representativeId
            vc.personId = self.personId
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func editOwner3Pressed(_ sender: Any) {
        bankingOrPerson = "person"
        individualOrBanking = "business"
        representativeOrOwner = "owner"
        ownerTransfer = self.owners[2]
        newInfoOrEditedInfo = "edit2"
        representativeOrOwner = "owner"
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
            vc.bankingOrPerson = self.bankingOrPerson
            vc.individualOrBanking = self.individualOrBanking
            vc.representativeOrOwner = self.representativeOrOwner
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representative = ownerTransfer
            vc.representativeId = self.representativeId
            vc.personId = self.personId
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func editOwner4Pressed(_ sender: Any) {bankingOrPerson = "person"
        individualOrBanking = "business"
        representativeOrOwner = "owner"
        ownerTransfer = self.owners[3]
        newInfoOrEditedInfo = "edit3"
        representativeOrOwner = "owner"
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
            vc.bankingOrPerson = self.bankingOrPerson
            vc.individualOrBanking = self.individualOrBanking
            vc.representativeOrOwner = self.representativeOrOwner
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representative = ownerTransfer
            vc.representativeId = self.representativeId
            vc.personId = self.personId
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func bSaveButtonPressed(_ sender: Any) {
        
        if termsOfServiceAccept != "Yes" {
            self.showToast(message: "Please accept terms of service.", font: .systemFont(ofSize: 12))
        } else if bMCCCode.text == "" || bMCCCode.text!.count != 4 {
            self.showToast(message: "Please enter valid mcc code", font: .systemFont(ofSize: 12))
        } else if bBusinessURL.text == "" || !verifyUrl(urlString: bBusinessURL.text!) {
            self.showToast(message: "Please enter valid business url", font: .systemFont(ofSize: 12))
        } else if companyName.text == "" {
            self.showToast(message: "Please enter company name", font: .systemFont(ofSize: 12))
        } else if bStreetAddress.text == "" || bCity.text == "" || bState.text == "" || bZipCode.text == "" {
            self.showToast(message: "Pleaes enter valid company anddress", font: .systemFont(ofSize: 12))
        } else if externalAccountInfo == nil {
            self.showToast(message: "Please add account info", font: .systemFont(ofSize: 12))
        } else if representative == nil {
            self.showToast(message: "Please add representative to manage this account.", font: .systemFont(ofSize: 12))
        } else if owners.count == 0 {
            self.showToast(message: "Please add atleast 1 owner", font: .systemFont(ofSize: 12))
        } else if companyTaxId.text == "" || companyTaxId.text!.count != 9 {
            self.showToast(message: "Please enter your company ein or your personal ssn", font: .systemFont(ofSize: 12))
        } else {
            if newAccountOrEditedAccount == "new" {
            saveBusinessAccountInfo()
            } else {
                updateBusinessAccount()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChefBankingToAddPersonSegue" {
            let info = segue.destination as! AddPersonViewController
            info.bankingOrPerson = self.bankingOrPerson
            info.individualOrBanking = self.individualOrBanking
            info.representativeOrOwner = self.representativeOrOwner
            info.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            info.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            info.representative = ownerTransfer
            info.representativeId = self.representativeId
            info.personId = self.personId
            
            
            
        }
    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Are you sure you want to continue? This will delete your stripe bank account.", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
           
            self.deleteAccount(stripeAccountId: self.stripeAccountId)
            if self.individualView.isHidden == true {
                
                self.bMCCCode.text = ""
                self.bBusinessURL.text = ""
                self.companyPhone.text = ""
                self.companyName.text = ""
                self.bStreetAddress.text = ""
                self.bCity.text = ""
                self.bState.text = ""
                self.bZipCode.text = ""
                self.companyTaxId.text = ""
                self.bAddAccountText.text = ""
                self.addRepresentativeLabel.text = ""
                self.representative = nil
                self.addOwnerLabel.text = ""
                self.addOwner2Label.text = ""
                self.addOwner3Label.text = ""
                self.addOwner4Label.text = ""
                self.addOwner2Stack.isHidden = true
                self.addOwner3Stack.isHidden = true
                self.addOwner4Stack.isHidden = true
                self.owners.removeAll()
                self.businessSaveConstraint.constant = 41.5
                self.companyTaxId.isEnabled = true
                self.newAccountOrEditedAccount = "new"
                self.externalAccountInfo = nil
                
                self.bIAcceptCircle.image = UIImage(systemName: "circle")
                self.termsOfServiceAccept = ""
            } else {
                
            self.mccCode.text = ""
            self.businessUrl.text = ""
            self.firstName.text = ""
            self.lastName.text = ""
            self.phoneNumber.text = ""
            self.email.text = ""
            self.day.text = ""
            self.month.text = ""
            self.year.text = ""
            self.streetAddress.text = ""
            self.city.text = ""
            self.state.text = ""
            self.zipCode.text = ""
            self.last4ofSSN.text = ""
            self.last4ofSSN.isEnabled = true
            self.addAccountText.text = ""
            self.externalAccountInfo = nil
            self.newAccountOrEditedAccount = "new"
                
            self.termsOfServiceAccept = ""
                self.iAcceptCircle.image = UIImage(systemName: "circle")
            }
            }))
        
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
           
                alert.dismiss(animated: true, completion: nil)
            }))
        present(alert, animated: true, completion: nil)
        
        
        
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
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func getWiFiAddress() -> String? {
        var address : String?

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
}
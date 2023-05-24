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
    @IBOutlet weak var externalAccountLabel: UILabel!
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
    @IBOutlet weak var companyPhone: UITextField!
    @IBOutlet weak var externalAccountBusiness: UILabel!
    @IBOutlet weak var representativeLabel: UILabel!
    @IBOutlet weak var companyTaxId: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var bankingOrPerson = "person"
    private var individualOrBanking = "business"
    private var representativeOrOwner = ""
    var newInfoOrEditedInfo = "new"
    var newAccountOrEditedAccount = "new"
    
    private var termsOfServiceAccept = ""
    
    var externalAccountInfo : ExternalAccount?
    var representative : Representative?
    var owners : [Representative] = []
    
    var individualBankingInfo : IndividualBankingInfo?
    var businessBankingInfo: BusinessBankingInfo?
    var external = ""
    
    
    
    private var stripeAccountId = ""
    private var externalAccountId = ""
    private var representativeId = ""
    private var personId = ""
    
    @IBOutlet weak var bSaveButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    var ownerTransfer : Representative?
    var isPersonAnOwner = ""
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    
        
        if newAccountOrEditedAccount == "new" {
            if external == "Individual" {
                individualView.isHidden = false
                businessView.isHidden = true
                
                self.individualButton.setTitleColor(UIColor.white, for: .normal)
                self.individualButton.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                self.businessButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                self.businessButton.backgroundColor = UIColor.white
                if individualBankingInfo!.termsOfServiceAcceptance == "Yes" {
                    iAcceptButton.isEnabled = true
                    iAcceptCircle.image = UIImage(systemName: "circle.fill")
                }
                mccCode.text = individualBankingInfo!.mccCode
                businessUrl.text = individualBankingInfo!.businessUrl
                firstName.text = individualBankingInfo!.firstName
                lastName.text = individualBankingInfo!.lastName
                month.text = individualBankingInfo!.month
                day.text = individualBankingInfo!.day
                year.text = individualBankingInfo!.year
                phoneNumber.text = individualBankingInfo!.phoneNumber
                email.text = individualBankingInfo!.email
                streetAddress.text = individualBankingInfo!.streetAddress
                city.text = individualBankingInfo!.city
                state.text = individualBankingInfo!.state
                zipCode.text = individualBankingInfo!.zipCode
                if individualBankingInfo!.externalAccount != nil {
                    externalAccountLabel.text = "\(individualBankingInfo!.externalAccount!.accountNumber)"
                }
                
                last4ofSSN.text = individualBankingInfo!.last4ofSSN
            } else if external == "Business" {
                individualView.isHidden = true
                businessView.isHidden = false
                
                self.businessButton.setTitleColor(UIColor.white, for: .normal)
                self.businessButton.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                self.individualButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                self.individualButton.backgroundColor = UIColor.white
                if businessBankingInfo!.termsOfServiceAcceptance == "Yes" {
                    bIAcceptButton.isEnabled = true
                    bIAcceptCircle.image = UIImage(systemName: "circle.fill")
                }
                
                bMCCCode.text = businessBankingInfo!.mccCode
                bBusinessURL.text = businessBankingInfo!.businessUrl
                companyName.text = businessBankingInfo!.companyName
                
                bStreetAddress.text = businessBankingInfo!.streetAddress
                bCity.text = businessBankingInfo!.city
                bState.text = businessBankingInfo!.state
                bZipCode.text = businessBankingInfo!.zipCode
                companyPhone.text = businessBankingInfo!.companyPhone
                if businessBankingInfo!.externalAccount != nil {
                    externalAccountBusiness.text = "\(businessBankingInfo!.externalAccount!.accountNumber)"
                }
                if businessBankingInfo!.representative != nil {
                    representativeLabel.text = "\(businessBankingInfo!.representative!.firstName) \(businessBankingInfo!.representative!.lastName)"
                }
                companyTaxId.text = businessBankingInfo!.companyTaxId
            }
            bSaveButton.setTitle("Continue", for: .normal)
            saveButton.setTitle("Continue", for: .normal)
        } else {
            if external == "" {
                loadBankingInfo()
            }
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
                            self.loadIndividualBankingInfo(stripeAccountId: stripeAccountId, externalAccountId: externalAccountId, individualOrBusiness: "Individual")
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
                                self.loadBusinessBankingInfo(stripeAccountId: stripeAccountId, externalAccountId: externalAccountId, representativeId: representativeId, documentId: doc.documentID)
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
    
    private func loadIndividualBankingInfo(stripeAccountId: String, externalAccountId: String, individualOrBusiness: String) {
        
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
                self.individualBankingInfo = IndividualBankingInfo(stripeAccountId: stripeAccountId, termsOfServiceAcceptance: "Yes", mccCode: mcc, businessUrl: url, firstName: firstName, lastName: lastName, month: "\(dobMonth)", day: "\(dobDay)", year: "\(dobYear)", phoneNumber: "\(phone)", email: email, streetAddress: line1, city: city, state: state, zipCode: "\(postalCode)", last4ofSSN: "*********", externalAccount: ExternalAccount(bankName: "", accountHolder: "", accountNumber: "", routingNumber: "", id: ""))
                print("individual load happening")
                
                self.loadExternalAccount(stripeAccountId: stripeAccountId, externalAccountId: externalAccountId, individualOrBusiness: individualOrBusiness)
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
    
    private func loadBusinessBankingInfo(stripeAccountId: String, externalAccountId: String, representativeId: String, documentId: String) {
        
            
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
                    var externalAccount = ExternalAccount(bankName: "", accountHolder: "", accountNumber: "", routingNumber: "", id: "")
                    var representative = Representative(isPersonAnOwner: "", isPersonAnExectutive: "", firstName: "", lastName: "", month: "", day: "", year: "", streetAddress: "", city: "", state: "", zipCode: "", emailAddress: "", phoneNumber: "", last4OfSSN: "", id: "")
                    
                    self.businessBankingInfo = BusinessBankingInfo(stripeAccountId: stripeAccountId, termsOfServiceAcceptance: "Yes", mccCode: mcc, businessUrl: url, companyName: companyName, companyPhone: "\(companyPhone)", streetAddress: companyLine1, city: city, state: state, zipCode: "\(postalCode)", companyTaxId: "*********", externalAccount: externalAccount, representative: representative, owner1: representative, owner2: representative, owner3: representative, owner4: representative, bankingInfoDocumentId: documentId)
                    
                    self.loadExternalAccount(stripeAccountId: stripeAccountId, externalAccountId: externalAccountId, individualOrBusiness: "Business")
                    self.loadPerson(stripeAccountId: stripeAccountId, personId: representativeId, representative: "yes")
                    
                    for i in 0..<persons.count {
                        if "\(persons[i]["id"]!)" != representativeId {
                            self.loadPerson(stripeAccountId: stripeAccountId, personId: "\(persons[i]["id"]!)", representative: "no")
                        }
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
                        let rep = Representative(isPersonAnOwner: "\(owner)", isPersonAnExectutive: "\(executive)", firstName: firstName, lastName: lastName, month: "\(month)", day: "\(day)", year: "\(year)", streetAddress: streetAddress, city: city, state: state, zipCode: "\(zipCode)", emailAddress: email, phoneNumber: "\(phoneNumber)", last4OfSSN: "*********", id: personId)
                        if representative == "yes" {
                            self.businessBankingInfo?.representative = rep
                            
                            self.representativeLabel.text = "\(firstName) \(lastName)"
                            
                            if "\(owner)" == "1" {
                                if self.businessBankingInfo?.owner1!.firstName == "" {
                                    self.businessBankingInfo?.owner1 = rep
                                } else if self.businessBankingInfo?.owner2!.firstName == "" {
                                    self.businessBankingInfo?.owner2 = rep
                                } else if self.businessBankingInfo?.owner3!.firstName == "" {
                                    self.businessBankingInfo?.owner3 = rep
                                } else if self.businessBankingInfo?.owner4!.firstName == "" {
                                    self.businessBankingInfo?.owner4 = rep
                                }
                            }
                            
                        } else {
                            if let index = self.owners.firstIndex(where: { "\($0.firstName) \($0.lastName) \($0.emailAddress)" == "\(firstName) \(lastName) \(email)" }) {} else {
                                if self.businessBankingInfo?.owner1!.firstName == "" {
                                    self.businessBankingInfo?.owner1 = rep
                                } else if self.businessBankingInfo?.owner2!.firstName == "" {
                                    self.businessBankingInfo?.owner2 = rep
                                } else if self.businessBankingInfo?.owner3!.firstName == "" {
                                    self.businessBankingInfo?.owner3 = rep
                                } else if self.businessBankingInfo?.owner4!.firstName == "" {
                                    self.businessBankingInfo?.owner4 = rep
                                }
                            }
                        }
                    }
                })
                task.resume()
    }
    
    private func loadExternalAccount(stripeAccountId: String, externalAccountId: String, individualOrBusiness: String) {
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
                var externalAccount = ExternalAccount(bankName: bankName, accountHolder: accountHolder, accountNumber: "\(accountNumber)", routingNumber: "\(routingNumber)", id: externalAccountId)
                if individualOrBusiness == "Individual" {
                    self.individualBankingInfo?.externalAccount = externalAccount
                    self.externalAccountLabel.text = "****\("\(accountNumber)".suffix(4))"
                } else {
                    self.businessBankingInfo?.externalAccount = externalAccount
                    self.externalAccountBusiness.text = "****\("\(accountNumber)".suffix(4))"
                }
                
                }
        })
        task.resume()
    }
    
    
    private func saveIndividualAccountInfo() {
        activityIndicator.isHidden = false
        
        activityIndicator.startAnimating()
        let json: [String: Any] = ["mcc": "\(individualBankingInfo!.mccCode)", "ip" : "\(getWiFiAddress()!)", "url" :"\(individualBankingInfo!.businessUrl)", "date": "\(Int(Date().timeIntervalSince1970))", "first_name" : "\(individualBankingInfo!.firstName)", "last_name" : "\(individualBankingInfo!.lastName)", "dob_day" : "\(individualBankingInfo!.day)", "dob_month" : "\(individualBankingInfo!.month)", "dob_year" : "\(individualBankingInfo!.year)", "line_1" : "\(individualBankingInfo!.streetAddress)", "line_2" : "", "postal_code" : "\(individualBankingInfo!.zipCode)", "city" : "\(individualBankingInfo!.city)", "state" : "\(individualBankingInfo!.state)", "email" : "\(individualBankingInfo!.email)", "phone" : "\(individualBankingInfo!.phoneNumber)", "ssn" : "\(individualBankingInfo!.last4ofSSN)", "account_holder" : "\(individualBankingInfo!.externalAccount!.accountHolder)", "routing_number" : "\(individualBankingInfo!.externalAccount!.routingNumber)", "account_number" : "\(individualBankingInfo!.externalAccount!.accountNumber)"]
        
    
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
        var owners : [Representative] = []
        if businessBankingInfo?.owner1 != nil {
            owners.append(businessBankingInfo!.owner1!)
        }
        if businessBankingInfo?.owner2 != nil {
            owners.append(businessBankingInfo!.owner2!)
        }
        if businessBankingInfo?.owner3 != nil {
            owners.append(businessBankingInfo!.owner3!)
        }
        if businessBankingInfo?.owner4 != nil {
            owners.append(businessBankingInfo!.owner4!)
        }
        
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        var vari = false
        if  businessBankingInfo!.representative!.isPersonAnOwner == "Yes" {
            vari = true
        }
        var i = 0
        
        let json: [String: Any] = ["mcc": "\(bMCCCode.text!)", "ip" : "\(getWiFiAddress()!)", "business_url" :"\(bBusinessURL.text!)", "date": "\(Int(Date().timeIntervalSince1970))", "company_name" : "\(companyName.text!)", "company_city" : "\(bCity.text!)", "company_line1" : "\(bStreetAddress.text!)", "company_line2" : "", "company_postal_code" : "\(bZipCode.text!)", "company_state" : "\(bState.text!)", "company_phone" : "\(companyPhone.text!)", "company_tax_id" : "\(companyTaxId.text!)", "account_holder" : "\(businessBankingInfo!.externalAccount!.accountHolder)", "routing_number" : "\(businessBankingInfo!.externalAccount!.routingNumber)", "account_number" : "\(businessBankingInfo!.externalAccount!.accountNumber)", "representative_first_name" : "\(businessBankingInfo!.representative!.firstName)", "representative_last_name" : "\(businessBankingInfo!.representative!.lastName)", "representative_dob_day" : "\(businessBankingInfo!.representative!.day)", "representative_dob_month" : "\(businessBankingInfo!.representative!.month)", "representative_dob_year" : "\(businessBankingInfo!.representative!.year)", "representative_line_1" : "\(businessBankingInfo!.representative!.streetAddress)", "representative_line_2" : "", "representative_postal_code" : "\(businessBankingInfo!.representative!.zipCode)", "representative_city" : "\(businessBankingInfo!.representative!.city)", "representative_state" : "\(businessBankingInfo!.representative!.state)", "representative_email" : "\(businessBankingInfo!.representative!.emailAddress)", "representative_phone": "\(businessBankingInfo!.representative!.phoneNumber)", "representative_id_number" : "\(businessBankingInfo!.representative!.last4OfSSN)", "representative_title" : "Executive", "representative" : true, "representative_owner" : vari, "representative_executive" : true]
        
    
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
               
                    
                        print("name 1 \(self.businessBankingInfo!.representative!.firstName) \(self.businessBankingInfo!.representative!.lastName) \(self.businessBankingInfo!.representative!.emailAddress)")
                        
                        print("name 2 \(owners[i].firstName) \(owners[i].lastName) \(owners[i].emailAddress)")
                        print("count \(owners.count)")
                    for i in 0..<owners.count {
                        print("happening owners for loop")
                        var end = ""
                        if i == owners.count - 1 { end = "end" }
                        if "\(self.businessBankingInfo!.representative!.firstName) \(self.businessBankingInfo!.representative!.lastName) \(self.businessBankingInfo!.representative!.emailAddress)" != "\(owners[i].firstName) \(owners[i].lastName) \(owners[i].emailAddress)" {
                            self.createPerson(stripeAccountId: id, owner: owners[i], end: end)
                            print("create person happening")
                        } else {
                            if end == "end" {
                                print("end happening")
                            self.performSegue(withIdentifier: "ChefBankingToHomeSegue", sender: self)
                            }
                        }
                    }
                    
                    
                
                }
        })
        task.resume()
        
    }
    
    
    private func createPerson(stripeAccountId: String, owner: Representative, end: String) {
       
        
            let json : [String:Any] = ["account_id" : "\(stripeAccountId)", "first_name" : "\(owner.firstName)", "last_name" : "\(owner.lastName)", "dob_day" : "\(owner.day)", "dob_month" : "\(owner.month)", "dob_year" : "\(owner.year)", "line_1" : "\(owner.streetAddress)", "line_2" : "", "postal_code" : "\(owner.zipCode)", "city" : "\(owner.city)", "state" : "\(owner.state)", "email" : "\(owner.emailAddress)", "phone" : "\(owner.phoneNumber)", "id_number" : "\(owner.last4OfSSN)" , "title" : "Owner", "representative" : false, "owner" : true, "executive" : false]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/create-person")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let data = data,
                      
                    
                      
                    let self = self else {
                // Handle error
                return
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    if end == "end" {
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
                    self.representativeLabel.text = ""
                    self.representative = nil
                    self.externalAccountBusiness.text = ""
                    self.owners.removeAll()
                    self.companyTaxId.isEnabled = true
                    self.newAccountOrEditedAccount = "new"
                    
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
                self.externalAccountLabel.text = ""
            self.zipCode.text = ""
            self.last4ofSSN.text = ""
            self.last4ofSSN.isEnabled = true
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
    
    
    
    @IBAction func externalAccountButtonPressed(_ sender: Any) {
        if newAccountOrEditedAccount == "new" {
            
            var termsOfServiceAcceptance = ""
            if iAcceptCircle.image == UIImage(systemName: "circle") { termsOfServiceAcceptance = "Yes" } else { termsOfServiceAcceptance = "No" }
            
            individualBankingInfo = IndividualBankingInfo(stripeAccountId: "", termsOfServiceAcceptance: termsOfServiceAcceptance, mccCode: mccCode.text!, businessUrl: businessUrl.text!, firstName: firstName.text!, lastName: lastName.text!, month: month.text!, day: day.text!, year: year.text!, phoneNumber: phoneNumber.text!, email: email.text!, streetAddress: streetAddress.text!, city: city.text!, state: state.text!, zipCode: zipCode.text!, last4ofSSN: last4ofSSN.text!, externalAccount: individualBankingInfo?.externalAccount)
            
        }
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ExternalAccount") as? ExternalAccountViewController  {
           
            vc.individualOrBusiness = "Individual"
            vc.individualBankingInfo = individualBankingInfo!
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.externalAccount = self.externalAccountInfo
            vc.stripeAccountId = self.stripeAccountId
            vc.externalAccountId = self.externalAccountId
            self.present(vc, animated: true, completion: nil)
        }
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
        } else if individualBankingInfo?.externalAccount == nil {
            self.showToast(message: "Please add account info", font: .systemFont(ofSize: 12))
        } else if last4ofSSN.text == "" || last4ofSSN.text!.count != 9 {
            self.showToast(message: "Please enter your ssn.", font: .systemFont(ofSize: 12))
        } else {
            if newAccountOrEditedAccount == "new" {
//            saveIndividualAccountInfo()
                print("individual banking info \(individualBankingInfo)")
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
            businessBankingInfo?.termsOfServiceAcceptance = "Yes"
        } else {
            bIAcceptCircle.image = UIImage(systemName: "circle")
            termsOfServiceAccept = ""
            businessBankingInfo?.termsOfServiceAcceptance = ""
        }
    }
    
    
    
    @IBAction func externalAccountButtonBusinessPresseed(_ sender: Any) {
        if newAccountOrEditedAccount == "new" {
            var termsOfServiceAcceptance = ""
            if bIAcceptCircle.image == UIImage(systemName: "circle.fill") { termsOfServiceAcceptance = "Yes" } else { termsOfServiceAcceptance = "No" }
            
            businessBankingInfo = BusinessBankingInfo(stripeAccountId: "", termsOfServiceAcceptance: termsOfServiceAcceptance, mccCode: bMCCCode.text!, businessUrl: bBusinessURL.text!, companyName: companyName.text!, companyPhone: companyPhone.text!, streetAddress: bStreetAddress.text!, city: bCity.text!, state: bState.text!, zipCode: bZipCode.text!, companyTaxId: companyTaxId.text!, externalAccount: businessBankingInfo?.externalAccount, bankingInfoDocumentId: "")
            
        }
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ExternalAccount") as? ExternalAccountViewController  {
           
            vc.individualOrBusiness = "Business"
            vc.businessBankingInfo = businessBankingInfo!
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.externalAccount = self.externalAccountInfo
            vc.stripeAccountId = self.stripeAccountId
            vc.externalAccountId = self.externalAccountId
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func representativeButtonPressed(_ sender: Any) {
        var termsOfServiceAcceptance = ""
        if bIAcceptCircle.image == UIImage(systemName: "circle.fill") { termsOfServiceAcceptance = "Yes" } else { termsOfServiceAcceptance = "No" }
        
        var rep = Representative(isPersonAnOwner: "", isPersonAnExectutive: "", firstName: "", lastName: "", month: "", day: "", year: "", streetAddress: "", city: "", state: "", zipCode: "", emailAddress: "", phoneNumber: "", last4OfSSN: "", id: "")
        
//        if newAccountOrEditedAccount == "new" && businessBankingInfo?.representative == nil {
//            
//            businessBankingInfo = BusinessBankingInfo(stripeAccountId: "", termsOfServiceAcceptance: termsOfServiceAcceptance, mccCode: bMCCCode.text!, businessUrl: bBusinessURL.text!, companyName: companyName.text!, companyPhone: companyPhone.text!, streetAddress: bStreetAddress.text!, city: bCity.text!, state: bState.text!, zipCode: bZipCode.text!, companyTaxId: companyTaxId.text!, externalAccount: businessBankingInfo?.externalAccount, representative: rep, bankingInfoDocumentId: "")
//        } else {
//            
//            businessBankingInfo = BusinessBankingInfo(stripeAccountId: "", termsOfServiceAcceptance: termsOfServiceAcceptance, mccCode: bMCCCode.text!, businessUrl: bBusinessURL.text!, companyName: companyName.text!, companyPhone: companyPhone.text!, streetAddress: bStreetAddress.text!, city: bCity.text!, state: bState.text!, zipCode: bZipCode.text!, companyTaxId: companyTaxId.text!, externalAccount: businessBankingInfo?.externalAccount, representative: businessBankingInfo?.representative, bankingInfoDocumentId: "")
//        }
        
        businessBankingInfo = BusinessBankingInfo(stripeAccountId: "", termsOfServiceAcceptance: termsOfServiceAcceptance, mccCode: bMCCCode.text!, businessUrl: bBusinessURL.text!, companyName: companyName.text!, companyPhone: companyPhone.text!, streetAddress: bStreetAddress.text!, city: bCity.text!, state: bState.text!, zipCode: bZipCode.text!, companyTaxId: companyTaxId.text!, externalAccount: businessBankingInfo?.externalAccount, representative: businessBankingInfo?.representative, owner1: businessBankingInfo?.owner1, owner2: businessBankingInfo?.owner2, owner3: businessBankingInfo?.owner3, owner4: businessBankingInfo?.owner4, bankingInfoDocumentId: "")
        
        
        if newAccountOrEditedAccount == "new" && businessBankingInfo?.externalAccount == nil {
        var ext = ExternalAccount(bankName: "", accountHolder: "", accountNumber: "", routingNumber: "", id: "")
           
        }
        
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPerson") as? AddPersonViewController  {
            if self.representative != nil {
                vc.representative = self.representative
                vc.representativeId = self.representativeId
                vc.personId = self.personId
                
            }
            vc.businessBankingInfo = businessBankingInfo!
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representativeId = self.representativeId
            vc.personId = self.personId
            vc.stripeAccountId = self.stripeAccountId
            vc.representativeOrOwner = "representative"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func ownersButtonPressed(_ sender: Any) {
        var termsOfServiceAcceptance = ""
        if bIAcceptCircle.image == UIImage(systemName: "circle.fill") { termsOfServiceAcceptance = "Yes" } else { termsOfServiceAcceptance = "No" }
        
        
            
        businessBankingInfo = BusinessBankingInfo(stripeAccountId: "", termsOfServiceAcceptance: termsOfServiceAcceptance, mccCode: bMCCCode.text!, businessUrl: bBusinessURL.text!, companyName: companyName.text!, companyPhone: companyPhone.text!, streetAddress: bStreetAddress.text!, city: bCity.text!, state: bState.text!, zipCode: bZipCode.text!, companyTaxId: companyTaxId.text!, externalAccount: businessBankingInfo?.externalAccount, representative: businessBankingInfo?.representative, owner1: businessBankingInfo?.owner1, owner2: businessBankingInfo?.owner2, owner3: businessBankingInfo?.owner3, owner4: businessBankingInfo?.owner4, bankingInfoDocumentId: "")
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Owners") as? OwnersViewController  {
           
            vc.businessBankingInfo = self.businessBankingInfo
            vc.newInfoOrEditedInfo = self.newInfoOrEditedInfo
            vc.newAccountOrEditedAccount = self.newAccountOrEditedAccount
            vc.representativeId = self.representativeId
            vc.personId = self.personId
            vc.stripeAccountId = self.stripeAccountId
            vc.representativeOrOwner = "owner"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func bSaveButtonPressed(_ sender: Any) {
        var owners : [Representative] = []
        if businessBankingInfo?.owner1 != nil {
            owners.append(businessBankingInfo!.owner1!)
        }
        if businessBankingInfo?.owner2 != nil {
            owners.append(businessBankingInfo!.owner2!)
        }
        if businessBankingInfo?.owner3 != nil {
            owners.append(businessBankingInfo!.owner3!)
        }
        if businessBankingInfo?.owner4 != nil {
            owners.append(businessBankingInfo!.owner4!)
        }
        
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
        } else if businessBankingInfo?.representative == nil {
            self.showToast(message: "Please add representative to manage this account.", font: .systemFont(ofSize: 12))
        } else if businessBankingInfo?.externalAccount == nil {
            self.showToast(message: "Please add account info.", font: .systemFont(ofSize: 12))
        } else if companyTaxId.text == "" || companyTaxId.text!.count != 9 {
            self.showToast(message: "Please enter your company ein or your personal ssn", font: .systemFont(ofSize: 12))
        } else if owners.count < 1 {
            self.showToast(message: "Please add atleast 1 owner.", font: .systemFont(ofSize: 12))
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

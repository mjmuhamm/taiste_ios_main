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
    var representativeOrOwner = ""
    
    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var disclaimerLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var personView: UIView!
    
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
    
    @IBOutlet weak var personSaveButton: UIButton!
    
    
    var representative : Representative?
    private var isPersonAnOwner = "Yes"
    private var isPersonAnExectutive = "Yes"
    
    var stripeAccountId = ""
    var personId = ""
    var representativeId = ""
    
    var businessBankingInfo : BusinessBankingInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("new info or edited info \(newInfoOrEditedInfo)")
        
        if newAccountOrEditedAccount == "edit" {
//            bankingSaveButton.isEnabled = false
            personSaveButton.isEnabled = false
        } else {
            personSaveButton.isEnabled = true
        }
        if representativeOrOwner.prefix(5) != "owner" {
            deleteButton.isHidden = true
        } else {
            deleteButton.isHidden = false
        }
//        if newInfoOrEditedInfo.prefix(4) == "edit" && representativeOrOwner == "owner"  {
//            deleteButton.isHidden = false
//        } else {
//            deleteButton.isHidden = true
//        }
        
        
        if representativeOrOwner == "representative" {
            disclaimerLabel.text = "The representative will be the manager of this account and must be an owner or executive of the business."
            personLabel.text = "Representative"
        } else if representativeOrOwner == "owner" {
            disclaimerLabel.text = "All owners with more than 25% ownership must be reported."
            personLabel.text = "Owner"
        }
        if representativeOrOwner == "representative" {
            if businessBankingInfo!.representative!.isPersonAnOwner == "1" {
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
            if businessBankingInfo!.representative!.isPersonAnExectutive == "1" {
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
            firstName.text = businessBankingInfo!.representative!.firstName
            lastName.text = businessBankingInfo!.representative!.lastName
            month.text = businessBankingInfo!.representative!.month
            day.text = businessBankingInfo!.representative!.day
            year.text = businessBankingInfo!.representative!.year
            streetAddress.text = businessBankingInfo!.representative!.streetAddress
            city.text = businessBankingInfo!.representative!.city
            state.text = businessBankingInfo!.representative!.state
            zipCode.text = businessBankingInfo!.representative!.zipCode
            emailAddress.text = businessBankingInfo!.representative!.emailAddress
            phoneNumber.text = businessBankingInfo!.representative!.phoneNumber
            last4OfSSN.text = businessBankingInfo!.representative!.last4OfSSN
        } else {
            if representativeOrOwner == "owner1" {
                if businessBankingInfo?.owner1 != nil {
                    firstName.text = businessBankingInfo!.owner1!.firstName
                    lastName.text = businessBankingInfo!.owner1!.lastName
                    month.text = businessBankingInfo!.owner1!.month
                    day.text = businessBankingInfo!.owner1!.day
                    year.text = businessBankingInfo!.owner1!.year
                    streetAddress.text = businessBankingInfo!.owner1!.streetAddress
                    city.text = businessBankingInfo!.owner1!.city
                    state.text = businessBankingInfo!.owner1!.state
                    zipCode.text = businessBankingInfo!.owner1!.zipCode
                    emailAddress.text = businessBankingInfo!.owner1!.emailAddress
                    phoneNumber.text = businessBankingInfo!.owner1!.phoneNumber
                    last4OfSSN.text = businessBankingInfo!.owner1!.last4OfSSN
                }
                if businessBankingInfo!.owner1!.isPersonAnOwner == "1" {
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
                if businessBankingInfo!.owner1!.isPersonAnExectutive == "1" {
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
            } else if representativeOrOwner == "owner2" {
                if businessBankingInfo?.owner2 != nil {
                    if businessBankingInfo!.owner2!.isPersonAnOwner == "1" {
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
                    if businessBankingInfo!.owner2!.isPersonAnExectutive == "1" {
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
                    firstName.text = businessBankingInfo!.owner2!.firstName
                    lastName.text = businessBankingInfo!.owner2!.lastName
                    month.text = businessBankingInfo!.owner2!.month
                    day.text = businessBankingInfo!.owner2!.day
                    year.text = businessBankingInfo!.owner2!.year
                    streetAddress.text = businessBankingInfo!.owner2!.streetAddress
                    city.text = businessBankingInfo!.owner2!.city
                    state.text = businessBankingInfo!.owner2!.state
                    zipCode.text = businessBankingInfo!.owner2!.zipCode
                    emailAddress.text = businessBankingInfo!.owner2!.emailAddress
                    phoneNumber.text = businessBankingInfo!.owner2!.phoneNumber
                    last4OfSSN.text = businessBankingInfo!.owner2!.last4OfSSN
                }
            } else if representativeOrOwner == "owner3" {
                if businessBankingInfo?.owner3 != nil {
                    if businessBankingInfo!.owner3!.isPersonAnOwner == "1" {
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
                    if businessBankingInfo!.owner3!.isPersonAnExectutive == "1" {
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
                    firstName.text = businessBankingInfo!.owner3!.firstName
                    lastName.text = businessBankingInfo!.owner3!.lastName
                    month.text = businessBankingInfo!.owner3!.month
                    day.text = businessBankingInfo!.owner3!.day
                    year.text = businessBankingInfo!.owner3!.year
                    streetAddress.text = businessBankingInfo!.owner3!.streetAddress
                    city.text = businessBankingInfo!.owner3!.city
                    state.text = businessBankingInfo!.owner3!.state
                    zipCode.text = businessBankingInfo!.owner3!.zipCode
                    emailAddress.text = businessBankingInfo!.owner3!.emailAddress
                    phoneNumber.text = businessBankingInfo!.owner3!.phoneNumber
                    last4OfSSN.text = businessBankingInfo!.owner3!.last4OfSSN
                }
            } else if representativeOrOwner == "owner4" {
                if businessBankingInfo?.owner4 != nil {
                    if businessBankingInfo!.owner4!.isPersonAnOwner == "1" {
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
                    if businessBankingInfo!.owner4!.isPersonAnExectutive == "1" {
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
                    firstName.text = businessBankingInfo!.owner4!.firstName
                    lastName.text = businessBankingInfo!.owner4!.lastName
                    month.text = businessBankingInfo!.owner4!.month
                    day.text = businessBankingInfo!.owner4!.day
                    year.text = businessBankingInfo!.owner4!.year
                    streetAddress.text = businessBankingInfo!.owner4!.streetAddress
                    city.text = businessBankingInfo!.owner4!.city
                    state.text = businessBankingInfo!.owner4!.state
                    zipCode.text = businessBankingInfo!.owner4!.zipCode
                    emailAddress.text = businessBankingInfo!.owner4!.emailAddress
                    phoneNumber.text = businessBankingInfo!.owner4!.phoneNumber
                    last4OfSSN.text = businessBankingInfo!.owner4!.last4OfSSN
                    
                }
            }
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    
    
    
        
    private func createPerson(representativeOrOwner: String) {
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
                    if representativeOrOwner == "representative" {
                        let data : [String: Any] = ["representativeId" : id]
                        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BankingInfo").document(self.businessBankingInfo!.bankingInfoDocumentId).updateData(data)
                        
                        var rep = Representative(isPersonAnOwner: self.isPersonAnOwner, isPersonAnExectutive: self.isPersonAnExectutive, firstName: self.firstName.text!, lastName: self.lastName.text!, month: self.month.text!, day: self.day.text!, year: self.year.text!, streetAddress: self.streetAddress.text!, city: self.city.text!, state: self.state.text!, zipCode: self.zipCode.text!, emailAddress: self.emailAddress.text!, phoneNumber: self.phoneNumber.text!, last4OfSSN: self.last4OfSSN.text!, id: id)
                        self.businessBankingInfo!.representative! = rep
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController  {
                            
                            vc.businessBankingInfo = self.businessBankingInfo!
                            vc.external = "Business"
                            
                            self.present(vc, animated: true)
                        }
                    } else {
                        
                        var owner = Representative(isPersonAnOwner: self.isPersonAnOwner, isPersonAnExectutive: self.isPersonAnExectutive, firstName: self.firstName.text!, lastName: self.lastName.text!, month: self.month.text!, day: self.day.text!, year: self.year.text!, streetAddress: self.streetAddress.text!, city: self.city.text!, state: self.state.text!, zipCode: self.zipCode.text!, emailAddress: self.emailAddress.text!, phoneNumber: self.phoneNumber.text!, last4OfSSN: self.last4OfSSN.text!, id: id)
                        
                        if representativeOrOwner == "owner1" {
                            self.businessBankingInfo!.owner1 = owner
                        } else if representativeOrOwner == "owner2" {
                            self.businessBankingInfo!.owner2 = owner
                        } else if representativeOrOwner == "owner3" {
                            self.businessBankingInfo!.owner3 = owner
                        } else if representativeOrOwner == "owner4" {
                            self.businessBankingInfo!.owner4 = owner
                        }
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Owners") as? OwnersViewController  {
                            
                            vc.businessBankingInfo = self.businessBankingInfo!
                            self.present(vc, animated: true)
                        }
                    }
                    }
            })
            task.resume()
    
        
    }
    
    private func deletePerson(stripeId: String, personId: String, representativeOrOwner: String) {
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
                if representativeOrOwner == "representative" {
                    let data : [String: Any] = ["representativeId" : ""]
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BankingInfo").document(self.businessBankingInfo!.bankingInfoDocumentId).updateData(data)
                }
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
        } else if isPersonAnExectutive != "Yes" && representativeOrOwner == "representative" {
            self.showToast(message: "The representative must be an executive of the company.", font: .systemFont(ofSize: 12))
        } else if isPersonAnOwner != "Yes" && representativeOrOwner == "owner" {
            self.showToast(message: "You must click 'yes' that the owner is in fact an owner.", font: .systemFont(ofSize: 12))
        } else {
            
            if representativeOrOwner == "representative" {
                
                if newAccountOrEditedAccount == "edit" {
                    let alert = UIAlertController(title: "Are you sure you want to continue? This will delete this representative and create a new person with this information.", message: nil, preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
                        
                        self.deletePerson(stripeId: self.businessBankingInfo!.stripeAccountId, personId: self.businessBankingInfo!.representative!.id, representativeOrOwner: "representative")
                        self.createPerson(representativeOrOwner: "representative")
                        
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
                        
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    var rep = Representative(isPersonAnOwner: self.isPersonAnOwner, isPersonAnExectutive: self.isPersonAnExectutive, firstName: self.firstName.text!, lastName: self.lastName.text!, month: self.month.text!, day: self.day.text!, year: self.year.text!, streetAddress: self.streetAddress.text!, city: self.city.text!, state: self.state.text!, zipCode: self.zipCode.text!, emailAddress: self.emailAddress.text!, phoneNumber: self.phoneNumber.text!, last4OfSSN: self.last4OfSSN.text!, id: "")
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController  {
                        self.businessBankingInfo!.representative = rep
                        vc.newAccountOrEditedAccount = "new"
                        vc.businessBankingInfo = self.businessBankingInfo!
                        vc.external = "Business"
                        self.present(vc, animated: true)
                    }
                }} else {
                    var rep = Representative(isPersonAnOwner: self.isPersonAnOwner, isPersonAnExectutive: self.isPersonAnExectutive, firstName: self.firstName.text!, lastName: self.lastName.text!, month: self.month.text!, day: self.day.text!, year: self.year.text!, streetAddress: self.streetAddress.text!, city: self.city.text!, state: self.state.text!, zipCode: self.zipCode.text!, emailAddress: self.emailAddress.text!, phoneNumber: self.phoneNumber.text!, last4OfSSN: self.last4OfSSN.text!, id: "")
                    
                    
                    if newAccountOrEditedAccount == "edit" {
                        var message = "Are you sure you want to continue? This will delete this owner and create a new person with this information."
                        if self.representativeOrOwner == "owner1" && self.businessBankingInfo?.owner1 == nil || self.representativeOrOwner == "owner2" && self.businessBankingInfo?.owner2 == nil || self.representativeOrOwner == "owner3" && self.businessBankingInfo?.owner3 == nil || self.representativeOrOwner == "owner4" && self.businessBankingInfo?.owner4 == nil {
                            message = "Are you sure you want to continue?"
                        }
                        let alert = UIAlertController(title: message, message: nil, preferredStyle: .actionSheet)
                        
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
                            if self.representativeOrOwner == "owner1" {
                                self.businessBankingInfo?.owner1 = rep
                            } else if self.representativeOrOwner == "owner2" {
                                self.businessBankingInfo?.owner2 = rep
                            } else if self.representativeOrOwner == "owner3" {
                                self.businessBankingInfo?.owner3 = rep
                            } else if self.representativeOrOwner == "owner4" {
                                self.businessBankingInfo?.owner4 = rep
                            }
                            self.deletePerson(stripeId: self.businessBankingInfo!.stripeAccountId, personId: self.businessBankingInfo!.representative!.id, representativeOrOwner: "owner")
                            self.createPerson(representativeOrOwner: "owner")
                            
                            
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        
                        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
                            
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        present(alert, animated: true, completion: nil)
                        
                    } else {
                        var owner = Representative(isPersonAnOwner: self.isPersonAnOwner, isPersonAnExectutive: self.isPersonAnExectutive, firstName: self.firstName.text!, lastName: self.lastName.text!, month: self.month.text!, day: self.day.text!, year: self.year.text!, streetAddress: self.streetAddress.text!, city: self.city.text!, state: self.state.text!, zipCode: self.zipCode.text!, emailAddress: self.emailAddress.text!, phoneNumber: self.phoneNumber.text!, last4OfSSN: self.last4OfSSN.text!, id: "")
                        
                        if representativeOrOwner == "owner1" {
                            self.businessBankingInfo!.owner1 = owner
                        } else if representativeOrOwner == "owner2" {
                            self.businessBankingInfo!.owner2 = owner
                        } else if representativeOrOwner == "owner3" {
                            self.businessBankingInfo!.owner3 = owner
                        } else if representativeOrOwner == "owner4" {
                            self.businessBankingInfo!.owner4 = owner
                        }
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Owners") as? OwnersViewController  {
                            vc.newAccountOrEditedAccount = "new"
                            vc.businessBankingInfo = self.businessBankingInfo!
                            self.present(vc, animated: true)
                        }
                    }
                    
                }
        }
        
        
    }
    
    @IBAction func delerteButtonPressed(_ sender: UIButton) {
        var owner = Representative(isPersonAnOwner: "", isPersonAnExectutive: "", firstName: "", lastName: "", month: "", day: "", year: "", streetAddress: "", city: "", state: "", zipCode: "", emailAddress: "", phoneNumber: "", last4OfSSN: "", id: "")
        if newAccountOrEditedAccount == "new" {
            
            if representativeOrOwner == "owner1" {
                businessBankingInfo!.owner1 = owner
            } else if representativeOrOwner == "owner2" {
                businessBankingInfo!.owner2 = owner
            } else if representativeOrOwner == "owner3" {
                businessBankingInfo!.owner3 = owner
            } else if representativeOrOwner == "owner4" {
                businessBankingInfo!.owner4 = owner
            }
            
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Owners") as? OwnersViewController  {
                    
                vc.businessBankingInfo = businessBankingInfo!
                self.present(vc, animated: true, completion: nil)
                }
        } else {
            let alert = UIAlertController(title: "Are you sure you want to delete this person?", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (handler) in
                var owner = Representative(isPersonAnOwner: "", isPersonAnExectutive: "", firstName: "", lastName: "", month: "", day: "", year: "", streetAddress: "", city: "", state: "", zipCode: "", emailAddress: "", phoneNumber: "", last4OfSSN: "", id: "")
                
                
                if self.representativeOrOwner == "owner1" {
                    self.deletePerson(stripeId: self.businessBankingInfo!.stripeAccountId, personId: self.businessBankingInfo!.owner1!.id, representativeOrOwner: "owner")
                    self.businessBankingInfo!.owner1 = owner
                } else if self.representativeOrOwner == "owner2" {
                    self.deletePerson(stripeId: self.businessBankingInfo!.stripeAccountId, personId: self.businessBankingInfo!.owner2!.id, representativeOrOwner: "owner")
                    self.businessBankingInfo!.owner2 = owner
                } else if self.representativeOrOwner == "owner3" {
                    self.deletePerson(stripeId: self.businessBankingInfo!.stripeAccountId, personId: self.businessBankingInfo!.owner3!.id, representativeOrOwner: "owner")
                    self.businessBankingInfo!.owner3 = owner
                } else if self.representativeOrOwner == "owner4" {
                    self.deletePerson(stripeId: self.businessBankingInfo!.stripeAccountId, personId: self.businessBankingInfo!.owner4!.id, representativeOrOwner: "owner")
                    self.businessBankingInfo!.owner4 = owner
                }
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Owners") as? OwnersViewController  {
                    
                    vc.businessBankingInfo = self.businessBankingInfo!
                    self.present(vc, animated: true, completion: nil)
                }
                alert.dismiss(animated: true)
        
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

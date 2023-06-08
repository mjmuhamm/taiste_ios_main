//
//  OrderDetailsViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/25/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import DropDown
import MapKit
import CoreLocation
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class OrderDetailsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var typeOfEventText: MDCOutlinedTextField!
    @IBOutlet weak var typeOfEventButton: UIButton!
    
    private let db = Firestore.firestore()
    private let user = "malik@testing.com"
    
    
    @IBOutlet weak var quantityOfEventText: MDCOutlinedTextField!
    
    @IBOutlet weak var dateOfEventButton: UIButton!
    @IBOutlet weak var dateOfEventText: UILabel!
    @IBOutlet weak var datesOfEventView: UIView!
    @IBOutlet weak var dateOfEventViewText: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addDateViewButton: MDCButton!
    @IBOutlet weak var okDateViewButton: MDCButton!
    
    let typeOfEventDropDown = DropDown()
    let quantityOfEventDropDown = DropDown()
    
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var streetAddressText: UITextField!
    @IBOutlet weak var streetAddressText2: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var stateText: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var locationOkButton: MDCButton!
    @IBOutlet weak var locationOfEventText: UILabel!
    @IBOutlet weak var notesToChefText: UITextField!
    @IBOutlet weak var eventTotalText: UILabel!
    
    @IBOutlet weak var clearDatesButton: MDCButton!
    @IBOutlet weak var seeAllDatesButton: MDCButton!
    
    
    @IBOutlet weak var seeAllDatesView: UIView!
    
    @IBOutlet weak var seeAllDatesText: UILabel!
    @IBOutlet weak var seeAllDatesOkButton: MDCButton!
    @IBOutlet weak var addEventButton: MDCButton!
    
    let locationManager = CLLocationManager()
    private var latitude : CLLocationDegrees?
    private var longitude : CLLocationDegrees?
    
    private var eventDays : [String] = []
    private var eventTimes : [String] = []
    
    private var travelFeeExpenseOption = "No"
    private var distance = ""
    
    var item : FeedMenuItems?
    var personalChefInfo : PersonalChefInfo?
    var newOrEdit = ""
    var documentId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if newOrEdit == "edit" {
            loadInfo()
        }
            quantityOfEventText.addTarget(self, action: #selector(OrderDetailsViewController.textFieldDidChange(_:)), for: .editingChanged)
        typeOfEventDropDown.dataSource = ["Corporate", "Social", "Celebration", "Birthday", "Other"]
        if item != nil {
            if item!.itemType == "Cater Items" {
                quantityOfEventDropDown.dataSource = ["1-10", "11-25", "26-40","41-55", "56-70", "71-90"]
            } else if item!.itemType == "MealKit Items" {
                quantityOfEventDropDown.dataSource = ["1", "2", "3", "4", "5"]
            }
        }
        
        typeOfEventDropDown.selectionAction = { index, item in
            self.typeOfEventText.text = item
        }
        
        quantityOfEventDropDown.selectionAction = { index, item1 in
            self.quantityOfEventText.text = item1
            var days = Double(self.eventDays.count)
            if days == 0 {
                days = 1.0
            }
            
            if (self.quantityOfEventText.text == "1-10") {
                let a = String(format: "%.2f", Double(self.item!.itemPrice)! * 7.0 * days)
                self.eventTotalText.text = "$\(a)"
            } else if self.quantityOfEventText.text == "11-25" {
                let a = String(format: "%.2f", Double(self.item!.itemPrice)! * 21.0 * days)
                self.eventTotalText.text = "$\(a)"
            } else if self.quantityOfEventText.text == "26-40" {
                let a = String(format: "%.2f", Double(self.item!.itemPrice)! * 33.0 * days)
                self.eventTotalText.text = "$\(a)"
            } else if self.quantityOfEventText.text == "41-55" {
                let a = String(format: "%.2f", Double(self.item!.itemPrice)! * 51.0 * days)
                self.eventTotalText.text = "$\(a)"
            } else if self.quantityOfEventText.text == "56-70" {
                let a = String(format: "%.2f", Double(self.item!.itemPrice)! * 63.0 * days)
                self.eventTotalText.text = "$\(a)"
            } else if self.quantityOfEventText.text == "71-90" {
                let a = String(format: "%.2f", Double(self.item!.itemPrice)! * 82.0 * days)
                self.eventTotalText.text = "$\(a)"
            } else {
                let a = String(format: "%.2f", Double(self.item!.itemPrice)! * Double(self.quantityOfEventText.text!)! * days)
                self.eventTotalText.text = "$\(a)"
            }
            
        }
        
        typeOfEventDropDown.anchorView = typeOfEventText
        quantityOfEventDropDown.anchorView = quantityOfEventText
        
        print("date \(datePicker.calendar.timeZone)")
        var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
       

        clearDatesButton.isHidden = true
        seeAllDatesButton.isHidden = true
        clearDatesButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        seeAllDatesButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        seeAllDatesOkButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        clearDatesButton.layer.cornerRadius = 2
        seeAllDatesButton.layer.cornerRadius = 2
        seeAllDatesOkButton.layer.cornerRadius = 2
        
        locationOkButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        locationOkButton.layer.cornerRadius = 2
        
        if item != nil {
            itemTitle.text = item!.itemTitle
            itemDescription.text = item!.itemDescription
        }
        addDateViewButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        okDateViewButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        addDateViewButton.layer.cornerRadius = 2
        okDateViewButton.layer.cornerRadius = 2
        datePicker.datePickerMode = .dateAndTime
        
        
        typeOfEventText.setOutlineColor(UIColor.systemGray4, for: .normal)
        typeOfEventText.setOutlineColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        typeOfEventText.setTextColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        typeOfEventText.setTextColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        
        typeOfEventText.setNormalLabelColor(UIColor.systemGray4, for: .normal)
        typeOfEventText.setFloatingLabelColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        
        quantityOfEventText.setOutlineColor(UIColor.lightGray, for: .normal)
        quantityOfEventText.setOutlineColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        quantityOfEventText.setTextColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        quantityOfEventText.setTextColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        
        quantityOfEventText.setNormalLabelColor(UIColor.systemGray4, for: .normal)
        quantityOfEventText.setFloatingLabelColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        
        typeOfEventText.label.text = "Type Of Event"
        typeOfEventText.placeholder = "Type Of Event"
        
        quantityOfEventText.label.text = "Quantity of Event"
        quantityOfEventText.placeholder = "Quantity of Event"
        
        typeOfEventText.setNormalLabelColor(UIColor.systemGray4, for: .normal)
        typeOfEventText.setFloatingLabelColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        
        quantityOfEventText.setNormalLabelColor(UIColor.systemGray4, for: .normal)
        quantityOfEventText.setFloatingLabelColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        
        
        datePicker.minimumDate = Date()
        // Do any additional setup after loading the view.
    }
    
    private func loadInfo() {
        
        addEventButton.setTitle("Cancel", for: .normal)
        addEventButton.titleLabel?.font = .systemFont(ofSize: 15)
        addEventButton.setTitleColor(UIColor.red, for: .normal)
        addEventButton.isUppercaseTitle = false
        quantityOfEventText.isEnabled = false
        dateOfEventButton.isEnabled = false
        notesToChefText.isEnabled = false
        clearDatesButton.isEnabled = false
        typeOfEventButton.isEnabled = false
        typeOfEventText.isEnabled = false
        db.collection("User").document(Auth.auth().currentUser!.uid).collection("Cart").document(documentId).getDocument { document, error in
            if error == nil {
                if document != nil {
                    let data = document!.data()
                    
                    if let chefEmail = data!["chefEmail"] as? String, let chefImageId = data!["chefImageId"] as? String, let chefUsername = data!["chefUsername"] as? String, let menuItemId = data!["menuItemId"] as? String, let itemDescription = data!["itemDescription"] as? String, let itemTitle = data!["itemTitle"] as? String, let datesOfEvent = data!["datesOfEvent"] as? [String], let timesForDatesOfEvent = data!["timesForDatesOfEvent"] as? [String], let travelExpenseOption = data!["travelExpenseOption"] as? String, let totalCostOfEvent = data!["totalCostOfEvent"] as? Double, let priceToChef = data!["priceToChef"] as? Double, let quantityOfEvent = data!["quantityOfEvent"] as? String, let unitPrice = data!["unitPrice"] as? String, let distance = data!["distance"] as? String, let location = data!["location"] as? String, let latitudeOfEvent = data!["latitudeOfEvent"] as? String, let longitudeOfEvent = data!["longitudeOfEvent"] as? String, let notesToChef = data!["notesToChef"] as? String, let typeOfService = data!["typeOfService"] as? String, let typeOfEvent = data!["typeOfEvent"] as? String, let city = data!["city"] as? String, let state = data!["state"] as? String, let user = data!["user"] as? String, let imageCount = data!["imageCount"] as? Int, let liked = data!["liked"] as? [String], let itemOrders = data!["itemOrders"] as? Int, let itemRating = data!["itemRating"] as? [Double], let itemCalories = data!["itemCalories"] as? String, let allergies = data!["allergies"] as? String, let additionalMenuItems = data!["additionalMenuItems"] as? String {
                        
                        self.itemTitle.text = "Executive Chef"
                        self.itemDescription.text = itemDescription
                        self.typeOfEventText.text = typeOfEvent
                        self.quantityOfEventText.text = quantityOfEvent
                        self.documentId = document!.documentID
                        for i in 0..<datesOfEvent.count {
                            if i == 0 {
                                self.dateOfEventText.text = "\(datesOfEvent[i]) \(timesForDatesOfEvent[i])"
                            } else {
                                if i < 2 {
                                    self.dateOfEventText.text = "\(self.dateOfEventText.text!), \(datesOfEvent[i]) \(timesForDatesOfEvent[i])"
                                    self.seeAllDatesText.text = self.dateOfEventText.text
                                    
                                } else {
                                    self.seeAllDatesText.text = "\(self.seeAllDatesText.text!), \(datesOfEvent[i]) \(timesForDatesOfEvent[i])"
                                    self.seeAllDatesButton.isHidden = false
                                }
                            }
                            
                        }
                        self.locationOfEventText.text = location
                        self.notesToChefText.text = notesToChef
                        let a = String(format: "%.2f", totalCostOfEvent)
                        self.eventTotalText.text = "$\(a)"
                        
                        
                    }
                }
            }
        }
    }
    

    @IBAction func okDateViewButtonPressed(_ sender: Any) {
        for i in 0..<eventDays.count {
            if i == 0 {
                dateOfEventText.text = "\(eventDays[i]) \(eventTimes[i])"
            } else {
                if i < 2 {
                    dateOfEventText.text = "\(dateOfEventText.text!), \(eventDays[i]) \(eventTimes[i])"
                    seeAllDatesText.text = dateOfEventText.text
                    
                } else {
                    seeAllDatesText.text = "\(seeAllDatesText.text!), \(eventDays[i]) \(eventTimes[i])"
                    seeAllDatesButton.isHidden = false
                }
            }
            
        }
        
        var days = Double(self.eventDays.count)
        if days == 0 {
            days = 1.0
        }
        
       
        dateOfEventText.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        
            clearDatesButton.isHidden = false
        typeOfEventText.isHidden = false
        
        datesOfEventView.isHidden = true
        
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        var days = Double(self.eventDays.count)
        if days == 0 {
            days = 1.0
        }
        if quantityOfEventText.text != "" {
            if Int(quantityOfEventText.text!)! >= 10 {
                let a = String(format: "%.2f", Double(self.item!.itemPrice)! * Double(self.quantityOfEventText.text!)! * days)
                self.eventTotalText.text = "$\(a)"
            }
            print("happeneing \(quantityOfEventText.text)")
        }
    }
    
    @IBAction func addDateViewButtonPressed(_ sender: Any) {
        let date = "\(datePicker.date)"
        let month = date.prefix(7).suffix(2)
        let day = date.prefix(10).suffix(2)
        let year = date.prefix(4)
        
        var hour = Int(date.prefix(16).suffix(5).prefix(2))
        let minute = date.prefix(16).suffix(2)
        
        var amOrPm = "AM"
        
        if hour! >= 17  {
            hour! -= 17
            amOrPm = "PM"
            if hour! == 0 {
                hour! = 12
            }
        } else if hour! < 5 {
            hour! += 7
            amOrPm = "PM"
        } else {
            hour! -= 5
            if hour! == 0 {
                hour = 12
            }
            amOrPm = "AM"
        }
        
        
        var newHour = ""
        if hour! >= 10 {
            newHour = "\(hour! + 1)"
        } else {
            newHour = "0\(hour! + 1)"
        }
        
        let newDay = "\(month)-\(day)-\(year)"
        let newTime = "\(newHour):\(minute) \(amOrPm)"
        
        let item = "\(newDay) \(newTime)"
    
        if (!eventDays.contains(where: { $0 == newDay })) {
        if eventDays.isEmpty {
            dateOfEventViewText.text = item
        } else {
            dateOfEventViewText.text = "\(dateOfEventViewText.text!), \(item)"
        }
        
        eventDays.append(newDay)
        eventTimes.append(newTime)
           
        } else {
            showToast(message: "This day has already been selected.", font: .systemFont(ofSize: 12))
        }
         
        
        
        addDateViewButton.setTitle("Add Another", for: .normal)
        addDateViewButton.titleLabel?.font = .systemFont(ofSize: 15)
        addDateViewButton.isUppercaseTitle = false
       
        
        print("print \(datePicker.date)")
       
    }
    
    @IBAction func dateOfEventButtonPressed(_ sender: Any) {
        datesOfEventView.isHidden = false
        typeOfEventText.isHidden = true
        if (clearDatesButton.isHidden == false) {
            clearDatesButton.isHidden = true
        }
        if (seeAllDatesButton.isHidden == false) {
            seeAllDatesButton.isHidden = true
        }
    
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func typeOfEventButton(_ sender: Any) {
        typeOfEventDropDown.show()
    }
    
    @IBAction func quantityOfEventButton(_ sender: Any) {
        quantityOfEventDropDown.show()
    }
    
    @IBAction func clearDatesButtonPressed(_ sender: Any) {
        eventDays.removeAll()
        eventTimes.removeAll()
        seeAllDatesText.text = ""
        dateOfEventText.text = " Select a date for your event here."
        dateOfEventViewText.text = "Date(s) of Event"
        eventTotalText.text = ""
        clearDatesButton.isHidden = true
        seeAllDatesButton.isHidden = true
        addDateViewButton.setTitle("Add", for: .normal)
        addDateViewButton.titleLabel?.font = .systemFont(ofSize: 15)
        addDateViewButton.isUppercaseTitle = false
        
        dateOfEventText.textColor = UIColor.systemGray2
    }
    
    @IBAction func seeAllDatesButtonPressed(_ sender: Any) {
        seeAllDatesView.isHidden = false
        clearDatesButton.isHidden = true
        seeAllDatesButton.isHidden = true
    }
    
    @IBAction func seeAllDatesOkButtonPressed(_ sender: Any) {
        seeAllDatesView.isHidden = true
        clearDatesButton.isHidden = false
        seeAllDatesButton.isHidden = false
        
    }
    
    @IBAction func locationOfEventButtonPressed(_ sender: Any) {
        if newOrEdit != "edit" {
            locationView.isHidden = false
            quantityOfEventText.isHidden = true
            clearDatesButton.isHidden = true
            seeAllDatesButton.isHidden = true
        }
        

    }
    
    @IBAction func locationBackButtonPressed(_ sender: Any) {
        streetAddressText.text = ""
        streetAddressText2.text = ""
        cityText.text = ""
        stateText.text = ""
        zipCode.text = ""
        
        if self.eventDays.count > 2 {
            self.seeAllDatesButton.isHidden = false
        }
        if (!self.eventDays.isEmpty) {
            self.clearDatesButton.isHidden = false
        }
        self.locationView.isHidden = true
        self.quantityOfEventText.isHidden = false
    }
    
    var no = ""
    @IBAction func locationOkButtonPressed(_ sender: Any) {
        clearDatesButton.isHidden = true
        seeAllDatesButton.isHidden = true
        var locationI = ""
        if streetAddressText.text!.isEmpty {
            showToast(message: "Please enter a street address in the allotted field.", font: .systemFont(ofSize: 12))
        } else if cityText.text!.isEmpty {
            showToast(message: "Please enter a city in the allotted field.", font: .systemFont(ofSize: 12))
        } else if stateText.text!.isEmpty {
            showToast(message: "Please enter a state in the allotted field.", font: .systemFont(ofSize: 12))
        } else if zipCode.text!.isEmpty {
                showToast(message: "Please enter a zip code in the allotted field.", font: .systemFont(ofSize: 12))
        } else {
        if streetAddressText2.text == "" {
            locationI = "\(streetAddressText.text!) \(cityText.text!), \(stateText.text!) \(zipCode.text!)"
        } else {
            locationI = "\(streetAddressText.text!) \(streetAddressText2.text!) \(cityText.text!), \(stateText.text!) \(zipCode.text!)"
        }
            let geoCoder1 = CLGeocoder()
            let location2 = "\(self.item!.city) \(self.item!.state) \(self.item!.zipCode)"
            var latitude1 : CLLocationDegrees?
            var longitude1 : CLLocationDegrees?
            
            geoCoder1.geocodeAddressString(location2) { placemarks, error in
                guard let placemarks = placemarks,
                      let location1 = placemarks.first?.location
                else {
                    return
                }
                latitude1 = location1.coordinate.latitude
                longitude1 = location1.coordinate.longitude
                
            
            
        let geoCoder = CLGeocoder()
           geoCoder.geocodeAddressString(locationI) { (placemarks1, error) in
               guard
                   let placemarks1 = placemarks1,
                   let location = placemarks1.first?.location
               else {
                   if self.no != "Yes" {
                       self.showToast(message: "We were unable to find a location. Please check your information and try again.", font: .systemFont(ofSize: 12))
                       self.no = "Yes"
                   } else {
                       
                       self.showToast(message: "Please stay in close contact with your chef.", font: .systemFont(ofSize: 12))
                       self.travelFeeExpenseOption = "Yes"
                       self.locationOfEventText.text = locationI
                       self.locationView.isHidden = true
                       
                       self.quantityOfEventText.isHidden = false
                   }
                   if self.eventDays.count > 2 {
                       self.seeAllDatesButton.isHidden = false
                   }
                   if (!self.eventDays.isEmpty) {
                       self.clearDatesButton.isHidden = false
                   }
                   // handle no location found
                   return
               }
               
               let latitude3 = location.coordinate.latitude
               let longitude3 = location.coordinate.longitude
               self.distance = "\(location.distance(from: CLLocation(latitude: latitude1!, longitude: longitude1!)) / 1609.34)"
               
               if (Double(self.distance)! > 45) {
                   self.showToast(message: "Please note that the chef will be given a travel fee option to be negotiated with you due to the distance of your event.", font: .systemFont(ofSize: 12))
                   self.travelFeeExpenseOption = "Yes"
               } else {
                   self.travelFeeExpenseOption = "No"
               }
               self.locationOfEventText.text = locationI
               if self.eventDays.count > 2 {
                   self.seeAllDatesButton.isHidden = false
               }
               if (!self.eventDays.isEmpty) {
                   self.clearDatesButton.isHidden = false
               }
               self.locationView.isHidden = true
               self.quantityOfEventText.isHidden = false
               // Use your location
               
           }
            }
        locationOfEventText.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        }
    }
    
    @IBAction func addEventButtonPressed(_ sender: MDCButton) {
        if newOrEdit != "edit" {
        if typeOfEventText.text!.isEmpty {
            showToast(message: "Please select the type of your event above.", font: .systemFont(ofSize: 12))
        } else if quantityOfEventText.text!.isEmpty {
            showToast(message: "Please select the quantity of your event above.", font: .systemFont(ofSize: 12))
        } else if (eventDays.isEmpty) {
            showToast(message: "Please select the day(s) of your event above.", font: .systemFont(ofSize: 12))
        } else if locationOfEventText.text == "Select a location for your event here." {
            showToast(message: "Please select the location of your event above.", font: .systemFont(ofSize: 12))
        } else {
            
                let priceToChef = Double(eventTotalText.text!.suffix(eventTotalText.text!.count - 1))! * 0.07
                let totalCostOfEVent = Double(eventTotalText.text!.suffix(eventTotalText.text!.count - 1))!
                
                let documentId = UUID().uuidString
                
            let data : [String: Any] = ["chefEmail" : item!.chefEmail, "chefImageId" : item!.chefImageId, "chefUsername" : item!.chefUsername, "city" : item!.city, "state" : item!.state, "datesOfEvent" : eventDays, "distance" : distance, "itemDescription" : item!.itemDescription, "itemTitle" : item!.itemTitle, "latitudeOfEvent" : "\(latitude)", "longitudeOfEvent" : "\(longitude)", "location" : locationOfEventText.text!, "menuItemId" : item!.menuItemId, "notesToChef" : notesToChefText.text!, "priceToChef" : priceToChef, "quantityOfEvent" : quantityOfEventText.text!, "timesForDatesOfEvent" : eventTimes, "totalCostOfEvent" : totalCostOfEVent, "travelExpenseOption" : travelFeeExpenseOption, "typeOfEvent" : typeOfEventText.text!, "typeOfService" : item!.itemType, "unitPrice" : item!.itemPrice, "user" : user, "imageCount" : item!.imageCount, "liked" : item!.liked, "itemOrders" : item!.itemOrders, "itemRating" : item!.itemRating, "itemCalories" : item!.itemCalories, "documentId" : documentId, "allergies" : "", "additionalMenuItems" : "", "signatureDishId" : ""]
                
                db.collection("User").document("\(Auth.auth().currentUser!.uid)").collection("Cart").document(documentId).setData(data)
                
                self.showToastCompletion(message: "Item Saved.", font: .systemFont(ofSize: 12))
            }
        } else {
            db.collection("User").document("\(Auth.auth().currentUser!.uid)").collection("Cart").document(documentId).delete()
            self.showToastCompletion(message: "Item Cancelled.", font: .systemFont(ofSize: 12))
    }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OrderDetailToUserTabSegue" {
            let info = segue.destination as! UserTabViewController
            info.whereTo = "home"
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
    
    func showToastCompletion(message : String, font: UIFont) {
        
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
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            self.performSegue(withIdentifier: "OrderDetailToUserTabSegue", sender: self)
            toastLabel.removeFromSuperview()
        })
    }
}

extension OrderDetailsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

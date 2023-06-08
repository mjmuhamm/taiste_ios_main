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

class PersonalChefOrderDetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var typeOfEventText: MDCOutlinedTextField!
    
    @IBOutlet weak var typeOfEventButton: UIButton!
    private let db = Firestore.firestore()
    private let user = "malik@testing.com"
    
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityText: MDCOutlinedTextField!
    @IBOutlet weak var allergiesLabel: UILabel!
    @IBOutlet weak var allergies: UITextField!
    @IBOutlet weak var additionalMenuItemsLabel: UILabel!
    @IBOutlet weak var additionalMenuItems: UITextField!
    
    @IBOutlet weak var dateOfEventButton: UIButton!
    @IBOutlet weak var dateOfEventText: UILabel!
    @IBOutlet weak var datesOfEventView: UIView!
    @IBOutlet weak var dateOfEventViewText: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addDateViewButton: MDCButton!
    @IBOutlet weak var okDateViewButton: MDCButton!
    
    let typeOfEventDropDown = DropDown()
    
    
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
    
    @IBOutlet weak var deleteButton: MDCButton!
    private var travelFeeExpenseOption = "No"
    private var distance = ""
    
    var item : FeedMenuItems?
    var personalChefInfo: PersonalChefInfo?
    
    var newOrEdit = ""
    var documentId = ""
    var checkoutItem : CheckoutItems?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("personal chef info \(personalChefInfo)")
        if newOrEdit == "edit" {
            loadInfo()
        }
        typeOfEventDropDown.dataSource = ["Trial Run", "Weeks", "Months"]
       
        itemTitle.text = "Executive Chef"
        if personalChefInfo != nil {
            itemDescription.text = personalChefInfo!.briefIntroduction
        }
        
        typeOfEventDropDown.selectionAction = { index, item in
            self.typeOfEventText.text = item
            self.quantityText.text = ""
            self.eventDays.removeAll()
            self.eventTimes.removeAll()
            self.clearDatesButton.isHidden = true
            self.seeAllDatesButton.isHidden = true
            self.dateOfEventText.textColor = UIColor.systemGray2
            self.dateOfEventText.text = " Select the date(s) for your service here."
        }
        
        
        typeOfEventDropDown.anchorView = typeOfEventText
        
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
        
        typeOfEventText.label.text = "Time Period of Service"
        typeOfEventText.placeholder = "Time Period of Service"
        
        
        typeOfEventText.setNormalLabelColor(UIColor.systemGray4, for: .normal)
        typeOfEventText.setFloatingLabelColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        
        quantityText.setOutlineColor(UIColor.lightGray, for: .normal)
        quantityText.setOutlineColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        quantityText.setTextColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        quantityText.setTextColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        
        quantityText.setNormalLabelColor(UIColor.systemGray4, for: .normal)
        quantityText.setFloatingLabelColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        
        
        quantityText.label.text = "# of Guest Being Serviced"
        quantityText.placeholder = "# of Guest Being Serviced"
        
        quantityText.setNormalLabelColor(UIColor.systemGray4, for: .normal)
        quantityText.setFloatingLabelColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        datePicker.minimumDate = Date()
        // Do any additional setup after loading the view.
    }
    
    private func loadInfo() {
        
        addEventButton.setTitle("Cancel", for: .normal)
        addEventButton.titleLabel?.font = .systemFont(ofSize: 15)
        addEventButton.setTitleColor(UIColor.red, for: .normal)
        addEventButton.isUppercaseTitle = false
        quantityText.isEnabled = false
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
                        self.quantityText.text = quantityOfEvent
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
                        self.allergies.text = allergies
                        self.additionalMenuItems.text = additionalMenuItems
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
                dateOfEventText.text = "\(i+1). \(eventDays[i]) \(eventTimes[i])"
                seeAllDatesText.text = dateOfEventText.text!
            } else {
                seeAllDatesText.text = "\(seeAllDatesText.text!) | \(i+1). \(eventDays[i]) \(eventTimes[i])"
                seeAllDatesButton.isHidden = false
                
            }
            
        }
        
        var days = Double(self.eventDays.count)
        if days == 0 {
            days = 1.0
        }
        
       
        dateOfEventText.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        
        if eventDays.count > 0 {
            clearDatesButton.isHidden = false
        }
        typeOfEventText.isHidden = false
        allergies.isHidden = false
        allergiesLabel.isHidden = false
        additionalMenuItems.isHidden = false
        quantityText.isHidden = false
        additionalMenuItemsLabel.isHidden = false
        datesOfEventView.isHidden = true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        eventDays.removeAll()
        eventTimes.removeAll()
        seeAllDatesText.text = ""
        clearDatesButton.isHidden = true
        seeAllDatesButton.isHidden = true
        dateOfEventText.text = " Select the date(s) for your service here."
        eventTotalText.text = ""
        dateOfEventViewText.text = "Date(s) of Service"
        addDateViewButton.setTitle("Add", for: .normal)
        addDateViewButton.titleLabel?.font = .systemFont(ofSize: 15)
        addDateViewButton.isUppercaseTitle = false
        dateOfEventText.textColor = UIColor.systemGray2
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        var days = Double(self.eventDays.count)
        if days == 0 {
            days = 1.0
        }
       
    }
    
    @IBAction func addDateViewButtonPressed(_ sender: Any) {
        if typeOfEventText.text == "Trial Run" {
           
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
                    
                
                
                addDateViewButton.setTitle("Add Another", for: .normal)
                addDateViewButton.titleLabel?.font = .systemFont(ofSize: 15)
                addDateViewButton.isUppercaseTitle = false
                
                    self.eventTotalText.text = "\(Double(personalChefInfo!.servicePrice)! * Double(eventDays.count)!)"
                    self.showToast(message: "Please order this item again with the remaining quantity amount.", font: .systemFont(ofSize: 12))
                    
                
                } else {
                    showToast(message: "This day has already been selected.", font: .systemFont(ofSize: 12))
                }
            
            
        } else if typeOfEventText.text == "Weeks" {
            
            
                
                let date = "\(datePicker.date)"
                let month = date.prefix(7).suffix(2)
                let day = date.prefix(10).suffix(2)
                let year = date.prefix(4)
                
                var arrWeekDates = Date().getWeekDates()
                
//                var endOfWeek = arrWeekDates.thisWeek[arrWeekDates.thisWeek.count - 2].toDate(format: "MM-dd-yyyy")
                
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
                
                var startOfWeek = "\(datePicker.date.getWeekDates().thisWeek[0])".prefix(10)
                var endOfWeek = "\(datePicker.date.getWeekDates().thisWeek[6])".prefix(10)
                
                
                print("these are the dates \(startOfWeek) through \(endOfWeek)")
                let df = DateFormatter()
                
                df.dateFormat = "yyyy-MM-dd"
                
                let x = df.date(from: "2023-01-05")
                print("datesss \(x!.getWeekDates().thisWeek)")
                
                let newTime = "\(newHour):\(minute) \(amOrPm)"
                let newWeek = "\(startOfWeek) \(newTime) through \(endOfWeek) \(newTime)"
                
                
                if (!eventDays.contains(where: { $0 == newWeek })) {
                    if eventDays.isEmpty {
                        dateOfEventViewText.text = newWeek
                    } else {
                        dateOfEventViewText.text = "\(dateOfEventViewText.text!), \(newWeek)"
                    }
                    
                    eventDays.append(newWeek)
                    eventTimes.append(newTime)
                   
                    self.eventTotalText.text = "\(Double(personalChefInfo!.servicePrice)! * Double(eventDays.count)! * 7)"
                        
                } else {
                    self.showToast(message: "This week has already been selected.", font: .systemFont(ofSize: 12))
                }
            
            
        } else if typeOfEventText.text == "Months" {
            
            if eventDays.count == 12 {
                self.showToast(message: "To service more months, please order this item again.", font: .systemFont(ofSize: 12))
            } else {
                let date = "\(datePicker.date)"
                let month = date.prefix(7).suffix(2)
                
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
                
                var newMonth = "\(month)"
                let newTime = "\(newHour):\(minute) \(amOrPm)"
                
                let item = "\(newMonth), \(newTime)"
                
                if (!eventDays.contains(where: { $0 == newMonth })) {
                    if eventDays.isEmpty {
                        dateOfEventViewText.text = item
                    } else {
                        dateOfEventViewText.text = "\(dateOfEventViewText.text!) | \(item)"
                    }
                    var a = ""
                    if (month == "1") { a = "January" } else if (month == "2") { a = "February" } else if month == "3" { a = "March" } else if month == "4" { a = "April" } else if month == "5" { a = "May" } else if a == "6" { a = "June" } else if month == "7" { a = "July" } else if month == "8" { a = "August" } else if month == "9" { a = "September" } else if month == "10" { a = "October" } else if month == "11" { a = "November" } else if month == "12" { a == "December" }
                    
                    eventDays.append(a)
                    eventTimes.append(newTime)
                    
                
                
                addDateViewButton.setTitle("Add Another", for: .normal)
                addDateViewButton.titleLabel?.font = .systemFont(ofSize: 15)
                addDateViewButton.isUppercaseTitle = false
              
                    self.eventTotalText.text = "\(Double(personalChefInfo!.servicePrice)! * Double(eventDays.count)! * 30)"
                    
                    
                    
                
                } else {
                    showToast(message: "This month has already been selected.", font: .systemFont(ofSize: 12))
                }
            }
            
        }
        
        print("print \(datePicker.date)")
       
    }
    
    @IBAction func dateOfEventButtonPressed(_ sender: Any) {
        if quantityText.text == "" {
            showToast(message: "Please insert a quantity before selecting any dates for accurate price forecasting.", font: .systemFont(ofSize: 12))
        } else if typeOfEventText.text == "" {
            showToast(message: "Please select a time period of service before selecting any dates for date logging.", font: .systemFont(ofSize: 12))
        } else {
            datesOfEventView.isHidden = false
            typeOfEventText.isHidden = true
            allergiesLabel.isHidden = true
            allergies.isHidden = true
            additionalMenuItems.isHidden = true
            additionalMenuItemsLabel.isHidden = true
            quantityText.isHidden = true
            if (clearDatesButton.isHidden == false) {
                clearDatesButton.isHidden = true
            }
            if (seeAllDatesButton.isHidden == false) {
                seeAllDatesButton.isHidden = true
            }
        }
    
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
   @IBAction func typeOfEventButton(_ sender: Any) {
        typeOfEventDropDown.show()
    }
    
    
    @IBAction func clearDatesButtonPressed(_ sender: Any) {
        eventDays.removeAll()
        eventTimes.removeAll()
        seeAllDatesText.text = ""
        dateOfEventText.text = " Select the date(s) for your service here."
        dateOfEventViewText.text = "Date(s) of Service"
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
        allergiesLabel.isHidden = true
        allergies.isHidden = true
        additionalMenuItems.isHidden = true
        additionalMenuItemsLabel.isHidden = true
    }
    
    @IBAction func seeAllDatesOkButtonPressed(_ sender: Any) {
        seeAllDatesView.isHidden = true
        clearDatesButton.isHidden = false
        seeAllDatesButton.isHidden = false
        allergiesLabel.isHidden = false
        allergies.isHidden = false
        additionalMenuItems.isHidden = false
        additionalMenuItemsLabel.isHidden = false
        
        
    }
    
    @IBAction func locationOfEventButtonPressed(_ sender: Any) {
        if newOrEdit != "edit" {
            locationView.isHidden = false
            quantityText.isHidden = true
            allergies.isHidden = true
            allergiesLabel.isHidden = true
            additionalMenuItems.isHidden = true
            additionalMenuItemsLabel.isHidden = true
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
        quantityText.isHidden = false
        allergies.isHidden = false
        allergiesLabel.isHidden = false
        additionalMenuItems.isHidden = false
        additionalMenuItemsLabel.isHidden = false
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
            let location2 = "\(self.personalChefInfo!.city) \(self.personalChefInfo!.state) \(self.personalChefInfo!.zipCode)"
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
                       
                       self.quantityLabel.isHidden = false
                       self.quantityText.isHidden = false
                       self.allergies.isHidden = false
                       self.allergiesLabel.isHidden = false
                       self.additionalMenuItems.isHidden = false
                       self.additionalMenuItemsLabel.isHidden = false
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
               self.quantityText.isHidden = false
               self.allergies.isHidden = false
               self.allergiesLabel.isHidden = false
               self.additionalMenuItems.isHidden = false
               self.additionalMenuItemsLabel.isHidden = false
               
               // Use your location
               
           }
            }
        locationOfEventText.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        }
    }
    
    @IBAction func addEventButtonPressed(_ sender: MDCButton) {
        if newOrEdit != "edit" {
            if typeOfEventText.text!.isEmpty {
                showToast(message: "Please select the time period of your service..", font: .systemFont(ofSize: 12))
            } else if quantityText.text!.isEmpty {
                showToast(message: "Please select the number of people the service in intended for.", font: .systemFont(ofSize: 12))
            } else if (eventDays.isEmpty) {
                showToast(message: "Please select the day(s) of your service above.", font: .systemFont(ofSize: 12))
            } else if locationOfEventText.text == "Select a location for your event here." {
                showToast(message: "Please select the location of your event above.", font: .systemFont(ofSize: 12))
            } else if allergies.text == "" {
                showToast(message: "If no allergies, please insert 'No'.", font: .systemFont(ofSize: 12))
            } else if additionalMenuItems.text == "" {
                showToast(message: "If no additional menu items, please insert 'No'.", font: .systemFont(ofSize: 12))
            } else {
                let priceToChef = Double(eventTotalText.text!.suffix(eventTotalText.text!.count - 1))! * 0.07
                let totalCostOfEVent = Double(eventTotalText.text!.suffix(eventTotalText.text!.count - 1))!
                
                let documentId = UUID().uuidString
                let item = personalChefInfo!
                let data : [String: Any] = ["chefEmail" : item.chefEmail, "chefImageId" : item.chefImageId, "chefUsername" : item.chefName, "city" : item.city, "state" : item.state, "datesOfEvent" : eventDays, "distance" : distance, "itemDescription" : item.briefIntroduction, "itemTitle" : "Executive Chef", "latitudeOfEvent" : "\(latitude)", "longitudeOfEvent" : "\(longitude)", "location" : locationOfEventText.text!, "menuItemId" : item.documentId, "notesToChef" : notesToChefText.text!, "priceToChef" : priceToChef, "quantityOfEvent" : quantityText.text!, "timesForDatesOfEvent" : eventTimes, "totalCostOfEvent" : totalCostOfEVent, "travelExpenseOption" : travelFeeExpenseOption, "typeOfEvent" : typeOfEventText.text!, "typeOfService" : "Executive Item", "unitPrice" : item.servicePrice, "user" : item.chefImageId, "imageCount" : 1, "liked" : item.liked, "itemOrders" : item.itemOrders, "itemRating" : item.itemRating, "itemCalories" : "0", "documentId" : item.documentId, "allergies" : allergies.text!, "additionalMenuItems" : additionalMenuItems.text!]
                
                db.collection("User").document("\(Auth.auth().currentUser!.uid)").collection("Cart").document(documentId).setData(data)
                
                self.showToastCompletion(message: "Item Saved.", font: .systemFont(ofSize: 12))
            }
        } else {
            db.collection("User").document("\(Auth.auth().currentUser!.uid)").collection("Cart").document(documentId).delete()
            self.showToastCompletion(message: "Item Cancelled.", font: .systemFont(ofSize: 12))
        }
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
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
            self.performSegue(withIdentifier: "PersonalChefOrderDetailToUserTabSegue", sender: self)
            toastLabel.removeFromSuperview()
        })
    }
}

extension PersonalChefOrderDetailViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

extension Date {

    func getWeekDates() -> (thisWeek:[Date],nextWeek:[Date]) {
        var tuple: (thisWeek:[Date],nextWeek:[Date])
        var arrThisWeek: [Date] = []
        for i in 0..<7 {
            arrThisWeek.append(Calendar.current.date(byAdding: .day, value: i, to: startOfWeek)!)
        }
        var arrNextWeek: [Date] = []
        for i in 1...7 {
            arrNextWeek.append(Calendar.current.date(byAdding: .day, value: i, to: arrThisWeek.last!)!)
        }
        tuple = (thisWeek: arrThisWeek,nextWeek: arrNextWeek)
        return tuple
    }

    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }

    var startOfWeek: Date {
        var gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return gregorian.date(byAdding: .day, value: 0, to: sunday!)!
    }
    
    func dayNumberOfWeek() -> Int? {
           return Calendar.current.dateComponents([.weekday], from: self).weekday
       }

    func toDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

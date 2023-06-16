//
//  DashboardViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/23/22.
//

import UIKit
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming
import MaterialComponents.MaterialButtons
import MaterialComponents
import DropDown
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

class DashboardViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var itemTypeText: MDCOutlinedTextField!
    @IBOutlet weak var itemText: MDCOutlinedTextField!
    @IBOutlet weak var itemTypeButton: MDCButton!
    @IBOutlet weak var itemButton: MDCButton!
    
    let itemTypeMenu = DropDown()
    let itemMenu = DropDown()
    
    @IBOutlet weak var weeklyButton: MDCButton!
    @IBOutlet weak var monthlyButton: MDCButton!
    @IBOutlet weak var totalButton: MDCButton!
    
    
    @IBOutlet weak var weeklyBarChart: BarChartView!
    @IBOutlet weak var monthlyBarChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var notificationsImage: UIImageView!
    
    private let db = Firestore.firestore()
    private var items : [FoodItems] = []
    var yearlyItems : [String] = ["All", "Cater Items", "Executive Items", "MealKit Items"]
    private var time = "Weekly"
    
    let date = Date()
    let df = DateFormatter()
    
    
    //Date
    private var year = ""
    private var month = ""
    private var yearMonth = ""
    private var quarter = "1"
    private var monthStart = "01"
    private var monthEnd = "07"
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        itemTypeButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        itemButton.setBorderColor(.clear, for: .normal)
        itemTypeButton.setBorderColor(.clear, for: .normal)
        
        itemTypeMenu.dataSource = ["Cater Items", "Personal Chef Items", "MealKit Items"]
        itemTypeMenu.anchorView = itemTypeText
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
       
        itemTypeMenu.selectionAction = { index, item in
            self.itemTypeText.text = item
            if self.time != "Yearly" {
            self.loadFoodItems(itemType: item)
            } else {
            self.loadItemYearlyData(itemTitle: item)
            }
        }
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
        itemMenu.anchorView = itemText
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            itemMenu.selectionAction = { index, item in
                self.itemText.text = item
                if self.time == "Weekly" {
                    print("weekly \(self.items)")
                    self.loadItemWeeklyData(itemTitle: item)
                } else if self.time == "Monthly" {
                    self.loadItemMonthlyData(itemTitle: item)
                }
            }
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
           }
        
        
        // Date
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
      
        let dateString = df.string(from: date)
        year = "\(dateString.prefix(4))"
        month = "\(dateString.prefix(7).suffix(2))"
        yearMonth = "\(year), \(month)"
        
            print("month number first\(self.month)")
        if Int(month)! < 7 {
            quarter = "1"
            monthStart = "01"
            monthEnd = "7"
        } else {
            quarter = "2"
            monthStart = "07"
            monthEnd = "13"
        }
        //
        
        
        
        //Charts
        weeklyBarChart.delegate = self
        monthlyBarChart.delegate = self
        pieChart.delegate = self
        
        
//        itemText.applyOutlinedTheme(withScheme: globalContainerScheme())
//        itemTypeText.borderStyle

        itemTypeText.layer.cornerRadius = 2
        itemText.layer.cornerRadius = 2
        
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
        
        if Auth.auth().currentUser != nil {
            loadNotifications()
        }
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = UIColor.white
    }

    private func loadNotifications() {
        if Auth.auth().currentUser != nil {
            db.collection("Chef").document(Auth.auth().currentUser!.uid).addSnapshotListener { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        if let notifications = data?["notifications"] as? String {
                            if notifications == "yes" {
                                self.notificationsImage.isHidden = false
                            } else {
                                self.notificationsImage.isHidden = true
                            }
                        }
                    }
                }
            }
        } else {
            self.showToast(message: "Something went wrong. Please check connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    private func loadFoodItems(itemType: String) {
        items.removeAll()
        itemMenu.dataSource.removeAll()
        itemText.text = ""
        var itemType1 = ""
        if itemType == "Personal Chef Items" {
            itemType1 = "Executive Items"
        } else {
            itemType1 = itemType
        }
        if Auth.auth().currentUser != nil {
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(itemType1).getDocuments { documents, error in
                
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                            if let itemTitle = data["itemTitle"] as? String {
                                self.items.append(FoodItems(menuItemId: doc.documentID, itemTitle: itemTitle))
                                self.itemMenu.dataSource.append(itemTitle)
                                
                            }
                        }
                    } else {
                        self.items.append(FoodItems(menuItemId: "", itemTitle: "There no items in \(itemType)."))
                        self.itemMenu.dataSource.append("There are no items in \(itemType).")
                        
                    }
                }
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    private func loadItemWeeklyData(itemTitle: String) {
        if Auth.auth().currentUser != nil {
            let month = "\(df.string(from: date))".prefix(7).suffix(2)
            let year = "\(df.string(from: date))".prefix(4)
            let yearMonth = "\(year), \(month)"
            var itemId = ""
            for i in 0..<items.count {
                if items[i].itemTitle == itemTitle {
                    itemId = items[i].menuItemId
                }
            }
            //        var entries = [BarChartDataEntry]()
            
            var weeklyData : [BarChartDataEntry] = [BarChartDataEntry(x: 0, y: 0), BarChartDataEntry(x: 1, y: 0), BarChartDataEntry(x: 2, y: 0), BarChartDataEntry(x: 3, y: 0)]
            let labels = ["Week 1", "Week 2", "Week 3", "Week 4"]
            weeklyBarChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:labels)
            if itemId != "" {
                for i in 1..<5 {
                    db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document("\(self.itemTypeText.text!)").collection(itemId).document("Month").collection(yearMonth).document("Week").collection("Week \(i)").getDocuments { documents, error in
                        
                        if error == nil {
                            if documents != nil {
                                for doc in documents!.documents {
                                    let data = doc.data()
                                    if let total = data["totalPay"]     {
                                        //                                self.weeklyData[i-1] = "\(total)"
                                        weeklyData[i-1] = BarChartDataEntry(x: Double(i), y: Double("\(total)")!)
                                        
                                        print("data \(doc.data())")
                                        print("weekly data \(weeklyData[i-1])")
                                        
                                        self.weeklyBarChart.data?.notifyDataChanged()
                                        print("2 \(i-1)")
                                        
                                        let set = BarChartDataSet(entries: weeklyData)
                                        set.colors = ChartColorTemplates.pastel()
                                        let data = BarChartData(dataSet: set)
                                        self.weeklyBarChart.data = data
                                        self.weeklyBarChart.xAxis.granularityEnabled = true
                                        self.weeklyBarChart.xAxis.drawGridLinesEnabled = false
                                        //            weeklyBarChart.xAxis.drawAxisLineEnabled = true
                                        self.weeklyBarChart.leftAxis.drawAxisLineEnabled = false
                                        self.weeklyBarChart.rightAxis.drawGridLinesEnabled = false
                                        self.weeklyBarChart.xAxis.drawAxisLineEnabled = true
                                        self.weeklyBarChart.leftAxis.drawAxisLineEnabled = true
                                        self.weeklyBarChart.rightAxis.drawAxisLineEnabled = true
                                        self.weeklyBarChart.leftAxis.drawGridLinesEnabled = false
                                        self.weeklyBarChart.xAxis.axisMinimum = 0.2
                                        self.weeklyBarChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
                                        self.weeklyBarChart.xAxis.labelCount = labels.count
                                        self.weeklyBarChart.xAxis.centerAxisLabelsEnabled = true
                                        
                                        let groupSpace = 0.1
                                        let barSpace = 0.05
                                        let barWidth = 0.25
                                        
                                        let gg = data.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
                                        //                weeklyBarChart.xAxis.axisMaximum = Double(0) + gg * 6
                                        self.weeklyBarChart.xAxis.axisMaximum = 4
                                        data.groupBars(fromX:0, groupSpace: groupSpace, barSpace: barSpace)
                                        self.weeklyBarChart.xAxis.labelCount = labels.count
                                        self.weeklyBarChart.xAxis.centerAxisLabelsEnabled = true
                                        data.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
                                        
                                        self.weeklyBarChart.xAxis.granularityEnabled = true
                                        //            weeklyBarChart.xAxis.spaceMin = 0.3
                                        self.weeklyBarChart.xAxis.labelWidth = 1
                                        self.weeklyBarChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
                                    }}}
                        }
                    }}
                
                
                //            entries.append(BarChartDataEntry(x: Double(total)!, y: i))
                //            entries.append(BarChartDataEntry(x: Double(total)!, y: i))
                //            entries.append(BarChartDataEntry(x: Double(total)!, y: i))
                //            entries.append(BarChartDataEntry(x: Double(total)!, y: i))
                
                
                
                
            }
        }  else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    private func loadItemMonthlyData(itemTitle: String) {
        if Auth.auth().currentUser != nil {
            var itemId = ""
            let year = "\(df.string(from: date))".prefix(4)
            var yearMonth = "\(year), \(month)"
            
            var monthlyData : [BarChartDataEntry] = [BarChartDataEntry(x: 0, y: 0), BarChartDataEntry(x: 1, y: 0), BarChartDataEntry(x: 2, y: 0), BarChartDataEntry(x: 3, y: 0), BarChartDataEntry(x: 4, y: 0), BarChartDataEntry(x: 5, y: 0)]
            var labels = ["January", "February", "March", "April", "May", "June"]
            
            print("date \(year), \(month)")
            if Int(month)! > 6 {
                labels = ["July", "August", "September", "October", "November", "December"]
            }
            
            var newMonth = monthStart
            
            for i in 0..<items.count {
                if items[i].itemTitle == itemTitle {
                    itemId = items[i].menuItemId
                }
            }
            
            for i in Int(monthStart)!-1..<Int(monthEnd)!-1 {
                
                print("month number statr \(newMonth)")
                if i != 1 || i != 7 {
                    newMonth = "\(i + 1)"
                    if Int(newMonth)! < 10 {
                        newMonth = "0\(newMonth)"
                    }
                }
                yearMonth = "\(year), \(newMonth)"
                print("yearmonth \(yearMonth)")
                print("i \(i)")
                db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document("\(self.itemTypeText.text!)").collection(itemId).document("Month").collection(yearMonth).document("Total").getDocument { document, error in
                    
                    if error == nil {
                        if document != nil {
                            if let total = document!.get("totalPay") {
                                if self.monthStart == "01" {
                                    monthlyData[i] = BarChartDataEntry(x: Double(i), y: Double("\(total)")!)
                                } else {
                                    monthlyData[i-6] = BarChartDataEntry(x: Double(i-6), y: Double("\(total)")!)
                                }
                                
                                self.monthlyBarChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:labels)
                                let set = BarChartDataSet(entries: monthlyData)
                                set.colors = ChartColorTemplates.pastel()
                                let data = BarChartData(dataSet: set)
                                
                                let groupSpace = 0.1
                                let barSpace = 0.05
                                let barWidth = 0.25
                                
                                let gg = data.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
                                //            monthlyBarChart.xAxis.axisMaximum = Double(0) + gg * 6
                                self.monthlyBarChart.xAxis.axisMaximum = 6
                                self.monthlyBarChart.xAxis.axisMinimum = 0
                                data.groupBars(fromX:0, groupSpace: groupSpace, barSpace: barSpace)
                                data.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
                                
                                self.monthlyBarChart.xAxis.granularityEnabled = true
                                self.monthlyBarChart.data = data
                                self.monthlyBarChart.xAxis.drawGridLinesEnabled = false
                                //        monthlyBarChart.xAxis.drawAxisLineEnabled = true
                                self.monthlyBarChart.leftAxis.drawAxisLineEnabled = false
                                self.monthlyBarChart.rightAxis.drawGridLinesEnabled = false
                                self.monthlyBarChart.leftAxis.drawGridLinesEnabled = false
                                self.monthlyBarChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
                                //        monthlyBarChart.xAxis.axisMinimum = 4.0
                                
                                self.monthlyBarChart.leftAxis.drawAxisLineEnabled = true
                                self.monthlyBarChart.rightAxis.drawAxisLineEnabled = true
                                self.monthlyBarChart.leftAxis.drawGridLinesEnabled = false
                                self.monthlyBarChart.xAxis.axisMinimum = 0.2
                                self.monthlyBarChart.xAxis.labelCount = labels.count
                                self.monthlyBarChart.xAxis.centerAxisLabelsEnabled = true
                                
                                //        monthlyBarChart.xAxis.spaceMin = 0.8
                                self.monthlyBarChart.xAxis.labelWidth = 1
                                self.monthlyBarChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
                                
                            }
                        }
                    }
                }
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        
           
    
    }
    
    private func loadItemYearlyData(itemTitle: String) {
        if Auth.auth().currentUser != nil {
            print("item data going")
            var pieChartData : [PieChartDataEntry] = []
            self.pieChart.clearValues()
            self.pieChart.clear()
            
            
            var array1 = ["Cater Items", "Executive Items", "MealKit Items"]
            var totalItems : [FoodItemsTotal] = []
            if itemTypeText.text != "" {
                if itemTypeText.text == "All" {
                    for i in 0..<3 {
                        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(array1[i]).getDocument { document, error in
                            
                            if error == nil {
                                if document != nil {
                                    if let total = document!.get("totalPay") {
                                        pieChartData.append(PieChartDataEntry(value: Double("\(total)")!, label: array1[i]))
                                        
                                        let set = PieChartDataSet(entries: pieChartData)
                                        set.colors = ChartColorTemplates.pastel()
                                        self.pieChart.entryLabelColor = .clear
                                        set.entryLabelFont = .systemFont(ofSize: 11)
                                        let data = PieChartData(dataSet: set)
                                        self.pieChart.data = data
                                        self.pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    
                    db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(self.itemTypeText.text!).getDocuments { documents, error in
                        
                        if error == nil {
                            if documents?.documents != nil {
                                for doc in documents!.documents {
                                    let data = doc.data()
                                    
                                    if let menuItemId = data["randomVariable"] as? String, let itemTitle = data["itemTitle"] as? String {
                                        
                                        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(self.itemTypeText.text!).collection(menuItemId).document("Total").getDocument { document, error in
                                            
                                            if error == nil {
                                                if document != nil {
                                                    if let total = document?.get("totalPay") {
                                                        print("total \(total)")
                                                        print("item title \(itemTitle)")
                                                        
                                                        pieChartData.append(PieChartDataEntry(value: Double("\(total)")!, label: itemTitle))
                                                        self.pieChart.entryLabelColor = .clear
                                                        
                                                        let set = PieChartDataSet(entries: pieChartData)
                                                        set.colors = ChartColorTemplates.pastel()
                                                        set.entryLabelFont = .systemFont(ofSize: 11)
                                                        let data = PieChartData(dataSet: set)
                                                        self.pieChart.data = data
                                                        self.pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    
                }
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }

    @IBAction func itemTypeButtonPressed(_ sender: UIButton) {
        itemTypeMenu.show()
    }
    
    @IBAction func itemButtonPressed(_ sender: UIButton) {
        itemMenu.show()
        
    }
    
    @IBAction func weeklyButtonPressed(_ sender: MDCButton) {
        self.time = "Weekly"
        itemTypeMenu.dataSource = ["Cater Items", "Personal Chef Items", "MealKit Items"]
        if itemTypeText.text == "All" {
            itemTypeText.text = ""
        }
        weeklyBarChart.isHidden = false
        monthlyBarChart.isHidden = true
        pieChart.isHidden = true
        itemText.isHidden = false
        
        if itemTypeText.text != "" && itemText.text != "" {
            loadItemWeeklyData(itemTitle: itemText.text!)
        }
        
        weeklyButton.setTitleColor(UIColor.white, for: .normal)
        weeklyButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        monthlyButton.backgroundColor = UIColor.white
        monthlyButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        totalButton.backgroundColor = UIColor.white
        totalButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        
    }
    
    @IBAction func monthlyButtonPressed(_ sender: MDCButton) {
        self.time = "Monthly"
        itemTypeMenu.dataSource = ["Cater Items", "Personal Chef Items", "MealKit Items"]
        if itemTypeText.text == "All" {
            itemTypeText.text = ""
        }
        
        weeklyBarChart.isHidden = true
        monthlyBarChart.isHidden = false
        pieChart.isHidden = true
        itemText.isHidden = false
        
        if itemTypeText.text != "" && itemText.text != "" {
            loadItemMonthlyData(itemTitle: itemText.text!)
        }
        
        weeklyButton.backgroundColor = UIColor.white
        weeklyButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        monthlyButton.setTitleColor(UIColor.white, for: .normal)
        monthlyButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        totalButton.backgroundColor = UIColor.white
        totalButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func totalButtonPressed(_ sender: MDCButton) {
        self.time = "Yearly"
        itemTypeMenu.dataSource = ["All", "Cater Items", "Personal Chef Items", "MealKit Items"]
        
        itemText.isHidden = true
        weeklyBarChart.isHidden = true
        monthlyBarChart.isHidden = true
        pieChart.isHidden = false
        
        if itemTypeText.text != "" {
            loadItemYearlyData(itemTitle: itemTypeText.text!)
        }
        
        weeklyButton.backgroundColor = UIColor.white
        weeklyButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        monthlyButton.backgroundColor = UIColor.white
        monthlyButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        totalButton.setTitleColor(UIColor.white, for: .normal)
        totalButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
    }
   
    @IBAction func notificationsButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Notifications") as? NotificationsViewController {
            vc.chefOrUser = "Chef"
            self.present(vc, animated: true, completion: nil)
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

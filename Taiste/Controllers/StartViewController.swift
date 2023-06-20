//
//  ViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/23/22.
//

import UIKit
import Firebase
import FirebaseAuth
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming


class StartViewController: UIViewController {
    
    let date = Date()
    let df = DateFormatter()
    
    
    @IBOutlet weak var termsOfSErviceText: UILabel!
    
    @IBOutlet weak var userButton: MDCButton!
    @IBOutlet weak var chefButton: MDCButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        userButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        chefButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        userButton.layer.cornerRadius = 2
        chefButton.layer.cornerRadius = 2
        
        
        
        
        var normalText = "Please review our "
        var boldText  = "Terms of Service"
        
        var secondNormalText = " and "
        var secondBoldText = "Privacy Policy"
        var thirdNormalText = " before continuing."

        var attributedString = NSMutableAttributedString(string:normalText)

        var attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13)]
        
        var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
        
        var secondAttributedString = NSMutableAttributedString(string:secondNormalText)
        
        var secondBoldString = NSMutableAttributedString(string: secondBoldText, attributes:attrs)
        
        var thirdAttributedString = NSMutableAttributedString(string:thirdNormalText)
        

        
        attributedString.append(boldString)
        attributedString.append(secondAttributedString)
        attributedString.append(secondBoldString)
        attributedString.append(thirdAttributedString)
        
        termsOfSErviceText.attributedText = attributedString
      
        print("date \(Date().startOfWeek)")
        print("date \(Date().getWeekDates().thisWeek)")
        print("date \(Int(Date().timeIntervalSince1970))")
        df.dateFormat = "yyyy-MM-dd"
        
        let x = df.date(from: "2023-01-05")
        print("datesss \(x!.getWeekDates().thisWeek)")
        
        let dateString = df.string(from: date)
        let year = dateString.prefix(4)
        let month = dateString.prefix(7).suffix(2)
        
        
//        print("date \(year), \(month)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let vc : UITabBarController = UserTabViewController()
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser!.displayName! == "User" {
                //your view controller
                self.performSegue(withIdentifier: "StartToUserTabSegue", sender: self)
            } else {
                self.performSegue(withIdentifier: "StartToChefTabSegue", sender: self)
            }
            }
        }else{
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
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




func globalContainerScheme() -> MDCContainerScheming {
  let containerScheme = MDCContainerScheme()
  // Customize containerScheme here...
    let colorScheme = MDCSemanticColorScheme(defaults: .material201804)
    colorScheme.primaryColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
    colorScheme.secondaryColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
    containerScheme.colorScheme = colorScheme
    
  return containerScheme
}

func secondGlobalContainerScheme() -> MDCContainerScheming {
  let containerScheme = MDCContainerScheme()
  // Customize containerScheme here...
    let colorScheme = MDCSemanticColorScheme(defaults: .material201804)
    colorScheme.primaryColor = UIColor.red
    colorScheme.secondaryColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
    containerScheme.colorScheme = colorScheme
    
  return containerScheme
}



//
//  LoginViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/24/22.
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
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailText: MDCOutlinedTextField!
    @IBOutlet weak var passwordText: MDCOutlinedTextField!
    
    @IBOutlet weak var loginButton: MDCButton!
    @IBOutlet weak var signUpButton: MDCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
        emailText.setOutlineColor(UIColor.systemGray4, for: .normal)
        emailText.setOutlineColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        emailText.setTextColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        emailText.setTextColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)

        emailText.setNormalLabelColor(UIColor.systemGray4, for: .normal)
        emailText.setFloatingLabelColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)

        passwordText.setOutlineColor(UIColor.lightGray, for: .normal)
        passwordText.setOutlineColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)
        passwordText.setTextColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        passwordText.setTextColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)

        passwordText.setNormalLabelColor(UIColor.systemGray4, for: .normal)
        passwordText.setFloatingLabelColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .editing)

        emailText.label.text = "Email"
        emailText.placeholder = "Email"

        loginButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        loginButton.layer.cornerRadius = 2

        passwordText.label.text = "Password"
        passwordText.placeholder = "Password"
       
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if emailText.text!.isEmpty || passwordText.text!.isEmpty {
            showToast(message: "Please enter your email and password in the allotted fields.", font: .systemFont(ofSize: 12))
        } else {
        Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
          // ...
            
            self!.performSegue(withIdentifier: "LoginToUserTabSegue", sender: self)
        }
        }
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: MDCButton) {
        
//        self.performSegue(withIdentifier: "LoginToUserSignUpSegue", sender: self)
    }
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height-180, width: (self.view.frame.width), height: 50))
        toastLabel.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
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


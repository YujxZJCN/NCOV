//
//  SignUpViewController.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/13.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class SignUpViewController: UIViewController {
    
    @IBOutlet var photoImageView: UIImageView! {
        didSet {
            self.photoImageView.clipsToBounds = false
            self.photoImageView.layer.cornerRadius = self.photoImageView.frame.height / 2
        }
    }
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var signupButton: UIButton! {
        didSet {
            self.signupButton.clipsToBounds = false
            self.signupButton.layer.cornerRadius = self.signupButton.frame.height / 2
        }
    }
    
    @IBOutlet var containerView: UIView! {
        didSet {
            self.containerView.clipsToBounds = false
            self.containerView.layer.cornerRadius = 23.0
        }
    }
    @IBOutlet var switchPasswordTextFieldButton: UIButton!
    
    // 0: password, 1: none
    var passwordTextFieldContentType = 0
    
    var signUpURL = "http://www.newnan.city:2020/api/regist/"
    
    @IBAction func switchPasswordTextField(_ sender: UIButton) {
        if passwordTextFieldContentType == 0 {
            passwordTextField.isSecureTextEntry = false
            passwordTextFieldContentType = 1
            switchPasswordTextFieldButton.setImage(UIImage(named: "eye"), for: .normal)
        } else {
            passwordTextField.isSecureTextEntry = true
            passwordTextFieldContentType = 0
            switchPasswordTextFieldButton.setImage(UIImage(named: "eye-invisible"), for: .normal)
        }
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let salt = 6.salt
        let hashed_passwd = (password + salt).MD5String
        
        if email == "" || username == "" || password == "" {
            return
        }
        
        let headers: HTTPHeaders = ["Content-Type" : "application/x-www-form-urlencoded"]
        let parameters: Parameters = ["email" : email,
                                      "nickname" : username,
                                      "salt" : salt,
                                      "hashed_passwd" : hashed_passwd
                                    ]
        Alamofire.request(signUpURL, method: .post, parameters: parameters, headers: headers).responseData { (response) in
            if let html = response.result.value, let doc = try? HTML(html: html, encoding: .utf8) {
                print(doc.content)
                if let content = doc.content {
                    if content == "注册通过，请检查邮箱" {
                        self.sendMessage(title: "注册通过，请检查邮箱", details: "需通过邮箱验证之后，才能登录。", turnOnSetting: false, needDismiss: true)
                    } else if content.contains("IntegrityError") {
                        self.sendMessage(title: "邮箱重复", details: "", turnOnSetting: false, needDismiss: false)
                    }
                }
            } else {
                print("Error")
            }
        }
    }
    
    func sendMessage(title: String, details: String, turnOnSetting: Bool, needDismiss: Bool) {
        let alertMessage = UIAlertController(title: title, message: details, preferredStyle: .alert)
        
        if turnOnSetting {
            let settingButton = UIAlertAction(title: NSLocalizedString("Go to settings", comment: "Go to settings"), style: .default) { ACTION in
                guard let settingURL = URL(string: UIApplication.openSettingsURLString) else {
                    // Handling errors that should not happen here
                    fatalError("Error!")
                }
                let app = UIApplication.shared
                app.open(settingURL)
                
                self.dismiss(animated: true, completion: nil)
            }
            alertMessage.addAction(settingButton)
            alertMessage.preferredAction = settingButton
        }
        
        let OKButton = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { ACTION in
            if needDismiss {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertMessage.addAction(OKButton)
        
        if !turnOnSetting { alertMessage.preferredAction = OKButton }
        
        present(alertMessage, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // dismiss keyboard
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}

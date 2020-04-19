//
//  ViewController.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/13.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import Kanna
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG
import ExternalAccessory

var LOGIN = false

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet var loginButton: UIButton! {
        didSet {
            self.loginButton.clipsToBounds = false
            self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2
        }
    }
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var switchPasswordTextFieldButton: UIButton!
    
    @IBOutlet var containerView: UIView! {
        didSet {
            self.containerView.clipsToBounds = false
            self.containerView.layer.cornerRadius = 23.0
        }
    }
    
    // 0: password, 1: none
    var passwordTextFieldContentType = 0
    
    var getSaltURL = "http://www.newnan.city:2020/api/querySA/"
    var loginURL = "http://www.newnan.city:2020/api/login/"
    
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
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        if email == "" || password == "" {
            return
        }
        
        let headers: HTTPHeaders = ["Content-Type" : "application/x-www-form-urlencoded"]
        
        let getSaltParameters: Parameters = ["email" : email]
        
        Alamofire.request(getSaltURL, method: .get, parameters: getSaltParameters, headers: headers).responseData { (response) in
            if let salt = response.response?.allHeaderFields["salt"] as? String, let uuid = UIDevice.current.identifierForVendor?.uuidString.components(separatedBy: "-").last {
                let hashed_passwd = (password + salt).MD5String
                let parameters: Parameters = ["email" : email,
                                              "hashed_passwd" : hashed_passwd,
                                              "mac" : uuid
                                            ]
                Alamofire.request(self.loginURL, method: .post, parameters: parameters, headers: headers).responseData { (response) in
                    if let html = response.result.value, let doc = try? HTML(html: html, encoding: .utf8) {
                        if let content = doc.content {
                            if content == "密码错误" {
                                self.sendMessage(title: "密码错误", details: "", turnOnSetting: false, needDismiss: false)
                            } else if content == "登录成功" {
                                self.sendMessage(title: "登录成功", details: "", turnOnSetting: false, needDismiss: true)
                                LOGIN = true
                                UserDefaults.standard.set(1, forKey: "LOGIN")
                                UserDefaults.standard.set(email, forKey: "EMAIL")
                            } else {
                                self.sendMessage(title: "邮箱不存在", details: "", turnOnSetting: false, needDismiss: false)
                            }
                        }
                    } else {
                        print("Error")
                    }
                }
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
    
    @IBAction func signUp(_ sender: UIButton) {
        let sectionController = self.storyboard?.instantiateViewController(withIdentifier: "registerPageVC") as! SignUpViewController
        sectionController.modalPresentationStyle = .fullScreen
        self.present(sectionController, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // dismiss keyboard
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}

extension String {
    var MD5String: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Int {
    var salt: String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<self).map{ _ in letters.randomElement()! })
    }
}

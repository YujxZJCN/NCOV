//
//  DetailViewController.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/16.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SwiftyJSON

class DetailViewController: UIViewController {
    @IBOutlet var containerView: UIView! {
        didSet {
            self.containerView.clipsToBounds = true
            self.containerView.layer.cornerRadius = 23.0
        }
    }
    
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var QQTextField: UITextField!
    @IBOutlet var wechatTextField: UITextField!
    
    let getUserInfoURL = "http://www.newnan.city:2020/api/getUser/"
    let updateUserInfoURL = "http://www.newnan.city:2020/api/updateUser/"
    let email = UserDefaults.standard.string(forKey: "EMAIL")
    
    
    @IBOutlet var saveButton: UIButton! {
        didSet {
            self.saveButton.clipsToBounds = true
            self.saveButton.layer.cornerRadius = self.saveButton.frame.height / 2
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let phone = phoneTextField.text ?? ""
        let QQ = QQTextField.text ?? ""
        let wechat = wechatTextField.text ?? ""
        
        let infoJSON = JSON(["phone" : phone, "qq" : QQ, "wechat" : wechat])
        if let uuid = UIDevice.current.identifierForVendor?.uuidString.components(separatedBy: "-").last, let email = email {
            print(uuid)
            let parameters: Parameters = ["email" : email,
                                          "mac" : uuid,
                                          "updateJSON" : infoJSON
                                        ]
            Alamofire.request(self.updateUserInfoURL, method: .post, parameters: parameters).responseData { (response) in
                if let html = response.result.value, let doc = try? HTML(html: html, encoding: .utf8) {
                    if let content = doc.content, content == "用户信息修改成功" {
                        self.sendMessage(title: "修改成功", details: "", turnOnSetting: false, needDismiss: false)
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let uuid = UIDevice.current.identifierForVendor?.uuidString.components(separatedBy: "-").last, let email = email {
            let parameters: Parameters = ["email" : email,
                                          "mac" : uuid
            ]
            
            Alamofire.request(self.getUserInfoURL, method: .get, parameters: parameters).responseData { (response) in
                if let data = response.data {
                    let infoJSON = JSON(data)
                    self.phoneTextField.text = infoJSON["phone"].stringValue
                    self.QQTextField.text = infoJSON["qq"].stringValue
                    self.wechatTextField.text = infoJSON["wechat"].stringValue
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.phoneTextField.resignFirstResponder()
        self.QQTextField.resignFirstResponder()
        self.wechatTextField.resignFirstResponder()
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

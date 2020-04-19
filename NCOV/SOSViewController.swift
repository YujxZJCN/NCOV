//
//  SOSViewController.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/16.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit

class SOSViewController: UIViewController {

    @IBOutlet var SOSButton: UIButton! {
        didSet {
            self.SOSButton.clipsToBounds = true
            self.SOSButton.layer.cornerRadius = self.SOSButton.frame.height / 2
        }
    }
    
    @IBAction func SOSButtonTapped(_ sender: UIButton) {
        self.sendMessage(title: "0086-10-12308", details: "", turnOnSetting: false, needDismiss: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.sendMessage(title: "0086-10-12308", details: "", turnOnSetting: false, needDismiss: false)
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
        let callButton = UIAlertAction(title: NSLocalizedString("Call", comment: "Call"), style: .default) { ACTION in
            alertMessage.title!.makeACall()
        }
        let OKButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .default) { ACTION in
            if needDismiss {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertMessage.addAction(callButton)
        alertMessage.addAction(OKButton)
        
        if !turnOnSetting { alertMessage.preferredAction = callButton }
        
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

extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool { return isValid(regex: regex.rawValue) }
    func isValid(regex: String) -> Bool { return range(of: regex, options: .regularExpression) != nil }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeACall() {
        guard   isValid(regex: .phone),
            let url = URL(string: "tel://\(self.onlyDigits())"),
            UIApplication.shared.canOpenURL(url) else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

//
//  ViewController.swift
//  FireChat
//
//  Created by Wojciech Karaś on 06/02/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit
import Firebase

class RegisterLogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        emailTextField.delegate = self
        emailTextField.becomeFirstResponder()
        passwordTextField.delegate = self
    }

    @IBAction func registerButtonTapped(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            result, error in
            if let error = error {
                self.setAlert(text: error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "chatSegue", sender: self)
            }
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            user, error in
            if let error = error {
                self.setAlert(text: error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "chatSegue", sender: self)
            }
        }
    }
    
    private func setAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - TextField Methods
extension RegisterLogInViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let oldText = textField.text {
            if let stringRange = Range(range, in: oldText) {
                let newText = oldText.replacingCharacters(in: stringRange, with: string)
                if textField === emailTextField {
                    logInButton.isEnabled = !newText.isEmpty && !(passwordTextField.text ?? "").isEmpty
                    registerButton.isEnabled = logInButton.isEnabled
                } else if textField === passwordTextField {
                    logInButton.isEnabled = !newText.isEmpty && !(emailTextField.text ?? "").isEmpty
                    registerButton.isEnabled = logInButton.isEnabled
                }
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

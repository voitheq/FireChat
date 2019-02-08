//
//  ChatViewController.swift
//  FireChat
//
//  Created by Wojciech Karaś on 06/02/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit
import Firebase

enum Keys: String {
    case messages
    case sender
    case text
}

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTextFieldContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    private var messageTextFieldContainerHeightConstraintConstant: CGFloat?
    
    var messages = [Message]()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextFieldContainerHeightConstraintConstant = messageTextFieldContainerHeightConstraint.constant
        
        tableView.register(UINib(nibName: "CurrentUserTableViewCell", bundle: nil), forCellReuseIdentifier: "currentUserCell")
        tableView.register(UINib(nibName: "OtherUserTableViewCell", bundle: nil), forCellReuseIdentifier: "otherUserCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 103
        tableView.separatorStyle = .none
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        messageTextField.delegate = self
        retrieveMessages()
    }
    
    private func retrieveMessages() {
        let messages = Database.database().reference().child(Keys.messages.rawValue)
        messages.observe(.childAdded) {
            snapshot in
            if let snapshotValue = snapshot.value as? [String: String] {
                if let sender = snapshotValue[Keys.sender.rawValue], let text = snapshotValue[Keys.text.rawValue] {
                    let message = Message()
                    message.sender = sender
                    message.text = text
                    self.messages.append(message)
                    self.tableView.reloadData()
                    self.scrollTableViewToLastRow()
                }
            }
        }
    }
    
    private func scrollTableViewToLastRow() {
        let lastSection = tableView.numberOfSections - 1
        if lastSection >= 0 {
            let lastRow = tableView.numberOfRows(inSection: lastSection) - 1
            if lastRow >= 0 {
                tableView.scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .bottom, animated: true)
            }
        }
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("error")
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        let messages = Database.database().reference().child(Keys.messages.rawValue)
        let message = [Keys.sender.rawValue: Auth.auth().currentUser?.email, Keys.text.rawValue: messageTextField.text]
        messages.childByAutoId().setValue(message) {
            error, reference in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.messageTextField.text = ""
                self.messageTextField.isEnabled = true
            }
        }
    }
    
}

//MARK: - TableView Methods
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        if messages[indexPath.row].sender == Auth.auth().currentUser?.email {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currentUserCell",
                                                     for: indexPath) as! CurrentUserTableViewCell
            cell.messageTextLabel.text = messages[indexPath.row].text
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "otherUserCell",
                                                     for: indexPath) as! OtherUserTableViewCell
            cell.messageTextLabel.text = messages[indexPath.row].text
            cell.emailTextLabel.text = messages[indexPath.row].sender
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - TextField Methods
extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let oldText = textField.text {
            if let stringRange = Range(range, in: oldText) {
                let newText = oldText.replacingCharacters(in: stringRange, with: string)
                sendButton.isEnabled = !newText.isEmpty
            }
        }
        return true
    }
}

//MARK: - Keyboard Methods
extension ChatViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
                    if let duration = animationDuration as? TimeInterval {
                        self.messageTextFieldContainerHeightConstraint.constant = messageTextFieldContainerHeightConstraintConstant! + keyboardFrameEnd.height
                        UIView.animate(withDuration: duration) {
                            self.view.layoutIfNeeded()
                        }
                        scrollTableViewToLastRow()
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
                if let duration = animationDuration as? TimeInterval {
                    self.messageTextFieldContainerHeightConstraint.constant = messageTextFieldContainerHeightConstraintConstant!
                    UIView.animate(withDuration: duration) {
                        self.view.layoutIfNeeded()
                    }
                    scrollTableViewToLastRow()
                }
            }

        }
    }
}

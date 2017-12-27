//
//  LoginViewController.swift
//  SNS-Realtime
//
//  Created by Icaro Barreira Lavrador on 11/10/15.
//  Copyright © 2015 Icaro Barreira Lavrador. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  
  var firebase = Firebase(url: "https://two-ios.firebaseio.com")
  var username = String()
  var newUser = false
  @IBOutlet weak var emailTextfield: UITextField!
  @IBOutlet weak var passwordTextfield: UITextField!
  
  
  @IBAction func LoginButton(sender: UIButton) {
    logUser()
  }
  
  @IBAction func Signup(sender: UIButton) {
    if checkFields(){
      firebase?.createUser(emailTextfield.text, password: passwordTextfield.text, withCompletionBlock: { [weak self] error in
        guard let strongSelf = self else {
          return
        }
        if let error = error {
          print(error.localizedDescription)
          strongSelf.displayMessage(error: error as NSError)
        } else {
          print("New user created")
          strongSelf.requestUsername()
        }
      })
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    emailTextfield.text = ""
    passwordTextfield.text = ""
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if firebase?.authData != nil{
      self.retriveUserName()
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func logUser(){
    if checkFields(){
      print("Start loggin user")
      firebase?.authUser(emailTextfield.text, password: passwordTextfield.text, withCompletionBlock: { [weak self](error, authData) in
        guard let strongSelf = self, let authData = authData else {
          return
        }
        
        if let error = error {
          print(error.localizedDescription)
          strongSelf.displayMessage(error: error as NSError)
        } else{
          print("user logged \(authData.description)")
          let uid = authData.uid
          if strongSelf.newUser {
            strongSelf.firebase?.child(byAppendingPath: "users").child(byAppendingPath: uid).setValue(["isOnline":true, "name":strongSelf.username])
            strongSelf.performSegue(withIdentifier: "segueJSQ", sender: self)
          } else {
            strongSelf.firebase?.child(byAppendingPath: "users").child(byAppendingPath: uid).updateChildValues(["isOnline":true])
            strongSelf.retriveUserName()
          }
        }
      })
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "segueJSQ"{
      let uid = self.firebase?.authData.uid
      if let viewController = segue.destination as? JSQViewController{
        firebase?.child(byAppendingPath: "users").child(byAppendingPath: uid).updateChildValues(["isOnline":true])
        viewController.senderId = uid
        viewController.senderDisplayName = self.username
      }
    }
  }
  
  func retriveUserName(){
    self.firebase?.child(byAppendingPath: "users").child(byAppendingPath: firebase?.authData.uid).observeSingleEvent(of: .value) { (snapshot: FDataSnapshot!) -> Void in
      self.username = (snapshot.value as! NSDictionary)["name"] as! String
      self.performSegue(withIdentifier: "segueJSQ", sender: self)
    }
  }
  
  func checkFields()->Bool{
    if ((!emailTextfield.text!.isEmpty) && (!passwordTextfield.text!.isEmpty)){
      return true
    } else{
      print("Empty field was found")
      return false
    }
  }
  
  func displayMessage(error:NSError){
    let titleMessage = "Error"
    let alert = UIAlertController(title: titleMessage, message: error.localizedDescription, preferredStyle: .alert)
    let actionOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alert.addAction(actionOk)
    self.present(alert, animated: true, completion: nil)
  }
  
  func requestUsername(){
    var usernameTextfield: UITextField?
    let titleMessage = "Enter a Username"
    let bodyMessage = "Please enter a username for your new account:"
    let usernameEntry = UIAlertController(title: titleMessage, message: bodyMessage, preferredStyle: .alert)
    let actionOk = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) -> Void in
      if let user = usernameTextfield?.text{
        print(user)
        self.username = user
        self.newUser = true
        self.logUser()
      }
    }
    usernameEntry.addAction(actionOk)
    usernameEntry.addTextField { (username:UITextField) -> Void in
      usernameTextfield = username
    }
    self.present(usernameEntry, animated: true, completion: nil)
  }
}

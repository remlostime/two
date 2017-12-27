//
//  LoginViewController.swift
//  Two
//
//  Created by Kai Chen on 12/20/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {
  
  @IBOutlet weak var usernameTextField: UITextField!
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  var handle: AuthStateDidChangeListenerHandle?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().signInSilently()
    handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
      if user != nil {
//        self.performSegue(withIdentifier: "", sender: nil)
        print("ok")
      }
    }
  }
  
  deinit {
    if let handle = handle {
      Auth.auth().removeStateDidChangeListener(handle)
    }
  }
  
  // MARK: Actions
  
  @IBAction func loginButtonTapped(_ sender: UIButton) {
  }
  
  @IBAction func registerButtonTapped(_ sender: UIButton) {
  }
  
}

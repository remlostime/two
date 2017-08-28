//
//  ViewController.swift
//  Two
//
//  Created by Kai Chen on 8/20/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

  lazy var ref: DatabaseReference = Database.database().reference()

  @IBOutlet weak var textField: UITextField!

  @IBAction func sendButtonTapped(_ sender: UIButton) {
    guard let name = textField.text else {
      return
    }

    ref.child("name").setValue(name)
    ref.child("online").setValue("true")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref.setValue("App Started")
    
    ref.observe(DataEventType.value, with: { (snapshot: DataSnapshot) in
      print(snapshot.value)
    })
  }
}


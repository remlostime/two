//
//  ViewController.swift
//  Two
//
//  Created by Kai Chen on 8/20/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
  
  lazy var ref: DatabaseReference = Database.database().reference()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref.setValue("App Started")
    
    ref.observe(DataEventType.value, with: { (snapshot: DataSnapshot) in
      print(snapshot.value)
    })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}


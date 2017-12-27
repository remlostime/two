//
//  MessageViewController.swift
//  SNS-Realtime
//
//  Created by Icaro Barreira Lavrador on 1/02/16.
//  Copyright © 2016 Icaro Barreira Lavrador. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
  
  var onMessageAvailable : ((_ data: String) -> ())?
  
  @IBOutlet weak var message: UITextField!
  
  @IBAction func sendMessage(sender: AnyObject) {
    onMessageAvailable!(message.text!)
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func cancelMessage(sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

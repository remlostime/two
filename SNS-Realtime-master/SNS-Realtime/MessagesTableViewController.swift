//
//  MessagesTableViewController.swift
//  SNS-Realtime
//
//  Created by Icaro Barreira Lavrador on 9/11/15.
//  Copyright © 2015 Icaro Barreira Lavrador. All rights reserved.
//

import UIKit

struct User {
  let uid: String?
  let name: String?
}

class MessagesTableViewController: UITableViewController {
  
  var firebase = Firebase(url: "https://two-ios.firebaseio.com/")
  var childAddedHandler = FirebaseHandle()
  var listOfMessages = NSMutableDictionary()
  
  let uid = ""
  
  @IBAction func logout(sender: AnyObject) {
    firebase?.unauth()
    self.dismiss(animated: true, completion: nil)
  }
  @IBAction func addMesssage(sender: AnyObject) {
    
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    /*
    childAddedHandler = firebase?.child(byAppendingPath: "posts").observe(.value, with: { [weak self] snapshot in
      guard let snapshot = snapshot else {
        return
      }
      self?.firebaseUpdate(snapshot: snapshot)
    })
    
    childAddedHandler = firebase?.observe(.childChanged, with: { [weak self] snapshot in
      guard let snapshot = snapshot else {
        return
      }
      self?.firebaseUpdate(snapshot: snapshot)
    })
  */
  }
  
  func firebaseUpdate(snapshot: FDataSnapshot){
    if let newMessages = snapshot.value as? NSDictionary{
      print(newMessages)
      for newMessage in newMessages{
        let key = newMessage.key as! String
        let messageExist = (self.listOfMessages[key] != nil)
        if !messageExist{
          self.listOfMessages.setValue(newMessage.value, forKey: key)
        }
      }
    }
    
    DispatchQueue.main.async { [unowned self] in
      self.tableView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listOfMessages.count
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let messageController = segue.destination as? MessageViewController {
      messageController.onMessageAvailable = {[weak self]
        (data) in
        if let weakSelf = self {
          weakSelf.receiveMessageToSend(message: data)
        }
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
    let arrayOfKeys = listOfMessages.allKeys
    let key = arrayOfKeys[indexPath.row]
    let value = listOfMessages[key as! String]
    cell.textLabel?.text = (value as! NSDictionary)["message"] as? String
    return cell
  }
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
   if editingStyle == .Delete {
   // Delete the row from the data source
   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
   } else if editingStyle == .Insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
  func receiveMessageToSend(message:String){
    self.firebase?.child(byAppendingPath: "posts").childByAutoId().setValue(["message":message, "sender":firebase?.authData.uid])
  }
  
}

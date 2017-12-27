//
//  JSQViewController.swift
//  SNS-Realtime
//
//  Created by Icaro Barreira Lavrador on 11/02/16.
//  Copyright © 2016 Icaro Barreira Lavrador. All rights reserved.
//

import UIKit

class JSQViewController: JSQMessagesViewController {
  
  var incomingBubble: JSQMessagesBubbleImage!
  var outgoingBubble: JSQMessagesBubbleImage!
  
  var avatars = [String:JSQMessagesAvatarImage]()
  
  var messages = [JSQMessage]()
  var keys = [String]()
  
  var imageToSend: UIImage?
  
  let firebase = Firebase(url: "https://two-ios.firebaseio.com")
  var userConnection = Firebase()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectUsers()
    setup()
    
  }
  
  func setupCollectUsers(){
    firebase?.child(byAppendingPath: "users").observeSingleEvent(of: FEventType.value) { (snapshot:FDataSnapshot!) -> Void in
      print("Single -> \(snapshot)")
    }
    firebase?.child(byAppendingPath: "users").observeSingleEvent(of: FEventType.childChanged) { (snapshot:FDataSnapshot!) -> Void in
      print("Observer -> \(snapshot)")
    }
  }
  
  func setup(){
    userConnection = Firebase(url: "https://two-ios.firebaseio.com/users/\(senderId)/isOnline")
    userConnection.onDisconnectSetValue("false")
    //Old code we now are going to use the Accesory Button
    //self.inputToolbar?.contentView?.leftBarButtonItem?.hidden = true
    //self.inputToolbar?.contentView?.leftBarButtonItemWidth = 0
    
    let bubbleFactory = JSQMessagesBubbleImageFactory()
    incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    createAvatar(senderId: senderId, senderDisplayName: senderDisplayName, color: UIColor.lightGray)
    
    firebase?.child(byAppendingPath: "JSQNode").queryLimited(toLast: 50).queryOrdered(byChild: "date").observeSingleEvent(of: FEventType.value) { (snapshot:FDataSnapshot!) -> Void in
      if let values = snapshot.value as? NSDictionary{
        for value in values{
          if !self.keys.contains(snapshot.key){
            self.keys.append(value.key as! String)
            
            if let message = value.value as? NSDictionary{
              let date = message["date"] as! TimeInterval
              let receiveSenderID = message["senderId"] as! String
              let receiveDisplayName = message["senderDisplayName"] as! String
              self.createAvatar(senderId: receiveSenderID, senderDisplayName: receiveDisplayName, color: UIColor.jsq_messageBubbleGreen())
              if let jsqMessage = JSQMessage(senderId: receiveSenderID, senderDisplayName: receiveDisplayName, date: NSDate(timeIntervalSince1970: date) as Date!, text: message["message"] as! String) {
                self.messages.append(jsqMessage)
              }
            }
          }
        }
        self.messages.sort(by: { ($0.date.compare($1.date) == ComparisonResult.orderedAscending)})
        self.finishReceivingMessage(animated: true)
      }
    }
    
    firebase?.child(byAppendingPath: "JSQNode").queryLimited(toLast: 1).observe(.childAdded) { (snapshot:FDataSnapshot!) -> Void in
      if !self.keys.contains(snapshot.key){
        self.keys.append(snapshot.key)
        if let message = snapshot.value as? NSDictionary{
          let date = message["date"] as! TimeInterval
          let receiveSenderID = message["senderId"] as! String
          let receiveDisplayName = message["senderDisplayName"] as! String
          self.createAvatar(senderId: receiveSenderID, senderDisplayName: receiveDisplayName, color: UIColor.jsq_messageBubbleGreen())
          if let jsqMessage = JSQMessage(senderId: receiveSenderID, senderDisplayName: receiveDisplayName, date: NSDate(timeIntervalSince1970: date) as Date!, text: message["message"] as! String) {
            self.messages.append(jsqMessage)
          }
          if receiveSenderID != self.senderId{
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
          }
        }
        self.finishReceivingMessage(animated: true)
      }
    }
  }
  
  func createAvatar(senderId: String, senderDisplayName: String, color: UIColor){
    if avatars[senderId] == nil{
      let endIndex = senderDisplayName.index(senderDisplayName.startIndex, offsetBy: min(2, senderDisplayName.characters.count))
      let initials = String(senderDisplayName[senderDisplayName.startIndex..<endIndex])
      let avatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials, backgroundColor: color, textColor: UIColor.black, font: UIFont.systemFont(ofSize: 14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
      avatars[senderId] = avatar
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    //let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
    firebase?.child(byAppendingPath: "JSQNode").childByAutoId().setValue(["message":text, "senderId":senderId, "senderDisplayName":senderDisplayName, "date":date.timeIntervalSince1970, "messageType":"txt"])
    //messages.append(message)
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    finishSendingMessage()
  }
  
  //MARK - Delegates
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return messages[indexPath.row]
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = messages[indexPath.row]
    
    if message.senderId == senderId{
      return outgoingBubble
    }
    return incomingBubble
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    let message = messages[indexPath.row]
    
    return avatars[message.senderId]
  }

  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
    let message = messages[indexPath.row]
    if indexPath.row <= 1 {
      return NSAttributedString(string: message.senderDisplayName)
    }
    
    return nil
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    
    let message = messages[indexPath.row]
    if message.senderId == senderId{
      cell.textView?.textColor = UIColor.black
    } else{
      cell.textView?.textColor = UIColor.white
    }
    
    cell.textView?.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue:(cell.textView?.textColor)!]
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return messages.count
  }
  
  //MARK: -Send Image
  
  override func didPressAccessoryButton(_ sender: UIButton!) {
    let alertController = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
    let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alertAction: UIAlertAction) in
      self.getImageFrom(source: .camera)
    }
    let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (alertAction: UIAlertAction) in
      self.getImageFrom(source: .photoLibrary)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction: UIAlertAction) in
      print("Selected Cancel")
    }
    
    alertController.addAction(cameraAction)
    alertController.addAction(galleryAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  func getImageFrom(source: UIImagePickerControllerSourceType){
    if UIImagePickerController.isSourceTypeAvailable(source){
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.modalPresentationStyle = .currentContext
      imagePicker.sourceType  = source
      imagePicker.allowsEditing = false
      if (source == .camera){
        imagePicker.cameraDevice = .rear
      }
      self.present(imagePicker, animated: true, completion: nil)
    } else{
      print("The selected source is not avaliable in this device")
    }
  }
}

extension JSQViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismissPicker(picker: picker)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    if (picker.sourceType == .camera || picker.sourceType == .photoLibrary){
      imageToSend = ImageHelper.resizeImage(image: image)
    }
    dismissPicker(picker: picker)
  }
  
  
  func dismissPicker(picker: UIImagePickerController){
    picker.dismiss(animated: true, completion: nil)
    picker.delegate = nil
  }
  
  
}







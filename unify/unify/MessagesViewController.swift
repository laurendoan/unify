//
//  MessagesViewController.swift
//  unify
//
//  Created by David Do on 3/26/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class MessagesViewController: JSQMessagesViewController {
    var className = "" // Course name.
    var classID = "" // Course title.
    
    var messages = [JSQMessage]()
    
    var databaseClass = Constants.refs.databaseRoot.child("chats")
    
    // Creates bubble image for outgoing message.
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    // Creates bubble image for incoming message.
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the background color.
        UIColourScheme.instance.set(for:self)
        collectionView.backgroundColor = UIColor(red: 230/255, green: 241/255, blue: 253/255, alpha: 1)

        // Chat room database reference.
        databaseClass = Constants.refs.databaseChats.child(className)
        
        senderId = Auth.auth().currentUser!.uid
        senderDisplayName = ""
        
        // Get sender's display name from the database.
        let ref = Constants.refs.databaseUsers
        ref.child(senderId!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.senderDisplayName = value?["displayName"] as? String ?? ""
        }) { (error) in
            print(error.localizedDescription)
        }
        
        title = "\(classID)"
        
        // Removes file upload button and user avatars.
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // Queries databse for previous messages to populate chat.
        let query = databaseClass.queryLimited(toLast: 100)
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender_id"],
                let name        = data["name"],
                let text        = data["text"],
                !text.isEmpty
            {
                if let message = JSQMessage(senderId: id, displayName: name, text: text) {
                    self?.messages.append(message)
                    self?.finishReceivingMessage()
                }
            }
        })
    }
    
    // Shows the navigation bar when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    // Returns the message at the given index.
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    // Returns the number of messages.
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // Distinguishes outgoing vs. incoming bubble appearance.
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    // Does not show an avatar for senders.
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // Displays sender's name above message.
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    // Sets the spacing between message bubbles.
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    // Sends the message if the send button is pressed and stores to firebase.
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let ref = databaseClass.childByAutoId()
        let message = ["sender_id": senderId, "name": senderDisplayName, "text": text]
        ref.setValue(message)
        finishSendingMessage()
    }
}

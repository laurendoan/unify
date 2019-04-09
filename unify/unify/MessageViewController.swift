//
//  AppDelegate.swift
//  MessageKitTest
//
//  Created by Julian Ricky Moore on 4/2/19.
//  Copyright © 2019 JulianMoore. All rights reserved.
//

import UIKit
import MapKit
import MessageKit
import MessageInputBar
import Firebase

final class MessageViewController: MessagesViewController, NotesDelegate, BackDelegate {

   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var panelView = PanelViewController()
    
    var notesView = NotesViewController()
    
    var panelOut = false
    
    var panelState = -1 //-1: inside, 0: standard, 1: notes, ADD: 2: members
    
    var messageList: [Message] = []
    
    let refreshControl = UIRefreshControl()
    
    var className: String = ""
    var classID: String = ""
    var senderDisplayName: String?
    var sender : Sender? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title of chatroom.
        self.navigationController?.isNavigationBarHidden = false
        title = "\(classID)"
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.emojiMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.emojiMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.locationMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.locationMessageSizeCalculator.incomingAvatarSize = .zero
            layout.videoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.videoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
        }
        
        configureMessageCollectionView()
        configureMessageInputBar()
        loadMessages()
        setupPanel()
    }
    
    func setupPanel() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "=", style: .plain, target: self, action: #selector(togglePanel)) //first create a button for the panel
        
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "icons8-menu-26.png")
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        panelView = storyboard.instantiateViewController(withIdentifier: "PanelViewController") as! PanelViewController
        panelView.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
        
        panelView.tableView.rowHeight = 40
        panelView.tableView.frame = CGRect(x: 0, y: 100, width: 276, height: panelView.tableView.rowHeight * 5)
        
        //panelView.stackView.frame = CGRect(x: 0, y: 100, width: 276, height: 200)
        //panelView.stackView.alignment = .fill

        //panelView.muteLabel.frame = CGRect(x: panelView.stackView.frame.minX + 10, y: panelView.muteLabel.frame.minY, width: panelView.muteLabel.frame.width, height: panelView.muteLabel.frame.height)
        
        //panelView.muteSwitch.frame = CGRect(x: panelView.stackView.frame.maxX - 10 - panelView.muteSwitch.frame.width, y: panelView.muteSwitch.frame.minY, width: panelView.muteSwitch.frame.width, height: panelView.muteSwitch.frame.height)
        
        
        //panelView.dividerView.frame = CGRect(x: panelView.stackView.frame.minX + 10, y:45, width: 100, height: 10)

        //panelView.dividerView.frame = CGRect(x: 0, y: 99, width: panelView.stackView.frame.width, height: 1)
        //print(panelView.stackView.subviews.count)
        //print(panelView.stackView.subviews[0].frame)
        //panelView.stackView.subviews[1].frame = CGRect(x: 0, y: 64, width: 376, height: 64)
        //print(panelView.stackView.subviews[1].frame)
        //panelView.stackView.bringSubviewToFront(panelView.stackView.subviews[1])
        //panelView.dividerView.backgroundColor = UIColor.black
        
        //print(panelView.muteLabel.frame)
        //print(panelView.stackView.frame)
        //print(panelView.dividerView.frame)

        self.view.insertSubview(panelView.view, at: 0)
        self.view.bringSubviewToFront(panelView.view)
        
        panelView.delegate = self
        panelOut = false
        panelView.view.isHidden = true; //don't show it initially
        panelView.view.frame = CGRect(x: self.view.frame.width, y: panelView.view.frame.minY, width: panelView.view.frame.width, height: panelView.view.frame.height)
        
        notesView = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
        notesView.delegate = self
        notesView.view.frame = CGRect(x: self.view.frame.width/3, y: 50, width: self.view.frame.width*2/3, height: self.view.frame.height) //want it 1/3 of the way across the screen so it's coming from the right
        
        self.view.insertSubview(notesView.view, at: 0)
        //self.view.bringSubviewToFront(panelView.view)
        notesView.view.frame = CGRect(x: self.view.frame.width, y: notesView.view.frame.minY, width: notesView.view.frame.width, height: notesView.view.frame.height)
        notesView.noteCollectionView.frame = CGRect(x: 0, y: 100, width: 276, height:  notesView.noteCollectionView.frame.height)
        notesView.toolbar.frame = CGRect(x: 0, y: self.view.frame.height - notesView.toolbar.frame.height - 100, width: 276, height: notesView.toolbar.frame.height)
        notesView.className = classID
        notesView.navBar.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)!, width: notesView.navBar.frame.width, height: notesView.navBar.frame.height)
    }
    
    @objc func togglePanel() {
        if(panelOut == false) {
            if(panelState == -1) { //just pull up the normal class info
                panelView.view.isHidden = false
                panelOut = true
                panelState = 0
                UIView.animate(withDuration: 0.3, animations: {
                    //self.panelView.view.alpha = 1
                    self.panelView.view.frame = CGRect(x: self.view.frame.width/3, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height)
                }, completion:  nil)
            }
        }
        else {
            if(panelState == 0) {
                self.notesView.view.frame = CGRect(x: self.view.frame.width, y: self.notesView.view.frame.minY, width: self.notesView.view.frame.width, height: self.notesView.view.frame.height) //move panel back even though it's invisible
                UIView.animate(withDuration: 0.3, animations: {
                    //self.panelView.view.alpha = 0
                    self.panelView.view.frame = CGRect(x: self.view.frame.width, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height)
                    
                }, completion:  {
                    (value: Bool) in
                    self.panelView.view.isHidden = true
                    self.panelOut = false
                    self.panelState = -1
                })
            }
            else if(panelState == 1){
                self.panelView.view.frame = CGRect(x: self.view.frame.width, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height) //move panel back even though it's invisible
                UIView.animate(withDuration: 0.3, animations: {
                    //self.panelView.view.alpha = 0
                    self.notesView.view.frame = CGRect(x: self.view.frame.width, y: self.notesView.view.frame.minY, width: self.notesView.view.frame.width, height: self.notesView.view.frame.height)
                    
                }, completion:  {
                    (value: Bool) in
                    self.notesView.view.isHidden = true
                    self.panelOut = false
                    self.panelState = -1
                })
            }
        }
        
        //panelView.view.isHidden = !panelView.view.isHidden //if they hit the button, just do the opposite of what it's currently doing
        //below code shows panel above navigation bar, but can't click away to hide panel
        /*if(panelView.view.isHidden == false) {
            self.navigationController!.navigationBar.layer.zPosition = -1;
        }
        else {
            self.navigationController!.navigationBar.layer.zPosition = 0;
        }*/

    }
    
    func notesPressed() {
        print("notes pressed")
        panelView.view.isHidden = true
        notesView.view.isHidden = false
        self.notesView.view.frame = CGRect(x: self.view.frame.width/3, y: self.notesView.view.frame.minY, width: self.notesView.view.frame.width, height: self.notesView.view.frame.height)
        self.view.bringSubviewToFront(notesView.view)
        panelState = 1 
        
    }
    
    func backPressed() {
        print("back pressed")
        notesView.view.isHidden = true
        panelView.view.isHidden = false
        self.panelView.view.frame = CGRect(x: self.view.frame.width/3, y: self.panelView.view.frame.minY, width: self.panelView.view.frame.width, height: self.panelView.view.frame.height)
        self.view.bringSubviewToFront(panelView.view)
        panelState = 0
        
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.tintColor = .primaryColor
    }
    
    func loadMessages() {
        // Chat room database reference.
        let databaseClass = Constants.refs.databaseChats.child(className)
        let senderId = Auth.auth().currentUser!.uid
        
        let ref = Constants.refs.databaseUsers
        ref.child(senderId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.senderDisplayName = value?["displayName"] as? String ?? ""
            self.sender = Sender(id: senderId, displayName: self.senderDisplayName!)
            let query = databaseClass.queryLimited(toLast: 10)
            
            _ = query.observe(.childAdded, with: { [weak self] snapshot in
                
                if  let data        = snapshot.value as? [String: String],
                    let id          = data["sender_id"],
                    let name        = data["name"],
                    let text        = data["text"],
                    let messageId   = data["message_id"],
                    let interval    = data["date"],
                    !text.isEmpty
                {
                    let date = Date(timeIntervalSince1970: Double(interval)!)
                    let message = Message(text: text, sender: Sender(id: id, displayName: name), messageId: messageId, date: date)
                    self?.insertMessage(message)
                }
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc
    func loadMoreMessages() {
        
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: Message) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
}

// MARK: - MessagesDisplayDelegate

extension MessageViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 241/255, blue: 253/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
}

// MARK: - MessagesLayoutDelegate

extension MessageViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

extension MessageViewController: MessagesDataSource {
    func currentSender() -> Sender {
        return sender!
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let date = message.sentDate
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let dateString: String = "\(hour):\(minutes)"
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

extension MessageViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            
            let current = currentSender()
            
            if let str = component as? String {
                let message = Message(text: str, sender: current, messageId: UUID().uuidString, date: Date())
                let ref = Constants.refs.databaseChats.child(className).childByAutoId()
                let newMessage = ["sender_id": current.id, "name": current.displayName, "text": str, "message_id": message.messageId, "date": String(Date().timeIntervalSince1970)]
                ref.setValue(newMessage)
            }
            
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}


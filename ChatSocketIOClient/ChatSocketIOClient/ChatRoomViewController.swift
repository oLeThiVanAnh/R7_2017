//
//  ChatRoomViewController.swift
//  ChatSocketIOClient
//
//  Created by vananh on 7/24/17.
//  Copyright © 2017 vananh. All rights reserved.
//

import UIKit

class ChatRoomViewController: UITableViewController {
    @IBOutlet weak var inputTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputTextView.delegate = self
        NotificationCenter.default.addObserver(forName: Notification.Name("newChatMessage"), object: nil, queue: nil, using: updateChatRoom)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.inputTextView.becomeFirstResponder()
    }
    
    func updateChatRoom(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = 0
        let selectFriend = SocketIOManager.sharedInstance.selectedFriend
        if let messageList = SocketIOManager.sharedInstance.messageList[selectFriend.userID] {
            numberOfRow = messageList.count
        }
        
        return numberOfRow
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String = "MyMessageCell"
        
        let selectFriend = SocketIOManager.sharedInstance.selectedFriend
        let messageList: [ChatMessage] = SocketIOManager.sharedInstance.messageList[selectFriend.userID]!
        let message: ChatMessage = messageList[indexPath.row]
        
        if (message.isRemoteMessage) {
            cellIdentifier = "FriendMessageCell"
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = message.message
        
        return cell
    }
    
    func addMessage(message: ChatMessage) {
        let selectedFriend = SocketIOManager.sharedInstance.selectedFriend
        if SocketIOManager.sharedInstance.messageList[selectedFriend.userID] == nil {
            SocketIOManager.sharedInstance.messageList[selectedFriend.userID] = []
        }
        SocketIOManager.sharedInstance.messageList[selectedFriend.userID]?.append(message)
                
        let lastRowIndex = max(0, (SocketIOManager.sharedInstance.messageList[selectedFriend.userID]?.count)! - 1)
        self.tableView.insertRows(at: [NSIndexPath(row: lastRowIndex, section: 0) as IndexPath], with: UITableViewRowAnimation.none)
        self.tableView.scrollRectToVisible((self.tableView.tableFooterView?.frame)!, animated: true)
        
    }
}

extension ChatRoomViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.range(of: "\n")?.isEmpty == false {
            let selectedFriend = SocketIOManager.sharedInstance.selectedFriend
            
            var message: String = textView.text.replacingOccurrences(of: "\n", with: "")
            message = message.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            SocketIOManager.sharedInstance.sendMessage(message: message, toUserID: selectedFriend.userID)
            self.addMessage(message: ChatMessage(isRemoteMessage: false, message: message))
            textView.text = nil
            return false
        }
        
        return true
    }
    
}

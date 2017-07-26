//
//  SocketIOManager.swift
//  ChatSocketIOClient
//
//  Created by vananh on 7/24/17.
//  Copyright © 2017 vananh. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.181.129:9999")! as URL)
    var friendList: [FriendModel] = []
    var messageList: [String:[ChatMessage]] = [:]
    var nickName: String = "unknown"
    var selectedFriend: FriendModel = FriendModel()
    
    override init() {
        super.init()
        socket.on("updateFriendList") { ( dataArray, ack) -> Void in
            self.friendList.removeAll()
            let responseUserHash = dataArray[0] as! [String: String]
            for (userID, nickName) in responseUserHash {
                self.friendList.append(FriendModel(userID: userID, nickName: nickName))
            }
            
            //Send notification for friendlist update
            NotificationCenter.default.post(name: Notification.Name("updateFriendList"), object: nil)
            
        }
        
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            let userID: String = dataArray[0] as! String
            let message: String = dataArray[1] as! String
            let newMessage: ChatMessage = ChatMessage(isRemoteMessage: true, message: message)
            
            if self.messageList[userID] == nil {
                self.messageList[userID] = []
            }            
            self.messageList[userID]?.append(newMessage)
            NotificationCenter.default.post(name: Notification.Name("newChatMessage"), object: nil)
        }
    }
    
    
    func establishConnection(_ onConnectedEvent:@escaping ()->Void) {
        socket.connect()    
        socket.on("connect") {data, ack in
            onConnectedEvent()
        }
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    
    func connectToServerWithNickname(nickname: String) {
        socket.emit("updateNickname", nickname)
    }
    
    func sendMessage(message: String, toUserID userID: String) {
        socket.emit("newChatMessage", userID, message)
    }
    
    
    
    
    
    
}


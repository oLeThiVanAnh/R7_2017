//
//  FriendListViewController.swift
//  ChatSocketIOClient
//
//  Created by vananh on 7/24/17.
//  Copyright © 2017 vananh. All rights reserved.
//

import UIKit

class FriendListViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SocketIOManager.sharedInstance.establishConnection { [weak self] in
            let alert = UIAlertController(title: "Login", message: "Enter your name:", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter text:"
            })
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:
                {
                    action in
                    if let nickName = alert.textFields?[0].text {
                        SocketIOManager.sharedInstance.nickName = nickName
                    }
                    
                    SocketIOManager.sharedInstance.connectToServerWithNickname(nickname: SocketIOManager.sharedInstance.nickName)
                }))
            
            self?.present(alert, animated: true, completion: nil)
        }
        
        
        NotificationCenter.default.addObserver(forName: Notification.Name("updateFriendList"), object: nil, queue: nil, using: updateFriendList)
    }
    
    func updateFriendList(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SocketIOManager.sharedInstance.friendList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath)
        cell.textLabel?.text = SocketIOManager.sharedInstance.friendList[indexPath.row].nickName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SocketIOManager.sharedInstance.selectedFriend.userID = SocketIOManager.sharedInstance.friendList[indexPath.row].userID
        SocketIOManager.sharedInstance.selectedFriend.nickName = SocketIOManager.sharedInstance.friendList[indexPath.row].nickName
    }
}

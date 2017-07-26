//
//  XMPPController.swift
//  xmppChat
//
//  Created by Luca Genco on 20/07/2017.
//  Copyright © 2017 Luca Genco. All rights reserved.
//

import UIKit
import Foundation
import XMPPFramework


struct XMPPConstants {
    
    struct text {
        static let checkPrefix : String = "//check:"
        static let commandFriendPrefix : String = "//command friend:"
        static let friendCheckPrefix : String = "//friend check:"
        static let friendAcceptPrefix : String = "//friend accept:"
        static let friendRejectPrefix : String = "//friend reject:"
        static let commandRegisterSIPPrefix : String = "//command registersip:"
    }
}


enum XMPPManagerError: Error {
    case wrongUserJID
}

class XMPPManager: NSObject {
    
    var xmppStream: XMPPStream
    var xmppRoaster: XMPPRoster
    
    let hostName: String
    let userJID: XMPPJID
    let hostPort: UInt16
    let password: String
    
    init(hostName: String, userJIDString: String, hostPort: UInt16 = 5222, password: String) throws {
        guard let userJID = XMPPJID(string: userJIDString) else {
            throw XMPPManagerError.wrongUserJID
        }
        
        self.hostName = hostName
        self.userJID = userJID
        self.hostPort = hostPort
        self.password = password
        
        // Stream Configuration
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = userJID
        
        self.xmppRoaster = XMPPRoster()

        super.init()
        
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    
    func connect() {
        if !self.xmppStream.isDisconnected() {
            return
        }
        
        try! self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
    }
    
    func goOnline() {
        let presence = XMPPPresence()
        self.xmppStream.send(presence)
    }
    
    func goOffline() {
        
        let presence = XMPPPresence(type: "unavailable")
        self.xmppStream.send(presence)
    }
    
    
    func sendCustomMessage(text: String, toUser: String, messageUID: String) {
        
        let element = XMLElement(name: "body")
        element.stringValue = text
        let receiverJID = getJIDfromString(user: toUser)

        let msg = XMPPMessage(type: "chat", to:receiverJID)
        msg?.addAttribute(withName: "id", stringValue: messageUID.description)
        msg?.addChild(element)
        
        self.xmppStream.send(msg)
    }
    

    func sendMessage(text: String, toUser: String, messageUID: String) {
        
        let receiverJID = getJIDfromString(user: toUser)
        let msg = XMPPMessage(type: "chat", to: receiverJID)
        msg?.addBody(text)
        
        self.xmppStream.send(msg)
    }
    
    
    func sendServiceMessage(text: String, toUser: String) {
        
        let today: TimeInterval = Date().timeIntervalSince1970
        let intervalString: String = "\(today)"
        
        self.sendMessage(text: text, toUser: toUser, messageUID: intervalString)
    }
    
    
    //MARK: - Friendship
    func removeFriendship(userID: String) {

        xmppRoaster.removeUser(getJIDfromString(user: userID))
        self.sendServiceMessage(text:XMPPConstants.text.friendRejectPrefix, toUser: userID)
        
    }
    
    func acceptFriendship(userID: String) {
   
        xmppRoaster.acceptPresenceSubscriptionRequest(from: getJIDfromString(user: userID), andAddToRoster: true)
        self.sendServiceMessage(text: XMPPConstants.text.friendAcceptPrefix, toUser: userID)
    }
    
    func denyFriendship(userID: String , isRemove: Bool) {
        
        xmppRoaster.removeUser(getJIDfromString(user: userID))
        self.sendServiceMessage(text:XMPPConstants.text.friendRejectPrefix, toUser: userID)
    }
    
    func autoFriendRequest(userID: String) {
        
        xmppRoaster.removeUser(XMPPJID.init(string:"\(userID)"))
        self.sendServiceMessage(text:XMPPConstants.text.friendRejectPrefix, toUser: userID)
    }
    

    //MARK: - Friendship
    func getJIDfromString(user : String) -> XMPPJID {
        
        return XMPPJID.init(string:"\(user)")
    }
    
    
}


extension XMPPManager: XMPPStreamDelegate {
    
    func xmppStreamDidConnect(_ stream: XMPPStream!) {
        print("Stream: Connected")
        try! stream.authenticate(withPassword: self.password)
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        self.xmppStream.send(XMPPPresence())
        print("Stream: Authenticated")
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        print("Stream: Fail to Authenticate")
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        
        print(message)
        
        print(message.type())
        print(message.body())
        
    }

//    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
//        
//        print(presence)
//        
//        let presenceType = presence.type()
//        let username = sender.myJID.user
//        let presenceFromUser = presence.from().user
//        
//        if presenceFromUser != username  {
//            if presenceType == "available" {
//                print("available")
//            }
//            else if presenceType == "subscribe" {
//                //               xmppRoster.subscribePresence(toUser:presence.from())
//            }
//            else {
//                print("presence type");
//            }
//        }
//        
//    }
    
}












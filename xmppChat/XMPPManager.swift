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

enum XMPPManagerError: Error {
    case wrongUserJID
}

class XMPPManager: NSObject {
    var xmppStream: XMPPStream
    
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
    
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        
        print(presence)
        
        let presenceType = presence.type()
        let username = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        if presenceFromUser != username  {
            if presenceType == "available" {
                print("available")
            }
            else if presenceType == "subscribe" {
               xmppRoster.subscribePresence(toUser:presence.from())
            }
            else {
                print("presence type");
            }
        }
        
    }
    
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        
        print(message)
        
        print(message.type())
        print(message.body())
        
    }
    
}












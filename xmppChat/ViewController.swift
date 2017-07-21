//
//  ViewController.swift
//  xmppChat
//
//  Created by Luca Genco on 20/07/2017.
//  Copyright © 2017 Luca Genco. All rights reserved.
//

import UIKit
import XMPPFramework


class ViewController: UIViewController {

    var logInPresented = false
    var xmppManager: XMPPManager!
    
    
    @IBOutlet weak var userJIDTF: UITextField!
    @IBOutlet weak var userPasswordTF: UITextField!
    @IBOutlet weak var serverTF: UITextField!
    @IBOutlet weak var messageTF: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    //Send
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userJIDTF.text = "testxmpppippo@jabb3r.de"
        self.userPasswordTF.text = "130385"
        self.userPasswordTF.isSecureTextEntry =  true
        self.serverTF.text = "jabb3r.de"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTouchLogin(_ sender: Any) {
        do {
            try xmppManager = XMPPManager(hostName: self.serverTF.text! , userJIDString: self.userJIDTF.text!, password: self.userPasswordTF.text!)
            self.xmppManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
            self.xmppManager.connect()
            
            
            //Send
            xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
            xmppRoster.activate(self.xmppManager.xmppStream)

            
        } catch {
            print("ERROR")
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        
        let message = self.messageTF.text
        let senderJID = XMPPJID.init(string: "testxmppluca@jabb3r.de")
        let msg = XMPPMessage(type: "chat", to: senderJID)
        msg?.addBody(message)
        self.xmppManager.xmppStream.send(msg)
    }
    
    @IBAction func goOnLine(_ sender: Any) {
        self.xmppManager.goOnline()

    }
    
    @IBAction func goOffLine(_ sender: Any) {
        self.xmppManager.goOffline()

    }
}

extension ViewController: XMPPStreamDelegate, XMPPRosterDelegate {
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {

        let alertController = UIAlertController(title: "XMPP Chat", message: "Loggato", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
    
        let alertController = UIAlertController(title: "XMPP Chat", message: "Wrong password or username", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Chiudi", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}

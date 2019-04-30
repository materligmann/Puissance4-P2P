//
//  ViewController.swift
//  FourinaRow
//
//  Created by Mathias Erligmann on 16/02/2019.
//  Copyright © 2019 Mathias Erligmann. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, SideDelegate, GameDelegate {
    
    
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var mcBrowserController : MCBrowserViewController?
    
    var choosenSide : PlayerSide?
    
    @IBOutlet weak var hostButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        startHosting()
        configureHostButton()
        
    }
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("connected in vc")
            sendSide()
        case.connecting:
            print("connecting in vc")
        case .notConnected:
            print("not connected in vc")
        }
    }
    func sendSide() {
        print("sendingSide")
        guard choosenSide != nil else { return }
        print("choosen not nil")
        let data = choosenSide!.rawValue.data(using: .utf8)
        print("data encoded")
        guard data != nil else { return }
        print("data not nil")
        try? mcSession.send(data!, toPeers: mcSession.connectedPeers, with: .reliable)
        print("sent")
    }
    func moveToGame() {
        print("moving to game")
        if mcBrowserController != nil {
            print("not nil")
            if mcBrowserController!.isViewLoaded {
                print("presented")
                mcBrowserController!.dismiss(animated: true) {
                    print("dismissing")
                    self.performSegue(withIdentifier: "toGame", sender: self)
                    return
                }
            }else {
                self.performSegue(withIdentifier: "toGame", sender: self)
            }
        }else {
            self.performSegue(withIdentifier: "toGame", sender: self)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let message = String(data: data, encoding: .utf8)
        switch message {
        case PlayerSide.jaune.rawValue:
            print("jaune received")
            choosenSide = .rouge
            sendConfirmation()
            moveToGame()
        case PlayerSide.rouge.rawValue:
            print("rouge received")
            choosenSide = .jaune
            sendConfirmation()
            moveToGame()
        case "C":
            print("confirmation received")
            DispatchQueue.main.async {
                self.moveToGame()
            }
        default:
            print(message)
            print("default message sended")
        }
    }
    func sendConfirmation() {
        let message = "C"
        let data = message.data(using: .utf8)
        guard data != nil else { return }
        try? mcSession.send(data!, toPeers: mcSession.connectedPeers, with: .reliable)
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
    
    func configureHostButton()  {
        hostButton.layer.cornerRadius = 20
        hostButton.dropShadow()
    }
    func startHosting() {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-kb", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    func joinSession() {
        mcBrowserController = MCBrowserViewController(serviceType: "hws-kb", session: mcSession)
        mcBrowserController!.delegate = self
        present(mcBrowserController!, animated: true)
    }

    
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toSide", sender: self)
        
    }
    func didChooseSide(side: PlayerSide) {
        choosenSide = side
        joinSession()
    }
    func didReceiveSession(session: MCSession) {
        print("sessionReceived")
        self.mcSession = session
        self.mcSession.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGame" {
            guard let navVC = segue.destination as? UINavigationController else { return }
            guard let gameVC = navVC.viewControllers[0] as? GameVC else { return }
            gameVC.delegate = self
            guard choosenSide != nil else { return }
            gameVC.session = self.mcSession
            gameVC.playerSide = choosenSide!
            if choosenSide! == .jaune {
                gameVC.canPlay = false
            }else {
                gameVC.canPlay = true
            }
        }
        if segue.identifier == "toSide" {
            guard let sideVC = segue.destination as? SideVC else { return }
            sideVC.delegate = self
        }
    }
}


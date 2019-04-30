//
//  GameVC.swift
//  FourinaRow
//
//  Created by Mathias Erligmann on 16/02/2019.
//  Copyright © 2019 Mathias Erligmann. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import PopupDialog

protocol GameDelegate {
    func didReceiveSession(session : MCSession)
}
class GameVC: UIViewController, MCSessionDelegate, GridDelegate {
    
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var toPlayView: UIView!
    @IBOutlet weak var youAreView: UIView!
    
    private var gridButtons : [[UIButton]]?
    private var collumnsStacks = [UIStackView]()
    private var grid : Grid?
    var delegate : GameDelegate?
    var playerSide : PlayerSide!
    var canPlay : Bool! {
        didSet {
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    if self.canPlay {
                        if self.playerSide == PlayerSide.jaune {
                            self.toPlayView.backgroundColor = PlayerSide.jaune.associatedColor
                        }else {
                            self.toPlayView.backgroundColor = PlayerSide.rouge.associatedColor
                        }
                    }else {
                        if self.playerSide == PlayerSide.jaune {
                            self.toPlayView.backgroundColor = PlayerSide.rouge.associatedColor
                        }else {
                            self.toPlayView.backgroundColor = PlayerSide.jaune.associatedColor
                        }
                    }
                }
            }
        }
    }
    
    var session : MCSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        youAreView.layer.cornerRadius = youAreView.frame.height / 2
        toPlayView.layer.cornerRadius = toPlayView.frame.height / 2
        if playerSide == PlayerSide.jaune {
            youAreView.backgroundColor = PlayerSide.jaune.associatedColor
            if canPlay {
                toPlayView.backgroundColor = PlayerSide.jaune.associatedColor
            }else {
                toPlayView.backgroundColor = PlayerSide.rouge.associatedColor
            }
        }else {
            youAreView.backgroundColor = PlayerSide.rouge.associatedColor
            if canPlay {
                toPlayView.backgroundColor = PlayerSide.rouge.associatedColor
            }else {
                toPlayView.backgroundColor = PlayerSide.jaune.associatedColor
            }
        }
        grid = Grid(numberOfRow: 6, numberOfCol: 7)
        grid?.delegate = self
        getColumns(completion: getCircleButtons)
        guard session != nil else { return }
        session?.delegate = self
    }
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("connected in game")
        case .connecting:
            print("connecting in game")
        case .notConnected:
            print("not connected in game")
            let alert = UIAlertController(title: "Not Connected", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    func clearButtons() {
        guard gridButtons != nil else { return }
        for stack in gridButtons! {
            for button in stack {
                button.tintColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
            }
        }
    }
    func winWasDetected(side: CaseStatus) {
        print("winDetected")
        let popup = PopupDialog(title: "\(side == .jaune ? "Yellow" : "Red") won", message: "Do you want to start a new game")
        let ouiButton = PopupDialogButton(title: "Yes") {
            print("new game")
            self.clearButtons()
        }
        let nonButton = PopupDialogButton(title: "No") {
            print("no new game")
            self.session?.disconnect()
            self.dismiss(animated: true, completion: nil)
        }
        popup.addButtons([ouiButton,nonButton])
        self.present(popup, animated: true, completion: nil)
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decoder = JSONDecoder()
        let gridIndex = try? decoder.decode(GridIndex.self, from: data)
        guard gridIndex != nil else { return }
        print("Row: \(gridIndex!.row)")
        print("Col: \(gridIndex!.col)")
        addOpponentPiece(gridIndex: gridIndex!)
        canPlay = !canPlay
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func getColumns(completion : () -> ()) {
        for stack in mainStack.arrangedSubviews {
            guard let column = stack as? UIStackView else { return }
            collumnsStacks.append(column)
        }
        
        completion()
    }
    func getCircleButtons() {
        guard !collumnsStacks.isEmpty else { return }
        var grid = [[UIButton]]()
        var column = [UIButton]()
        for col in collumnsStacks {
            
            for button in col.arrangedSubviews {
                
                guard let circle = button as? UIButton else { return }
                
                configureButton(button: circle)
                column.append(circle)
            }
            grid.append(column)
            column = []
        }
        gridButtons = grid
    }
    func configureButton(button : UIButton) {
        let emptyImage = UIImage(named: "circle")
        button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        button.tintColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.addTarget(self, action: #selector(buttonWasPressed(button:)), for: .touchUpInside)
        button.setImage(emptyImage, for: .normal)
    }
    func addOpponentPiece(gridIndex : GridIndex) {
        let opponentSide = playerSide == .jaune ? PlayerSide.rouge : PlayerSide.jaune
        guard grid != nil else { return }
        guard let realgridIndex = grid!.addPiece(colIndex: gridIndex.col, side: opponentSide) else {
            print("col is full")
            return
        }
        guard let changedButton = gridButtons?[realgridIndex.col][realgridIndex.row] else { return }
        DispatchQueue.main.async {
            changedButton.tintColor = opponentSide.associatedColor
        }
    }
    func getButtonColIndex(button : UIButton) -> Int? {
        guard gridButtons != nil else { return nil }
        var index : Int?
        for (i,col) in gridButtons!.enumerated() {
            for but in col {
                if but == button {
                    index = i
                    break
                }
            }
        }
        return index
    }
    @objc func buttonWasPressed(button: UIButton) {
        guard canPlay else { return }
        guard let colIndex = getButtonColIndex(button: button) else { return }
        guard grid != nil else { return }
        canPlay = !canPlay
        guard let gridIndex = grid!.addPiece(colIndex: colIndex, side: playerSide) else {
            print("col is full")
            return
        }
        let encoder = JSONEncoder()
        let data = try? encoder.encode(gridIndex)
        guard data != nil else { return }
        guard session != nil else { return }
        try? session?.send(data!, toPeers: session?.connectedPeers ?? [], with: .reliable)
        guard gridButtons != nil else { return }
        guard let changedButton = gridButtons?[gridIndex.col][gridIndex.row] else { return }
        DispatchQueue.main.async {
            changedButton.tintColor = self.playerSide.associatedColor
        }
    }
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = #colorLiteral(red: 1, green: 0.3431297541, blue: 0.07248919457, alpha: 1)
        let popup = PopupDialog(title: "Warning", message: "Leaving will end the game, are you sure you want to leave ?")
        let yesButton = PopupDialogButton(title: "Yes") {
            self.session?.disconnect()
            if self.session != nil {
                self.session?.delegate = nil
                self.delegate?.didReceiveSession(session: self.session!)
            }
            self.dismiss(animated: true, completion: nil)
        }
        let cancelButton = PopupDialogButton(title: "Cancel") {
            print("cancelled")
        }
        popup.addButtons([yesButton, cancelButton])
        self.present(popup, animated: true, completion: nil)
    }
}

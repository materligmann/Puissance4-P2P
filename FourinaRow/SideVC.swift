//
//  SideVC.swift
//  FourinaRow
//
//  Created by Mathias Erligmann on 28/02/2019.
//  Copyright © 2019 Mathias Erligmann. All rights reserved.
//

import UIKit
protocol SideDelegate {
    func didChooseSide(side : PlayerSide)
}

class SideVC: UIViewController {

    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    
    var delegate : SideDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
    }
    
    func configureButtons() {
        yellowButton.layer.cornerRadius = yellowButton.bounds.height / 2
        redButton.layer.cornerRadius = redButton.bounds.height / 2
        yellowButton.dropShadow()
        redButton.dropShadow()
    }
    @IBAction func buttonWasPressed(_ sender: UIButton) {
        guard delegate != nil else { return }
        self.dismiss(animated: true) {
            if sender == self.redButton {
                self.delegate!.didChooseSide(side: .rouge)
            }else {
                self.delegate!.didChooseSide(side: .jaune)
            }
        }
    }
}

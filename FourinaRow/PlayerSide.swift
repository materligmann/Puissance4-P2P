//
//  PlayerSide.swift
//  FourinaRow
//
//  Created by Mathias Erligmann on 16/02/2019.
//  Copyright © 2019 Mathias Erligmann. All rights reserved.
//

import UIKit

enum PlayerSide : String {
   
    
    case rouge = "rouge"
    case jaune = "jaune"
    
    var associatedColor : UIColor {
        switch self {
        case .jaune:
            return #colorLiteral(red: 0.9937534928, green: 0.8900862336, blue: 0, alpha: 1)
        case .rouge:
            return #colorLiteral(red: 1, green: 0.3431297541, blue: 0.07248919457, alpha: 1)
        }
    }
}

//
//  UIViewExtension.swift
//  FourinaRow
//
//  Created by Mathias Erligmann on 28/02/2019.
//  Copyright © 2019 Mathias Erligmann. All rights reserved.
//

import UIKit

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = #colorLiteral(red: 0.231372549, green: 0.1882352941, blue: 0.1882352941, alpha: 1).cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
    }
}

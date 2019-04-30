//
//  Case.swift
//  FourinaRow
//
//  Created by Mathias Erligmann on 16/02/2019.
//  Copyright © 2019 Mathias Erligmann. All rights reserved.
//

import Foundation

struct Case {
    var gridCol : Int
    var gridRow : Int
    var caseStatus : CaseStatus = .empty
    
    init(gridCol: Int, gridRow: Int) {
        self.gridCol = gridCol
        self.gridRow = gridRow
    }
}

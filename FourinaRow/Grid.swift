//
//  Grid.swift
//  FourinaRow
//
//  Created by Mathias Erligmann on 16/02/2019.
//  Copyright © 2019 Mathias Erligmann. All rights reserved.
//

import Foundation

protocol GridDelegate {
    func winWasDetected(side : CaseStatus)
}
struct Grid {
    
    private var cases : [[Case]]
    var delegate : GridDelegate?
    
    init(numberOfRow : Int, numberOfCol : Int) {
        var cases = [[Case]]()
        for (_, i) in (0..<numberOfCol).enumerated() {
            var col = [Case]()
            for (_,j) in (0..<numberOfRow).enumerated() {
                let ca = Case(gridCol: i, gridRow: j)
                col.append(ca)
            }
            cases.append(col)
        }
        self.cases = cases
    }
    
    mutating func addPiece(colIndex : Int, side : PlayerSide) -> GridIndex? {
        guard let isPossible = checkPossibilityToAdd(colIndex: colIndex) else { return nil }
        guard isPossible else { return  nil }
        guard let rowIndex = getRow(colIndex: colIndex) else { return nil }
        let gridIndex = GridIndex(row: rowIndex, col: colIndex)
        changeCase(gridIndex: gridIndex, playerSide: side)
        checkForWin(gridIndex: gridIndex)
        return gridIndex
    }
    private mutating func changeCase(gridIndex : GridIndex, playerSide : PlayerSide) {
        if playerSide == .jaune {
            cases[gridIndex.col][gridIndex.row].caseStatus = .jaune
        }else{
            cases[gridIndex.col][gridIndex.row].caseStatus = .rouge
        }
    }
    mutating func checkForWin(gridIndex : GridIndex){
        let vCheck = verticalCheckForWin(gridIndex: gridIndex)
        if  vCheck.0 {
            print("vertical win")
            guard delegate != nil else { return }
            clearGrid()
            delegate!.winWasDetected(side: vCheck.1!)
            return
        }
        let hCheck = horizontalCheckForWin(gridIndex: gridIndex)
        if hCheck.0 {
            print("horizontal win")
            guard delegate != nil else { return }
            clearGrid()
            delegate!.winWasDetected(side: hCheck.1!)
            return
        }
        let dCheck = diagonalCheckForWin(gridIndex: gridIndex)
        if dCheck.0 {
            print("diagonale win")
            guard delegate != nil else { return }
            print(1)
            clearGrid()
            print(2)
            delegate!.winWasDetected(side: dCheck.1!)
            print(3)
            return
        }
    }
    private mutating func clearGrid(){
        for (i,col) in cases.enumerated() {
            for (j,_) in col.enumerated() {
                cases[i][j].caseStatus = .empty
            }
        }
    }
    
    func verticalCheckForWin(gridIndex : GridIndex) -> (Bool, CaseStatus?){
        let side = cases[gridIndex.col][gridIndex.row].caseStatus
        for (_,i) in (0..<3).enumerated(){
            print(1)
            let rowIndex = gridIndex.row + (i + 1)
            guard cases[gridIndex.col].indices.contains(rowIndex) else { return (false,nil)}
            print(2)
            guard cases[gridIndex.col][rowIndex].caseStatus == side else { return (false,nil)}
            print(3)
        }
        return (true, side)
    }
    func horizontalCheckForWin(gridIndex : GridIndex) -> (Bool, CaseStatus?) {
        let side = cases[gridIndex.col][gridIndex.row].caseStatus
        var leftBlocked = false
        var rightBlocked = false
        var numberOfAlign = 0
        for (_,i) in (0..<4).enumerated(){
            
            if rightBlocked && leftBlocked {
                return (false,nil)
            }
            if numberOfAlign == 3 {
                return (true,side)
            }
            
            if !rightBlocked {
            
                let colIndexRight = gridIndex.col + (i + 1)
                if !cases.indices.contains(colIndexRight){
            
                    rightBlocked = true
                }else {
            
                    if cases[colIndexRight][gridIndex.row].caseStatus != side {
            
                        rightBlocked = true
                    }else{
                        numberOfAlign += 1
                    }
                }
            }
            
            if !leftBlocked {
            
                let colIndexLeft = gridIndex.col - (i + 1)
                if !cases.indices.contains(colIndexLeft){
            
                    leftBlocked = true
                }else {
            
                    if cases[colIndexLeft][gridIndex.row].caseStatus != side {
            
                        leftBlocked = true
                    }else{
                        numberOfAlign += 1
                    }
                }
            }
            
        }
        
        return (true,side)
    }
    func diagonalCheckForWin(gridIndex : GridIndex) -> (Bool, CaseStatus?) {
        let side = cases[gridIndex.col][gridIndex.row].caseStatus
        var leftTopBlocked = false
        var rightTopBlocked = false
        var leftBottomBlocked = false
        var rightBottomBlocked = false
        var numberOfAlignTLtoBR = 0
        var numberOfAlignBLtoTR = 0
        for (_,i) in (0..<4).enumerated(){
            if leftTopBlocked && rightTopBlocked && leftBottomBlocked && rightBottomBlocked  {
                return (false,nil)
            }
            if numberOfAlignBLtoTR == 3 {
                return (true,side)
            }
            if numberOfAlignTLtoBR == 3 {
                return (true,side)
            }
            if !rightBottomBlocked {
                let colIndexRight = gridIndex.col + (i + 1)
                let rowIndexBottom = gridIndex.row - (i + 1)
                if !cases.indices.contains(colIndexRight){
                    rightBottomBlocked = true
                }else if !cases[colIndexRight].indices.contains(rowIndexBottom) {
                    rightBottomBlocked = true
                }else {
                    if cases[colIndexRight][rowIndexBottom].caseStatus != side {
                        rightBottomBlocked = true
                    }else{
                        numberOfAlignTLtoBR += 1
                    }
                }
            }
            if !rightTopBlocked {
                let colIndexRight = gridIndex.col + (i + 1)
                let rowIndexTop = gridIndex.row + (i + 1)
                if !cases.indices.contains(colIndexRight){
                    rightTopBlocked = true
                }else if !cases[colIndexRight].indices.contains(rowIndexTop) {
                    rightTopBlocked = true
                }else {
                    if cases[colIndexRight][rowIndexTop].caseStatus != side {
                        rightTopBlocked = true
                    }else{
                        numberOfAlignBLtoTR += 1
                    }
                }
            }
            if !leftBottomBlocked {
                let colIndexLeft = gridIndex.col - (i + 1)
                let rowIndexBottom = gridIndex.row - (i + 1)
                if !cases.indices.contains(colIndexLeft){
                    leftBottomBlocked = true
                }else if !cases[colIndexLeft].indices.contains(rowIndexBottom) {
                    leftBottomBlocked = true
                }else {
                    if cases[colIndexLeft][rowIndexBottom].caseStatus != side {
                        leftBottomBlocked = true
                    }else{
                        numberOfAlignBLtoTR += 1
                    }
                }
            }
            if !leftTopBlocked {
                let colIndexLeft = gridIndex.col - (i + 1)
                let rowIndexTop = gridIndex.row + (i + 1)
                if !cases.indices.contains(colIndexLeft){
                    leftTopBlocked = true
                }else if !cases[colIndexLeft].indices.contains(rowIndexTop) {
                    leftTopBlocked = true
                }else {
                    if cases[colIndexLeft][rowIndexTop].caseStatus != side {
                        leftTopBlocked = true
                    }else{
                        numberOfAlignTLtoBR += 1
                    }
                }
            }
        }
        return (true,side)
    }
    private func checkPossibilityToAdd(colIndex : Int) -> Bool? {
        guard let topCase = cases[colIndex].first else { return nil }
        guard topCase.caseStatus == .empty else { return false }
        return true
    }
    private func getRow(colIndex : Int) -> Int? {
        let col = cases[colIndex]
        var lastEmptyRow : Int?
        for (i, ca) in col.enumerated() {
            if ca.caseStatus == .empty {
                lastEmptyRow = i
            }
        }
        return lastEmptyRow
    }
}

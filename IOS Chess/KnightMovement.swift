//
//  KnightMovement.swift
//  IOS Chess
//
//  Created by Tenzin Gyaltso on 5/11/25.
//

import Foundation

struct KnightMovement {
    static func validateMove(
        piece: ChessPiece,
        from: (row: Int, col: Int),
        to: (row: Int, col: Int),
        board: [ChessPiece],
        capturedPieceId: inout UUID?
    ) -> MoveType {
        // Knight moves in an L shape: 2 squares in one direction and 1 square perpendicular
        let rowDiff = abs(to.row - from.row)
        let colDiff = abs(to.col - from.col)
        
        if !((rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2)) {
            return .invalid
        }
        
        // Check if destination has opponent's piece
        if let capturedPiece = board.first(where: { $0.position.row == to.row && $0.position.col == to.col }) {
            if capturedPiece.color != piece.color {
                capturedPieceId = capturedPiece.id
                return .capture
            }
            return .invalid
        }
        
        return .normal
    }
}

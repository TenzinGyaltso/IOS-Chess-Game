//
//  RookMovement.swift
//  IOS Chess
//
//  Created by Tenzin Gyaltso on 5/11/25.
//

import Foundation

struct RookMovement {
    static func validateMove(
        piece: ChessPiece,
        from: (row: Int, col: Int),
        to: (row: Int, col: Int),
        board: [ChessPiece],
        capturedPieceId: inout UUID?
    ) -> MoveType {
        // Rook moves in straight lines (horizontally or vertically)
        if from.row != to.row && from.col != to.col {
            return .invalid
        }
        
        // Check if the path is clear
        let rowDelta = to.row > from.row ? 1 : (to.row < from.row ? -1 : 0)
        let colDelta = to.col > from.col ? 1 : (to.col < from.col ? -1 : 0)
        
        var checkRow = from.row + rowDelta
        var checkCol = from.col + colDelta
        
        while checkRow != to.row || checkCol != to.col {
            if board.contains(where: { $0.position.row == checkRow && $0.position.col == checkCol }) {
                return .invalid
            }
            checkRow += rowDelta
            checkCol += colDelta
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

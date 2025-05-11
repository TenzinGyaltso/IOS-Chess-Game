//
//  QueenMovement.swift
//  IOS Chess
//
//  Created by Tenzin Gyaltso on 5/11/25.
//

import Foundation

struct QueenMovement {
    static func validateMove(
        piece: ChessPiece,
        from: (row: Int, col: Int),
        to: (row: Int, col: Int),
        board: [ChessPiece],
        capturedPieceId: inout UUID?
    ) -> MoveType {
        // Queen can move like a rook or a bishop
        let rookMove = RookMovement.validateMove(piece: piece, from: from, to: to, board: board, capturedPieceId: &capturedPieceId)
        if rookMove != .invalid {
            return rookMove
        }
        
        return BishopMovement.validateMove(piece: piece, from: from, to: to, board: board, capturedPieceId: &capturedPieceId)
    }
}

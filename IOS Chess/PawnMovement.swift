//
//  PawnMovement.swift
//  IOS Chess
//
//  Created by Tenzin Gyaltso on 5/11/25.
//

import Foundation

struct PawnMovement {
    static func validateMove(
        piece: ChessPiece,
        from: (row: Int, col: Int),
        to: (row: Int, col: Int),
        board: [ChessPiece],
        capturedPieceId: inout UUID?
    ) -> MoveType {
        let direction = piece.color == .white ? -1 : 1
        
        // Normal move: one square forward
        if from.col == to.col && from.row + direction == to.row {
            // Check if the destination square is empty
            if !board.contains(where: { $0.position.row == to.row && $0.position.col == to.col }) {
                // Check for promotion
                if (piece.color == .white && to.row == 0) || (piece.color == .black && to.row == 7) {
                    return .promotion
                }
                return .normal
            }
        }
        
        // First move: two squares forward
        if !piece.hasMoved && from.col == to.col && from.row + (2 * direction) == to.row {
            // Check if both the intermediate and destination squares are empty
            let intermediateRow = from.row + direction
            if !board.contains(where: { ($0.position.row == intermediateRow && $0.position.col == from.col) ||
                                      ($0.position.row == to.row && $0.position.col == to.col) }) {
                return .normal
            }
        }
        
        // Capture: diagonal move
        if abs(from.col - to.col) == 1 && from.row + direction == to.row {
            // Direct capture
            if let capturedPiece = board.first(where: { $0.position.row == to.row && $0.position.col == to.col }) {
                if capturedPiece.color != piece.color {
                    capturedPieceId = capturedPiece.id
                    
                    // Check for promotion
                    if (piece.color == .white && to.row == 0) || (piece.color == .black && to.row == 7) {
                        return .promotion
                    }
                    return .capture
                }
            }
            
            // En passant capture
            let enPassantRow = piece.color == .white ? 3 : 4  // Row where en passant capture can happen
            if from.row == enPassantRow {
                if let capturedPiece = board.first(where: {
                    $0.position.row == from.row &&
                    $0.position.col == to.col &&
                    $0.type == .pawn &&
                    $0.color != piece.color &&
                    $0.canBeCapturedEnPassant
                }) {
                    capturedPieceId = capturedPiece.id
                    return .enPassant
                }
            }
        }
        
        return .invalid
    }
}

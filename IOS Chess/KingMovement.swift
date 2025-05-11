//
//  KingMovement.swift
//  IOS Chess
//
//  Created by Tenzin Gyaltso on 5/11/25.
//

import Foundation

struct KingMovement {
    static func validateMove(
        piece: ChessPiece,
        from: (row: Int, col: Int),
        to: (row: Int, col: Int),
        board: [ChessPiece],
        capturedPieceId: inout UUID?
    ) -> MoveType {
        let rowDiff = abs(to.row - from.row)
        let colDiff = abs(to.col - from.col)
        
        // Normal king move (one square in any direction)
        if rowDiff <= 1 && colDiff <= 1 {
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
        
        // Castling
        if !piece.hasMoved && from.row == to.row && abs(from.col - to.col) == 2 {
            // Determine if it's kingside or queenside castling
            let kingsideCol = 6
            let queensideCol = 2
            let rookColFrom = to.col == kingsideCol ? 7 : 0
            
            // Check if the rook is in place and hasn't moved
            guard let rook = board.first(where: {
                $0.position.row == from.row &&
                $0.position.col == rookColFrom &&
                $0.type == .rook &&
                $0.color == piece.color &&
                !$0.hasMoved
            }) else {
                return .invalid
            }
            
            // Check if the path between king and rook is clear
            let direction = to.col > from.col ? 1 : -1
            var checkCol = from.col + direction
            
            while checkCol != rookColFrom {
                if board.contains(where: { $0.position.row == from.row && $0.position.col == checkCol }) {
                    return .invalid
                }
                checkCol += direction
            }
            
            // Check if king is in check or would pass through check
            let kingColor = piece.color
            let opponentColor = kingColor == .white ? PieceColor.black : PieceColor.white
            let opponentPieces = board.filter { $0.color == opponentColor }
            
            // Check current position
            let kingPos = (from.row, from.col)
            for opponentPiece in opponentPieces {
                let move = ChessPieceMovement.validateMove(
                    piece: opponentPiece,
                    from: opponentPiece.position,
                    to: kingPos,
                    board: board,
                    checkForCheck: false
                )
                if move.type == .capture {
                    return .invalid
                }
            }
            
            // Check intermediate position
            let intermediatePos = (from.row, from.col + direction)
            for opponentPiece in opponentPieces {
                let move = ChessPieceMovement.validateMove(
                    piece: opponentPiece,
                    from: opponentPiece.position,
                    to: intermediatePos,
                    board: board,
                    checkForCheck: false
                )
                if move.type == .capture {
                    return .invalid
                }
            }
            
            // Check destination position
            for opponentPiece in opponentPieces {
                let move = ChessPieceMovement.validateMove(
                    piece: opponentPiece,
                    from: opponentPiece.position,
                    to: to,
                    board: board,
                    checkForCheck: false
                )
                if move.type == .capture {
                    return .invalid
                }
            }
            
            return .castling
        }
        
        return .invalid
    }
}

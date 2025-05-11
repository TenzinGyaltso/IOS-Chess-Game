//
//  ChessMovement.swift
//  IOS Chess
//
//  Created by Tenzin Gyaltso on 5/11/25.
//

import Foundation

struct ChessPieceMovement {
    static func validateMove(
        piece: ChessPiece,
        from: (row: Int, col: Int),
        to: (row: Int, col: Int),
        board: [ChessPiece],
        checkForCheck: Bool = true
    ) -> ChessMove {
        // Can't move to the same square
        if from.row == to.row && from.col == to.col {
            return ChessMove(type: .invalid, from: from, to: to)
        }
        
        // Check if destination is occupied by own piece
        if let occupyingPiece = board.first(where: { $0.position.row == to.row && $0.position.col == to.col }) {
            if occupyingPiece.color == piece.color {
                return ChessMove(type: .invalid, from: from, to: to)
            }
        }
        
        var moveType: MoveType = .invalid
        var capturedPieceId: UUID? = nil
        
        // Check move validity based on piece type
        switch piece.type {
        case .pawn:
            moveType = PawnMovement.validateMove(piece: piece, from: from, to: to, board: board, capturedPieceId: &capturedPieceId)
        case .rook:
            moveType = RookMovement.validateMove(piece: piece, from: from, to: to, board: board, capturedPieceId: &capturedPieceId)
        case .knight:
            moveType = KnightMovement.validateMove(piece: piece, from: from, to: to, board: board, capturedPieceId: &capturedPieceId)
        case .bishop:
            moveType = BishopMovement.validateMove(piece: piece, from: from, to: to, board: board, capturedPieceId: &capturedPieceId)
        case .queen:
            moveType = QueenMovement.validateMove(piece: piece, from: from, to: to, board: board, capturedPieceId: &capturedPieceId)
        case .king:
            moveType = KingMovement.validateMove(piece: piece, from: from, to: to, board: board, capturedPieceId: &capturedPieceId)
        }
        
        // Create the move
        let move = ChessMove(
            type: moveType,
            from: from,
            to: to,
            capturedPieceId: capturedPieceId,
            wasFirstMove: !piece.hasMoved,
            capturedPiece: capturedPieceId != nil ?
                board.first(where: { $0.id == capturedPieceId }) : nil
        )
        
        // If the move would result in check for the player's king, invalidate it
        if checkForCheck && moveType != .invalid {
            // Create a temporary board copy to simulate the move
            var tempBoard = board
            
            // Find the piece in the temp board
            guard let pieceIndex = tempBoard.firstIndex(where: { $0.id == piece.id }) else {
                return ChessMove(type: .invalid, from: from, to: to)
            }
            
            // Temporarily make the move on our copy
            let originalPosition = tempBoard[pieceIndex].position
            tempBoard[pieceIndex].position = to
            
            // If there's a capture, remove that piece
            if let capturedId = capturedPieceId,
               let capturedIndex = tempBoard.firstIndex(where: { $0.id == capturedId }) {
                tempBoard.remove(at: capturedIndex)
            }
            
            // Check if the king is in check after this move
            let kingColor = piece.color
            guard let king = tempBoard.first(where: { $0.type == .king && $0.color == kingColor }) else {
                // Restore original position and return invalid move
                tempBoard[pieceIndex].position = originalPosition
                return ChessMove(type: .invalid, from: from, to: to)
            }
            
            let opponentColor = kingColor == .white ? PieceColor.black : PieceColor.white
            let opponentPieces = tempBoard.filter { $0.color == opponentColor }
            
            // Check if any opponent piece can attack the king
            for opponentPiece in opponentPieces {
                let attackMove = validateMove(
                    piece: opponentPiece,
                    from: opponentPiece.position,
                    to: king.position,
                    board: tempBoard,
                    checkForCheck: false  // Important to avoid infinite recursion
                )
                
                if attackMove.type == .capture {
                    return ChessMove(type: .invalid, from: from, to: to)
                }
            }
        }
        
        return move
    }
    
    // Helper method to determine if a king is in check
    static func isKingInCheck(color: PieceColor, board: [ChessPiece]) -> Bool {
        // Find king position
        guard let king = board.first(where: { $0.type == .king && $0.color == color }) else {
            return false
        }
        
        // Check if any opponent piece can capture the king
        let opponentColor = color == .white ? PieceColor.black : PieceColor.white
        let opponentPieces = board.filter { $0.color == opponentColor }
        
        for piece in opponentPieces {
            let move = validateMove(
                piece: piece,
                from: piece.position,
                to: king.position,
                board: board,
                checkForCheck: false // Important to avoid infinite recursion
            )
            
            if move.type == .capture {
                return true
            }
        }
        
        return false
    }
    
    // Helper method to determine if a player has any legal moves
    static func playerHasLegalMoves(color: PieceColor, board: [ChessPiece]) -> Bool {
        let playerPieces = board.filter { $0.color == color }
        
        for piece in playerPieces {
            for row in 0..<8 {
                for col in 0..<8 {
                    let move = validateMove(
                        piece: piece,
                        from: piece.position,
                        to: (row, col),
                        board: board
                    )
                    
                    if move.type != .invalid {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // Helper method to determine if a move would result in check
    static func wouldMoveResultInCheck(piece: ChessPiece, move: ChessMove, board: [ChessPiece]) -> Bool {
        var tempBoard = board
        
        // Simulate move
        guard let pieceIndex = tempBoard.firstIndex(where: { $0.id == piece.id }) else {
            return false
        }
        
        // Handle captured piece
        if let capturedPieceId = move.capturedPieceId,
           let capturedIndex = tempBoard.firstIndex(where: { $0.id == capturedPieceId }) {
            tempBoard.remove(at: capturedIndex)
            
            // Adjust index if needed
            if capturedIndex < pieceIndex {
                // If we removed a piece with a lower index, we need to adjust our index
                tempBoard[pieceIndex - 1].position = move.to
            } else {
                tempBoard[pieceIndex].position = move.to
            }
        } else {
            tempBoard[pieceIndex].position = move.to
        }
        
        // Check if king is in check after this move
        return isKingInCheck(color: piece.color, board: tempBoard)
    }
}

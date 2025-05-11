//
//  ChessModels.swift
//  IOS Chess
//
//  Created by Tenzin Gyaltso on 5/11/25.
//

import Foundation
import SwiftUI

// Basic types and enums
enum PieceType: String, CaseIterable {
    case king = "King"
    case queen = "Queen"
    case rook = "Rook"
    case bishop = "Bishop"
    case knight = "Knight"
    case pawn = "Pawn"
}

enum PieceColor {
    case white
    case black
    
    var opponent: PieceColor {
        return self == .white ? .black : .white
    }
}

// Chess piece model
struct ChessPiece: Identifiable, Equatable {
    let id: UUID
    var type: PieceType
    let color: PieceColor
    var position: (row: Int, col: Int)
    var hasMoved: Bool = false
    var canBeCapturedEnPassant: Bool = false
    
    var imageName: String {
        "\(color == .white ? "White" : "Black") \(type.rawValue)"
    }
    
    var image: Image {
        Image(imageName)
    }
    
    init(id: UUID = UUID(), type: PieceType, color: PieceColor, position: (row: Int, col: Int), hasMoved: Bool = false, canBeCapturedEnPassant: Bool = false) {
        self.id = id
        self.type = type
        self.color = color
        self.position = position
        self.hasMoved = hasMoved
        self.canBeCapturedEnPassant = canBeCapturedEnPassant
    }
    
    static func == (lhs: ChessPiece, rhs: ChessPiece) -> Bool {
        return lhs.id == rhs.id &&
               lhs.type == rhs.type &&
               lhs.color == rhs.color &&
               lhs.position.row == rhs.position.row &&
               lhs.position.col == rhs.position.col &&
               lhs.hasMoved == rhs.hasMoved &&
               lhs.canBeCapturedEnPassant == rhs.canBeCapturedEnPassant
    }
}

// Game status enum
enum GameStatus {
    case active
    case check
    case checkmate
    case stalemate
    case whiteWin
    case blackWin
    case draw
}

// Move types
enum MoveType {
    case normal
    case capture
    case castling
    case enPassant
    case promotion
    case invalid
}

// Chess move model
struct ChessMove {
    let type: MoveType
    let from: (row: Int, col: Int)
    let to: (row: Int, col: Int)
    let capturedPieceId: UUID?
    let wasFirstMove: Bool
    let capturedPiece: ChessPiece?
    
    init(type: MoveType, from: (row: Int, col: Int), to: (row: Int, col: Int), capturedPieceId: UUID? = nil, wasFirstMove: Bool = false, capturedPiece: ChessPiece? = nil) {
        self.type = type
        self.from = from
        self.to = to
        self.capturedPieceId = capturedPieceId
        self.wasFirstMove = wasFirstMove
        self.capturedPiece = capturedPiece
    }
}

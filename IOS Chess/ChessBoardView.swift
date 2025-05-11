//
//  ChessBoardView.swift
//  IOS Chess
//
//  Created by Tenzin Gyaltso on 5/10/25.
//

import SwiftUI

// MARK: - Chess Square View
struct ChessSquareView: View {
    let row: Int
    let col: Int
    let squareSize: CGFloat
    let piece: ChessPiece?
    let isSelected: Bool
    let isLastMove: Bool
    let isValidMove: Bool
    let onTap: () -> Void
    let onDrag: (DragGesture.Value) -> Void
    let onDragEnd: (DragGesture.Value) -> Void
    
    var body: some View {
        ZStack {
            // Square background
            Rectangle()
                .fill((row + col) % 2 == 0 ? Color(white: 0.9) : Color(white: 0.5))
                .frame(width: squareSize, height: squareSize)
            
            // Highlight selected square
            if isSelected {
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: squareSize, height: squareSize)
            }
            
            // Highlight last move
            if isLastMove {
                Rectangle()
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: squareSize, height: squareSize)
            }
            
            // Show valid move indicators
            if isValidMove {
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: squareSize * 0.3, height: squareSize * 0.3)
            }
            
            // Chess piece
            if let piece = piece {
                piece.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: squareSize * 0.8, height: squareSize * 0.8)
                    .background(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged(onDrag)
                            .onEnded(onDragEnd)
                    )
            }
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Chess Board View
struct ChessBoardView: View {
    @State private var pieces: [ChessPiece] = ChessBoardView.initializePieces()
    @State private var selectedPiece: ChessPiece?
    @State private var dragOffset: CGSize = .zero
    @State private var draggedPiece: ChessPiece?
    @State private var isWhiteTurn: Bool = true
    @State private var message: String = "White's turn"
    @State private var gameStatus: GameStatus = .active
    @State private var moveHistory: [ChessMove] = []
    @State private var showPromotionOptions: Bool = false
    @State private var pendingPromotion: (pieceIndex: Int, position: (row: Int, col: Int))? = nil
    
    // Use dynamic sizing based on the screen size
    var squareSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return min(screenWidth / 8, 50)
    }
    
    var body: some View {
        VStack {
            // Game status message and reset button
            HStack {
                Text(message)
                    .font(.headline)
                    .foregroundColor(gameStatus == .check ? .red : .primary)
                
                Spacer()
                
                Button(action: resetGame) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding()
            
            // Chess board
            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            ChessSquareView(
                                row: row,
                                col: col,
                                squareSize: squareSize,
                                piece: pieces.first(where: { $0.position.row == row && $0.position.col == col }),
                                isSelected: selectedPiece?.position.row == row && selectedPiece?.position.col == col,
                                isLastMove: isLastMoveSquare(row: row, col: col),
                                isValidMove: isValidMoveSquare(row: row, col: col),
                                onTap: { handleSquareTap(row: row, col: col) },
                                onDrag: { gesture in
                                    if let piece = pieces.first(where: { $0.position.row == row && $0.position.col == col }),
                                       piece.color == (isWhiteTurn ? .white : .black) {
                                        draggedPiece = piece
                                        dragOffset = gesture.translation
                                    }
                                },
                                onDragEnd: { gesture in
                                    handlePieceDrop(piece: draggedPiece, gesture: gesture)
                                }
                            )
                        }
                    }
                }
            }
            .overlay(
                // Dragged piece overlay
                Group {
                    if let piece = draggedPiece {
                        piece.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: squareSize * 0.8, height: squareSize * 0.8)
                            .background(Color.clear)
                            .offset(dragOffset)
                            .position(
                                x: CGFloat(piece.position.col) * squareSize + squareSize/2,
                                y: CGFloat(piece.position.row) * squareSize + squareSize/2
                            )
                    }
                }
            )
        }
        .sheet(isPresented: $showPromotionOptions) {
            PromotionView { pieceType in
                handlePromotion(pieceType: pieceType)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func isLastMoveSquare(row: Int, col: Int) -> Bool {
        guard let lastMove = moveHistory.last else { return false }
        return (lastMove.from.row == row && lastMove.from.col == col) ||
               (lastMove.to.row == row && lastMove.to.col == col)
    }
    
    private func isValidMoveSquare(row: Int, col: Int) -> Bool {
        guard let selectedPiece = selectedPiece else { return false }
        let move = ChessPieceMovement.validateMove(
            piece: selectedPiece,
            from: selectedPiece.position,
            to: (row, col),
            board: pieces
        )
        return move.type != .invalid
    }
    
    // MARK: - Game Logic
    
    private func resetGame() {
        pieces = ChessBoardView.initializePieces()
        selectedPiece = nil
        dragOffset = .zero
        draggedPiece = nil
        isWhiteTurn = true
        message = "White's turn"
        gameStatus = .active
        moveHistory = []
        showPromotionOptions = false
        pendingPromotion = nil
    }
    
    private func handleSquareTap(row: Int, col: Int) {
        if let selectedPiece = selectedPiece {
            let move = ChessPieceMovement.validateMove(
                piece: selectedPiece,
                from: selectedPiece.position,
                to: (row, col),
                board: pieces
            )
            
            if move.type != .invalid {
                executeMove(move: move)
            }
            self.selectedPiece = nil
        } else {
            if let piece = pieces.first(where: { $0.position.row == row && $0.position.col == col }) {
                if piece.color == (isWhiteTurn ? .white : .black) {
                    self.selectedPiece = piece
                }
            }
        }
    }
    
    private func handlePieceDrop(piece: ChessPiece?, gesture: DragGesture.Value) {
        guard let piece = piece else { return }
        
        let row = Int((gesture.location.y - squareSize/2) / squareSize)
        let col = Int((gesture.location.x - squareSize/2) / squareSize)
        
        if row >= 0 && row < 8 && col >= 0 && col < 8 {
            let move = ChessPieceMovement.validateMove(
                piece: piece,
                from: piece.position,
                to: (row, col),
                board: pieces
            )
            
            if move.type != .invalid {
                executeMove(move: move)
            }
        }
        
        draggedPiece = nil
        dragOffset = .zero
    }
    
    private func executeMove(move: ChessMove) {
        guard let pieceIndex = pieces.firstIndex(where: { $0.id == selectedPiece?.id }) else { return }
        
        // Handle special moves
        switch move.type {
        case .promotion:
            pendingPromotion = (pieceIndex, move.to)
            showPromotionOptions = true
            return
            
        case .castling:
            // Move the rook
            let rookCol = move.to.col > move.from.col ? 7 : 0
            let newRookCol = move.to.col > move.from.col ? move.to.col - 1 : move.to.col + 1
            
            if let rookIndex = pieces.firstIndex(where: {
                $0.type == .rook &&
                $0.position.row == move.from.row &&
                $0.position.col == rookCol
            }) {
                pieces[rookIndex].position = (move.from.row, newRookCol)
                pieces[rookIndex].hasMoved = true
            }
            
        case .enPassant:
            // Remove the captured pawn
            if let capturedPiece = move.capturedPiece {
                pieces.removeAll { $0.id == capturedPiece.id }
            }
            
        default:
            break
        }
        
        // Update piece position
        pieces[pieceIndex].position = move.to
        pieces[pieceIndex].hasMoved = true
        
        // Remove captured piece if any
        if let capturedPieceId = move.capturedPieceId {
            pieces.removeAll { $0.id == capturedPieceId }
        }
        
        // Update game state
        moveHistory.append(move)
        isWhiteTurn.toggle()
        selectedPiece = nil
        
        // Update message and check game status
        updateGameStatus()
    }
    
    private func handlePromotion(pieceType: PieceType) {
        guard let promotion = pendingPromotion else { return }
        
        pieces[promotion.pieceIndex].type = pieceType
        pieces[promotion.pieceIndex].position = promotion.position
        pieces[promotion.pieceIndex].hasMoved = true
        
        pendingPromotion = nil
        showPromotionOptions = false
        
        // Update game state
        isWhiteTurn.toggle()
        updateGameStatus()
    }
    
    private func updateGameStatus() {
        let currentColor = isWhiteTurn ? PieceColor.white : PieceColor.black
        
        // Check if king is in check
        if ChessPieceMovement.isKingInCheck(color: currentColor, board: pieces) {
            gameStatus = .check
            message = "\(currentColor == .white ? "White" : "Black") is in check!"
            
            // Check for checkmate
            if !ChessPieceMovement.playerHasLegalMoves(color: currentColor, board: pieces) {
                gameStatus = currentColor == .white ? .blackWin : .whiteWin
                message = "Checkmate! \(currentColor == .white ? "Black" : "White") wins!"
            }
        } else {
            // Check for stalemate
            if !ChessPieceMovement.playerHasLegalMoves(color: currentColor, board: pieces) {
                gameStatus = .stalemate
                message = "Stalemate! Game is a draw."
            } else {
                gameStatus = .active
                message = "\(currentColor == .white ? "White" : "Black")'s turn"
            }
        }
    }
    
    // MARK: - Initialization
    
    static func initializePieces() -> [ChessPiece] {
        var pieces: [ChessPiece] = []
        
        // Initialize pawns
        for col in 0..<8 {
            pieces.append(ChessPiece(type: .pawn, color: .white, position: (6, col)))
            pieces.append(ChessPiece(type: .pawn, color: .black, position: (1, col)))
        }
        
        // Initialize other pieces
        let backRankPieces: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        
        for (col, type) in backRankPieces.enumerated() {
            pieces.append(ChessPiece(type: type, color: .white, position: (7, col)))
            pieces.append(ChessPiece(type: type, color: .black, position: (0, col)))
        }
        
        return pieces
    }
}

// MARK: - Promotion View
struct PromotionView: View {
    let onSelect: (PieceType) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a piece to promote to")
                .font(.headline)
            
            HStack(spacing: 30) {
                ForEach([PieceType.queen, .rook, .bishop, .knight], id: \.self) { type in
                    Button(action: { onSelect(type) }) {
                        ChessPiece(type: type, color: .white, position: (0, 0)).image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ChessBoardView()
}

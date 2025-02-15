import SwiftUI

struct PatternMatchGameView: View {
    @State private var grid: [[PatternCell]] = []
    @State private var selectedCells: Set<Int> = []
    @State private var revealedCells: Set<Int> = []
    @State private var score = 0
    @State private var level = 1
    @State private var gameActive = false
    
    // Added for cognitive/memory enhancement:
    @State private var showAllPatterns = false
    @State private var timeRemaining = 0
    @State private var timer: Timer?
    
    // Reference the universal score (persisted)
    @AppStorage("universalScore") private var universalScore: Int = 0
    
    let gridSize = 4
    let patternRevealDuration = 2 // seconds
    let maxTimePerLevel = 20      // a basic timer for each level
    
    var body: some View {
        ZStack {
            Color(hex: "#02a59c").ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Pattern Match")
                            .font(.system(size: 28, weight: .bold))
                        Text("Level \(level)")
                            .font(.system(size: 18))
                    }
                    Spacer()
                    Text("Score: \(score)")
                        .font(.system(size: 24, weight: .bold))
                }
                .foregroundColor(Color(hex: "#013640"))
                .padding()
                .background(Color(hex: "#bcebf2"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Timer display (cognitive challenge aspect)
                if gameActive {
                    Text("Time Left: \(timeRemaining)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                if gameActive {
                    // Grid
                    VStack(spacing: 8) {
                        ForEach(0..<gridSize, id: \.self) { row in
                            HStack(spacing: 8) {
                                ForEach(0..<gridSize, id: \.self) { column in
                                    let index = row * gridSize + column
                                    PatternCellView(
                                        cell: grid[row][column],
                                        showPattern: showAllPatterns || revealedCells.contains(index),
                                        isTapped: selectedCells.contains(index)
                                    )
                                    .onTapGesture {
                                        cellTapped(row: row, column: column)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "#bcebf2"))
                    .cornerRadius(16)
                } else {
                    Button(action: startGame) {
                        Text("Start Game")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#013640"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#02fcee"))
                            .cornerRadius(16)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func startGame() {
        gameActive = true
        level = 1
        score = 0
        nextLevel()
    }
    
    private func nextLevel() {
        generateNewGrid()
        startTimer()
        revealPatternsTemporarily()
    }
    
    private func generateNewGrid() {
        // Clear old data
        grid = Array(repeating: Array(repeating: PatternCell(), count: gridSize), count: gridSize)
        selectedCells.removeAll()
        revealedCells.removeAll()
        
        // Generate pairs (level + 1 pairs)
        let pairCount = level + 1
        var usedIndices = Set<Int>()
        
        for _ in 0..<pairCount {
            if usedIndices.count >= gridSize * gridSize { break }
            let pattern = Int.random(in: 0...5)
            
            // Find available positions
            let available = (0..<gridSize*gridSize).filter { !usedIndices.contains($0) }
            guard available.count >= 2 else { break }
            
            // Assign pattern to two random positions
            let chosen = available.shuffled().prefix(2)
            for pos in chosen {
                usedIndices.insert(pos)
                let row = pos / gridSize
                let col = pos % gridSize
                grid[row][col].pattern = pattern
            }
        }
    }
    
    private func revealPatternsTemporarily() {
        // Show all patterns briefly to exercise memory
        showAllPatterns = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(patternRevealDuration)) {
            // Hide them again
            withAnimation {
                showAllPatterns = false
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeRemaining = maxTimePerLevel
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                
                // Game ends
                gameActive = false
                // Once the time is up, reflect the score in the universal score
                universalScore += score
            }
        }
    }
    
    private func cellTapped(row: Int, column: Int) {
        let index = row * gridSize + column
        
        // If user already revealed the cell, ignore
        if revealedCells.contains(index) { return }
        
        // Toggling tapped state, but also handle selection logic for matching
        if selectedCells.contains(index) {
            selectedCells.remove(index)
        } else {
            selectedCells.insert(index)
        }
        
        if selectedCells.count == 2 {
            checkMatch()
        }
    }
    
    private func checkMatch() {
        let selectedArray = Array(selectedCells)
        guard selectedArray.count == 2 else { return }
        
        let firstIndex = selectedArray[0]
        let secondIndex = selectedArray[1]
        
        let firstCell = cellFromIndex(firstIndex)
        let secondCell = cellFromIndex(secondIndex)
        
        // If they match
        if firstCell.pattern == secondCell.pattern && firstCell.pattern != nil {
            score += 100
            revealedCells.insert(firstIndex)
            revealedCells.insert(secondIndex)
            
            // Check if level is completed
            if isLevelComplete() {
                level += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    nextLevel()
                }
            }
        }
        
        // Delay to show both tapped cells briefly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            selectedCells.removeAll()
        }
    }
    
    private func cellFromIndex(_ index: Int) -> PatternCell {
        let row = index / gridSize
        let col = index % gridSize
        return grid[row][col]
    }
    
    private func isLevelComplete() -> Bool {
        // If all patterns for this level (2 * (level + 1) cells) are revealed, level is done
        let totalPatternedCells = 2 * (level + 1)
        return revealedCells.count >= totalPatternedCells
    }
}

struct PatternCell {
    var pattern: Int? = nil
}

struct PatternCellView: View {
    let cell: PatternCell
    let showPattern: Bool
    let isTapped: Bool
    
    var body: some View {
        ZStack {
            let baseColor = Color(hex: "#bcebf2")
            let highlightColor = Color(hex: "#f5d442")
            
            RoundedRectangle(cornerRadius: 8)
                .fill(isTapped ? highlightColor : (showPattern ? Color(hex: "#02fcee") : baseColor))
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "#013640"), lineWidth: 2)
                )
            
            if showPattern, let pattern = cell.pattern {
                Text("\(pattern)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "#013640"))
            }
        }
    }
}

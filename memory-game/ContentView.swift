//
//  ContentView.swift
//  memory-game
//
//  Created by Nene Wang  on 3/23/24.
//


import SwiftUI

// Define a model for the Card
struct Card: Identifiable {
    var id: Int
    var content: String
    var isFlipped: Bool = false
    var isMatched: Bool = false
}



func generateCards(pairs: Int = 3) -> [Card]{
    if(pairs == 3)
    {
        return [
            Card(id: 1, content: "🐶"),
            Card(id: 2, content: "🐱"),
            Card(id: 3, content: "🐭"),
            Card(id: 4, content: "🐶"),
            Card(id: 5, content: "🐱"),
            Card(id: 6, content: "🐭")
        ].shuffled()
    }else{
        
        return [
            Card(id: 1, content: "🐶"),
            Card(id: 2, content: "🐱"),
            Card(id: 3, content: "🐭"),
            Card(id: 4, content: "🐶"),
            Card(id: 5, content: "🐱"),
            Card(id: 6, content: "🐭"),
            
            Card(id: 7, content: "🐼"),
            Card(id: 8, content: "🐼"),
            Card(id: 9, content: "🦊"),
            Card(id: 10, content: "🦊"),
            Card(id: 11, content: "🐻"),
            Card(id: 12, content: "🐻"),
        ].shuffled()
    }
}

struct ConfettiView: View {
    var body: some View {
        ZStack {
            ForEach(0..<100, id: \.self) { _ in
                Circle()
                    .foregroundColor(Color(hue: Double.random(in: 0...1), saturation: 1, brightness: 1))
                    .scaleEffect(CGFloat.random(in: 0.1...0.5))
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                    .animation(Animation.easeOut(duration: 1).repeatForever().delay(Double.random(in: 0...1)), value: UUID())
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            }
        }
    }
}


// ContentView with a basic grid of cards
struct ContentView: View {
    
    @State private var cards: [Card] = generateCards()// Shuffle the cards for the game start
    @State private var numberOfPairs: Int = 3
    @State private var selectedPairs: Int = 3
    
    @State private var showingConfetti = false

    
    @State private var firstSelectedCardIndex: Int? = nil
    

    
    var body: some View {
        
        VStack {
            
            Spacer().frame(height: 20)

            HStack {
                Button("Reset Game") {
                    resetGame()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Picker("Number of Pairs", selection: $selectedPairs) {
                    Text("3 Pairs").tag(3)
                    Text("6 Pairs").tag(6)
                }
                .pickerStyle(DefaultPickerStyle())
                .onChange(of: selectedPairs){
                    _ in
                    resetGame()
                }
            }
            .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(cards) { card in
                        CardView(card: card)
                            .onTapGesture {
                                flipCard(card)
                            }
                    }
                }
                .padding()
            }
            if showingConfetti {
                ConfettiView().transition(.opacity).onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showingConfetti = false
                    }
                }
            }
            Spacer().frame(height: 20)
        }

        
    }
    
    func flipCard(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFlipped.toggle()
            
            // Check for match if this is the second card flipped
            if let firstIndex = firstSelectedCardIndex, firstIndex != index {
                // Check if cards match
                if cards[firstIndex].content == card.content {
                    cards[firstIndex].isMatched = true
                    cards[index].isMatched = true
                    withAnimation { showingConfetti = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.showingConfetti = false }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        cards[firstIndex].isFlipped = false
                        cards[index].isFlipped = false
                    }
                }
                firstSelectedCardIndex = nil // Reset for next selection
            } else {
                firstSelectedCardIndex = index // First card flipped
            }
        }
    }
    
    
    func resetGame() {
        // Resets the game by shuffling the cards and resetting their state
        cards = generateCards(pairs: selectedPairs)
    }
    
}

// A view representing a single card
struct CardView: View {
    var card: Card
    
    var body: some View {
           ZStack {
               if card.isFlipped {
                   if card.isMatched {
                       Color.clear // Make matched cards disappear by showing a clear color
                   } else {
                       Text(card.content)
                   }
               } else {
                   Rectangle()
                       .fill(Color.blue)
                       .cornerRadius(10)
               }
           }
           .frame(width: 100, height: 170)
           .opacity(card.isMatched ? 0 : 1) // Set opacity to 0 if matched, making the card disappear
           .shadow(radius: card.isMatched ? 2 : 5) // Remove shadow for matched cards
       }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


#Preview {
    ContentView()
}

//
//  StudyTopicView.swift
//  LearnAlert
//
//  Created by Blake Miller on 3/27/24.
//

import SwiftUI

enum Side {
    case front, back
}

struct CardView: View {
    public let card: Card
    @Binding public var side: Side
    private var sideData: CardSide {
        switch side {
        case .front:
            return card.front
        case .back:
            return card.back
        }
    }
    
    @State private var isFlipped: Bool = false
    
    func toggleSide() {
        // Trigger the animation
        withAnimation(.easeInOut(duration: 0.8)) {
            isFlipped.toggle()
        }
        // Delay the side toggle to the midpoint of animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            side = side == .front ? .back : .front
        }
    }

    var body: some View {
        Button(action: toggleSide) {
            VStack {
                Spacer()
                VStack(alignment: .center) {
                    Text(sideData.text)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color(uiColor: .label))
                      
                        .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
                    if let data = sideData.image, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
                           
                    }
                }
                .padding()
                Spacer()
            }
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
         //   .border(Color.white)
            // Rotate the card container
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        }
        .buttonStyle(.plain)
        .padding()
    }
}



struct StudyTopicView: View {
    @State private var cardIndex: Int
    @State private var side: Side
    @State private var cards: [Card]
    
    init(cards: [Card]) {
        self.cardIndex = 0 // Guaranteed to contain atleast 1 card, since this view isn't accessible otherwise.
        self.side = .front
        self.cards = cards
    }
    
    var body: some View {
        VStack {
            CardView(card: cards[cardIndex], side: $side)
            Text("Tap card to flip.")
                .font(.headline)
            HStack {
                    Button(action: {
                        cardIndex -= 1
                        side = .front
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .bold()
                    }
                    .disabled(cardIndex == 0)
                Spacer()
                Button(action: {
                    cardIndex += 1
                    side = .front
                }) {
                    Image(systemName: "arrow.right")
                        .font(.title)
                        .bold()
                }
                .disabled(cardIndex == cards.count-1)
            }
            .padding()
        }
        .onAppear {
            cards.shuffle()
        }
        .padding()
    }
}


//
//  DeckListView.swift
//  LearnAlert
//
//  Created by Blake Miller on 3/27/24.
//

import SwiftUI
import SwiftData

extension Color {
    static let customDarkGray = Color(red: 0.25, green: 0.25, blue: 0.25)
}

struct ClearButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.clear)
    }
}

struct DeckListView: View {
  
    @Query private var decks: [Deck]
    @State private var isSearching = false
    @State private var search = ""
    @FocusState private var searchbarFocused: Bool
    @State private var isOptionsPresented = false

    private func startSearching() {
        isSearching = true
        searchbarFocused = true
    }
    
    private func stopSearching() {
        isSearching = false
        searchbarFocused = false
        search = ""
    }
    
    private func filterDecksFromSearch() -> [Deck] {
        decks.filter { deck in
            deck.name.lowercased().hasPrefix(search.lowercased())
        }
        .sorted {
            $0.order > $1.order
        }
    }
    
    private func makeToolbarContent() -> some ToolbarContent {
        Group {
            if isSearching {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: stopSearching) {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.primary)
                            .bold()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    TextField("Search", text: $search)
                        .focused($searchbarFocused)
                        .onDisappear(perform: stopSearching)
                }
            } else {
               // ToolbarItem(placement: .topBarLeading) {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: startSearching) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.primary)
                            .bold()
                    }
                }
            }
        }
    }

    @State private var navigateToCustomizeView = false
    private func makeDeckListOrPlaceholder() -> some View {
        GeometryReader { geometry in
            VStack {
                // The "Customize Deck" button at the top
                NavigationLink(destination: DeckCustomizeView(onFinishCustomizing: .makeDeck)) {
                    makeFloatingButtonContent()
                }//.buttonStyle(ClearButtonStyle())
                .buttonStyle(PlainButtonStyle())
                   
                .padding(.top)
                .padding(.horizontal)

                ZStack {
                    if decks.isEmpty {
                        Text("Press the + Button to create a Study Set.")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 50)
                            .frame(width: geometry.size.width, height: 400, alignment: .center)
                            .offset(y: -20)
                            .opacity(0.3)
                            .multilineTextAlignment(.center)
                    } else {
                        if filterDecksFromSearch().isEmpty {
                            Text("No Search Results")
                                .bold()
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                        } else {
                            List {
                                ForEach(filterDecksFromSearch()) { deck in
                                    DeckView(deck: deck)
                                        .frame(height: 150)
                                }
                                .onMove(perform: { indices, newOffset in
                                    // Handle the move logic here
                                })
                                .moveDisabled(isSearching)
                            }
                            .frame(height: 700) // Adjust as needed
                            .listRowInsets(EdgeInsets())
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
            }
        }
    }

    
    private func makeFloatingButtonContent() -> some View {
        Text("+")
            .font(.system(size: 30))
            .offset(y: -2)
            .frame(height: 20) // Define the height of the button
            .frame(maxWidth: .infinity)
            .bold()
            .foregroundColor(Color.gray)
            .padding()
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.customDarkGray, lineWidth: 2.4)
            )
            .padding(.horizontal)
            .offset(y: 10)
         
    }

    var body: some View {
        NavigationStack {
            makeDeckListOrPlaceholder()
            .navigationDestination(for: Deck.self) { deck in
                TopicListView(deck: deck, currentTopic: deck.getRecentlyAddedTopic())
            }
            .navigationTitle("Decks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(decks.isEmpty ? .hidden : .visible, for: .navigationBar)
            .toolbar(content: makeToolbarContent)
        }
    }
}

@MainActor
class PreviewHandler {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Deck.self, configurations: config)
            
            let modelDeck = Deck(name: "Welcome to LearnAlert!", colorIndex: 0, image: UIImage(resource: .example).pngData(), order: 0)
            
            container.mainContext.insert(modelDeck)
            
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}

#Preview("Light") {
    return MainTabView()
        .preferredColorScheme(.dark)
        .modelContainer(PreviewHandler.previewContainer)
}

#Preview("Dark") {
    return MainTabView()
        .preferredColorScheme(.dark)
        .modelContainer(PreviewHandler.previewContainer)
}

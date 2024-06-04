//
//  SwiftUIView.swift
//  LearnAlert
//
//  Created by Blake Miller on 3/27/24.
//

import SwiftUI
import PhotosUI
import SwiftData
import PhotosUI

// Helper extension to perform actions on Color changes
extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
let DECK_COLORS: [Color] = [
    .clear, .gray, .pink, .red, .brown, .orange, .yellow, .green, .teal, .blue, .indigo, .purple
]


let PRESET_DECK_IMAGES: [ImageResource] = [
    .ps1, .ps2, .ps3, .ps4, .ps5, .ps6, .ps7, .ps8, .ps9, .ps10
]

private let DECK_NAME_LIMIT = 40


struct DeckCustomizeView: View {
    @State private var useGradient = false
    @State private var selectedColor: Color = .blue
    @State private var gradientColors: [Color] = [.red, .blue]
    
    
    
    @State private var name: String = ""
    @State private var colorIndex: Int = 0 // Set "no color" as default
    @State private var imageData: Data? = nil
    @State private var isPresetPhotosPresented: Bool = false
    @State private var photoItem: PhotosPickerItem?
    @State private var isImageSelected = false
    
    
    private var image: Image? {
        guard let imageData, let uiImage = UIImage(data: imageData) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    @Query private var decks: [Deck]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var nameFieldFocused: Bool
    
    enum OnFinishCustomizing: Equatable {
        case makeDeck
        case changeDeck(_ deck: Deck)
    }
    var onFinishCustomizing: OnFinishCustomizing
    
    private func finishCustomizing() {
        dismiss()
        switch onFinishCustomizing {
        case .makeDeck:
            
            let newDeck = Deck(name: name, colorIndex: colorIndex, image: imageData, order: decks.count)
            modelContext.insert(newDeck)
        case .changeDeck(let deck):
            deck.name = name
            deck.colorIndex = colorIndex
            deck.image = imageData
        }
    }
    
    
    
    private func asyncLoadPhotoToData() {
        Task {
            if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                photoItem = nil
                imageData = data
            }
        }
    }
    
    private func clearImage() {
        photoItem = nil
        imageData = nil
        colorIndex = 0 // Reset to "no color" when image is cleared
    }
    
    private func selectPresetImage(_ resource: ImageResource) {
        imageData = UIImage(resource: resource).pngData()
        isPresetPhotosPresented = false
    }
    
    private func makeToolbarContent() -> any ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                finishCustomizing()
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
    
    private func makeColorSelectionView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(DECK_COLORS.indices, id: \.self) { index in
                    Button(action: {
                        self.colorIndex = index
                        self.selectedColor = DECK_COLORS[index]
                    }) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(DECK_COLORS[index])
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(colorIndex == index ? Color.white : Color.clear, lineWidth: 3)
                            )
                    }.buttonStyle(ClearButtonStyle())
                    .padding(4)
                }
            }
        }
        .padding(.vertical)
    }

    // Function to find the index of the selected color and update `colorIndex`
    private func updateIndex(newColor: Color) {
        if let index = DECK_COLORS.firstIndex(of: newColor) {
            colorIndex = index
        }
    }




    
    private func makePresetPhotosSheet() -> some View {
        VStack {
            Button("Close") { isPresetPhotosPresented = false }
                .padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(PRESET_DECK_IMAGES, id: \.self) { resource in
                        Button(action: { selectPresetImage(resource) }) {
                            Image(resource)
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fit) // Maintain landscape aspect ratio without cropping
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    
    
    
    private func saveDeck(name: String, colorHex: String, imageData: Data?) {
        
        print("Saving Deck with Name: \(name), Color: \(colorHex), Image Data: \(String(describing: imageData))")
        
        dismiss()
    }
    
    
   
        
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Deck Details")) {
                        TextField("Deck Name", text: $name)
                        makeColorSelectionView()
                        // MARK: COLOR PICKER DISABLED, DATA NOT PROCESSING
                    //    ColorPicker("Custom Color", selection: $selectedColor.onChange(updateIndex)).opacity(0.3).disabled(true)
                        ///same with preview
                        /// Gradient will be disabled until implemented
                        /**
                         Toggle("Use Gradient", isOn: .constant(false))
                         .disabled(true)
                         .foregroundColor(.gray)
                         */
                    }
                    
                    Section(header: Text("Customize")) {
                        HStack(spacing: 10) {
                            PresetButton(isPresented: $isPresetPhotosPresented, onPresetSelected: { selectedResource in
                                selectPresetImage(selectedResource)
                            }).buttonStyle(PlainButtonStyle())
                            
                            
                            Section() {
                                PhotosPicker(selection: $photoItem, matching: .images) {
                                    Label("Custom", systemImage: "photo")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .buttonStyle(PlainButtonStyle())
                                        .foregroundColor(.white)
                                }
                                .onReceive([self.photoItem].publisher.first()) { _ in
                                    asyncLoadPhotoToData()
                                }
                            }
                            
                            /**
                             HStack(spacing: 6) {
                             Button(action: {}) { // This button does nothing when tapped
                             HStack {
                             Image(systemName: "photo.fill")
                             Text("Custom")
                             }
                             .padding()
                             .frame(maxWidth: .infinity)
                             .background(Color.gray.opacity(0.1)) // Greyed out appearance
                             .clipShape(RoundedRectangle(cornerRadius: 8))
                             }
                             .disabled(false) // This disables the button
                             }
                             .padding(.horizontal)
                             **/
                        }
                    }
                    if let image = image {
                        Section(header: Text("Selected Image")) {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                            
                            Button("Clear Image") {
                                clearImage()
                            }
                            .padding()
                        }
                    }
                    
                    Section(header: Text("Preview")) {
                        DeckBackground(useGradient: useGradient, selectedColor: selectedColor, gradientColors: gradientColors, selectedImage: image)
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding()
                        
                    }
                    
                }
                
            }
            
            
            
            
            
            
            
            .navigationTitle("Create Deck")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        finishCustomizing()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            
        }
    }

    
    struct PresetButton: View {
        @Binding var isPresented: Bool
        var onPresetSelected: (ImageResource) -> Void // Closure to call when a preset is selected

        
        var body: some View {
            Button(action: {
                isPresented = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Presets")
                }
                
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .sheet(isPresented: $isPresented) {
                VStack {
                    Button("Close") {
                        isPresented = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                            ForEach(PRESET_DECK_IMAGES, id: \.self) { resource in
                                Button(action: { onPresetSelected(resource) }) { // Pass 'resource' to the closure
                                    Image(resource)
                                        .resizable()
                                        .aspectRatio(16/9, contentMode: .fit)
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                        .clipped()
                                        .cornerRadius(8)
                                }

                            }
                        }
                    }
                }
                .padding()
            }
        }
    }



struct DeckBackground: View {
    let useGradient: Bool
    let selectedColor: Color
    let gradientColors: [Color]
    let selectedImage: Image? // Optional Image

    var body: some View {
        ZStack {
            // Background color or gradient
            if useGradient {
                LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
            } else {
                selectedColor
            }
            
            // Overlay image if available
            selectedImage?
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        }
    }
}


#Preview("Dark") {
    NavigationStack {
        DeckCustomizeView(onFinishCustomizing: .makeDeck)
       
             .preferredColorScheme(.dark)
    }
}

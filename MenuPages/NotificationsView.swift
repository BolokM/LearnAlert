//
//  NotificationsView.swift
//  LearnAlert
//
//  Created by Blake Miller on 3/27/24.
//

import SwiftUI
import UserNotifications
import SwiftData
import UIKit
class NotificationsSettings: ObservableObject {
    @Published var notificationsEnabled: Bool = false
}

struct NotificationsView: View {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var settings = NotificationsSettings()

    @Query private var decks: [Deck]
    @State private var selectedDeckName: String = "None"
    @State private var selectedInterval: TimeInterval = 10 * 60
    @State private var logMessage: String? = nil
    @State private var isPressed = false
    @State private var showAlert = false
    @State private var alertMessage = ""
 
    
    
    
    let intervals = ["10m", "30m", "1h", "2h", "3h", "4h", "5h", "12h", "1d", "5s (TEST BUTTON)"]

    var body: some View {
        NavigationView {
            Form {
                
          
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $settings.notificationsEnabled)
                }

                Section(header: Text("Select Study Set")) {
                    Picker("Select Study Set", selection: $selectedDeckName) {
                        Text("None").tag("None")
                        ForEach(decks.map { $0.name }, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                }
                
                Section(header: Text("Select Flashcard Order")) {
                    Picker("Select Flashcard Order", selection: $selectedDeckName) {
                        Text("Random").tag("Random")
                        Text("In Order").tag("InOrder")
                       // ForEach(decks.map { $0.name }, id: \.self) { name in
                       //     Text(name).tag(name)
                       // }
                    }
                }

                Section(header: Text("Interval")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(intervals, id: \.self) { interval in
                                Button(action: {
                                    self.selectedInterval = intervalInSeconds(from: interval) ?? 10
                                }) {
                                    Text(interval)
                                        .padding()
                                        .foregroundColor(selectedInterval == intervalInSeconds(from: interval) ? .white : .blue)
                                        .background(selectedInterval == intervalInSeconds(from: interval) ? Color.blue : Color.customDarkGray)
                                        .cornerRadius(10)
                                }.buttonStyle(ClearButtonStyle())
                            }
                        }
                    }
                }

          //      if settings.notificationsEnabled && selectedDeckName != "None" {
                       Button(action: {
                           self.isPressed = true
                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                               self.isPressed = false
                               self.scheduleFlashcards()
                           }
                       }) {
                           Text("Schedule Flashcards")
                             //  .padding()
                            //   .background(isPressed ? Color.blue.opacity(0.5) : Color.blue)
                               .foregroundColor(isPressed ? Color.blue.opacity(0.5) : Color.blue)
                               .cornerRadius(10)
                              
                               .scaleEffect(isPressed ? 0.9 : 1.0) // Animate scale
                            
                       }   .frame(minWidth: 0, maxWidth: .infinity)
                       .animation(.easeOut(duration: 0.1), value: isPressed) // Apply smooth transition animation
             //      }
               
        /**        if settings.notificationsEnabled && selectedDeckName != "None" {
                    Button("Schedule Flashcards"){
                            scheduleFlashcards()
                        }  .scaleEffect(isPressed ? 0.9 : 1.0) // Reduces the scale when pressed
                        .animation(.easeOut(duration: 0.2), value: isPressed) // Smooth transition for the scale effect
                            //Text("Schedule Flashcards")
                          //      .padding()
                            //   .background(isPressed ? Color.customDarkGray.opacity(0.5) : Color.customDarkGray)
                         //       .foregroundColor(.white)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                              .onChanged({ _ in self.isPressed = true })
                                .onEnded({ _ in self.isPressed = false })
                       )
                        
                        }
         */
                    
                

                if let logMessage = logMessage {
                    Text(logMessage)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
             //       if let timeRemaining = timerManager.timeRemaining {
           //             Text("Next notification in \(Int(timeRemaining)) seconds")
              //              .font(.caption)
              //              .foregroundColor(.gray)
               //     }
                }
            }    
            .alert(isPresented: $showAlert) {  // This is how you properly use the alert modifier
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Notification Settings")
        }
        .onAppear {
            NotificationHandler.shared.requestNotificationPermission { granted in
                print("Notification permission granted: \(granted)")
            }
        }
        .task(id: settings.notificationsEnabled) {
            print("Notifications toggled: \(settings.notificationsEnabled)")
            if !settings.notificationsEnabled {
                timerManager.stopTimer()
                NotificationHandler.shared.cancelAllNotifications()
                logMessage = nil
            }
        }
    }

    private func scheduleFlashcards() {
        
        
            guard let deck = decks.first(where: { $0.name == selectedDeckName }),
                  selectedDeckName != "None" else {
                print("No deck selected or deck not found")
                return
            }
            
            let cardCountdupe = deck.topics.reduce(0) { $0 + $1.cards.count }
            if cardCountdupe <= 1 {
                alertMessage = "Cannot schedule flashcards for a deck with 1 or fewer flashcards."
                showAlert = true
                return
            }
        
        guard let deck = decks.first(where: { $0.name == selectedDeckName }),
              selectedDeckName != "None" else {
            print("No deck selected or deck not found")
            return
        }
        let cardCount = deck.topics.reduce(0) { $0 + $1.cards.count }
        logMessage = "Scheduled \(cardCount) Cards in \"\(deck.name)\" on a \(intervalString(from: selectedInterval)) interval"
        
        timerManager.startTimer(interval: selectedInterval, selectedInterval: selectedInterval)

        var notificationTime = Date()
        for topic in deck.topics {
            for card in topic.cards {
                NotificationHandler.shared.scheduleCardNotification(frontText: card.front.text, backText: card.back.text, at: notificationTime)
                notificationTime.addTimeInterval(selectedInterval)
            }
        }
    }


    private func intervalInSeconds(from intervalString: String) -> TimeInterval? {
        switch intervalString {
        case "10m": return 10 * 60
        case "30m": return 30 * 60
        case "1h": return 60 * 60
        case "2h": return 2 * 60 * 60
        case "3h": return 3 * 60 * 60
        case "4h": return 4 * 60 * 60
        case "5h": return 5 * 60 * 60
        case "12h": return 12 * 60 * 60
        case "1d": return 24 * 60 * 60
        case "5s": return 5
        default: return nil
        }
    }
    
    private func intervalString(from interval: TimeInterval) -> String {
        switch interval {
        case 10 * 60: return "10m"
        case 30 * 60: return "30m"
        case 60 * 60: return "1h"
        case 2 * 60 * 60: return "2h"
        case 3 * 60 * 60: return "3h"
        case 4 * 60 * 60: return "4h"
        case 5 * 60 * 60: return "5h"
        case 12 * 60 * 60: return "12h"
        case 24 * 60 * 60: return "1d"
        case 5: return "5s"
        default: return "\(Int(interval))s"
        }
    }
    
    func setupNotificationObserver() {
        NotificationHandler.shared.stopIntervalCallback = { [self] in
            // Set logMessage to nil or handle as needed
            self.logMessage = nil
        }
    }
    
}



#Preview {
    NotificationsView()
}

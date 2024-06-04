//
//  NotificationHandler.swift
//  LearnAlert
//
//  Created by Blake Miller on 3/29/24.
//

import UserNotifications
import SwiftUI
import SwiftData
import UIKit


// MARK: MAIN NotificationHandler
class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationHandler()
    
    let timerManager: TimerManager = TimerManager() // Initialize timerManager
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationActions()  // Set up notification actions when initializing
    }
    
    // Define a closure type for the callback
    var stopIntervalCallback: (() -> Void)?
    
    // Function to call when stop interval action is performed
    func stopIntervalAction() {
        // Stop the timer and cancel notifications
        timerManager.stopTimer()
        cancelAllNotifications()
        
        // Call the callback if it's set
        stopIntervalCallback?()
    }


    // MARK: Request Notification Permission
    func requestNotificationPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                print("Notification permission requested. Granted: \(granted)")
                completion(granted)
            }
        }
    }

    // MARK: Setup Notification Actions
    private func setupNotificationActions() {
        let gotItAction = UNNotificationAction(identifier: "gotIt-action", title: "A", options: [.foreground])
        let notsureAction = UNNotificationAction(identifier: "notsure-action", title: "B", options: [.foreground])
        let reviewAction = UNNotificationAction(identifier: "review-action", title: "C", options: [.foreground])
        let adjustAction = UNNotificationAction(identifier: "adjust-action", title: "Adjust Interval", options: [.foreground])

        let category = UNNotificationCategory(identifier: "flashcard-actions", actions: [gotItAction, notsureAction, reviewAction, adjustAction], intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: Schedule Card Notification


    func scheduleCardNotification(frontText: String, backText: String, at time: Date) {
        // 1. Generate the image with backText
        guard let image = generateImageWithText(backText) else { return }

        // 2. Save the image temporarily
        guard let imageURL = saveImageTemporarily(image) else { return }

        // 3. Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "LearnAlert"
        content.body = frontText
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "betaringtone.m4a"))
        content.categoryIdentifier = "flashcard-actions"

        // 4. Create an attachment
        if let attachment = try? UNNotificationAttachment(identifier: UUID().uuidString, url: imageURL, options: nil) {
            content.attachments = [attachment]
        }

        // 5. Create a trigger and schedule the notification
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled with image at \(time)")
            }
        }
    }

    // Function to generate an image with text
    func generateImageWithText(_ text: String) -> UIImage? {
        let size = CGSize(width: 320, height: 200)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        // Set up the black background
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.black.cgColor) // Set the fill color to black
        context?.fill(CGRect(origin: .zero, size: size)) // Fill the entire image area with black

        // Set up the text attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.white // Change color to white
        ]

        // Calculate text size and position
        let textSize = text.size(withAttributes: attributes)
        let rect = CGRect(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        text.draw(in: rect, withAttributes: attributes) // Draw the text

        return UIGraphicsGetImageFromCurrentImageContext() // Retrieve the image from the context
    }



    // Function to save the image temporarily
    func saveImageTemporarily(_ image: UIImage) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let imageURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")

        guard let imageData = image.pngData() else { return nil }
        try? imageData.write(to: imageURL)

        return imageURL
    }


    // MARK: Cancel All Notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: Handle Notification Actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier

        switch actionIdentifier {
    //    case "gotIt-action":
   //         print("User selected 'Got it!'")
            // Handle 'Got it!' action here
    //    case "notsure-action":
    //        print("User selected 'not sure'")
            // Handle 'Got it!' action here
       case "review-action":
       print("User selected 'review'")
        
        case "adjust-action":
            print("User selected 'stopinterval'")
            timerManager.stopTimer()
            NotificationHandler.shared.cancelAllNotifications()
            //logMessage = nil
        default:
            break
        }

        completionHandler()
    }
}

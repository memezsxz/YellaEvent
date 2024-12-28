//
//  PushNotificationService.swift
//  YellaEvent
//
//  Created by Ahmed Ali on 27/12/2024.
//

import Foundation
import UserNotifications

class PushNotificationService {
    
    /// Static function to show a local notification
    /// - Parameters:
    ///   - title: The title of the notification
    ///   - description: The body or description of the notification
    static func showNotification(title: String, description: String) {
        // Ensure notifications are authorized
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("Notifications are not authorized")
                return
            }
            
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = description
            content.sound = .default
            
            // Set a trigger to show the notification immediately
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            // Create a unique identifier for the request
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            // Add the notification request
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error showing notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled: \(title)")
                }
            }
        }
    }
}

//
//  NotificationManager.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 10/20/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import UserNotifications

@objcMembers
public class NotificationManager: NSObject {
    
    // Check and request notification permission
    @objc public static func checkAndRequestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        
        // Check current notification settings
        center.getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    // If permission hasn't been requested yet, request permission for alerts and sounds
                    center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                        if granted {
                            print("Notification permission granted.")
                        } else {
                            print("Notification permission denied.")
                        }
                    }
                } else if settings.authorizationStatus == .denied {
                    print("Notification permission was previously denied.")
                } else if settings.authorizationStatus == .authorized {
                    print("Notification permission already granted.")
                }
            }
        }
    }
    
    // Schedule a local notification
    @objc public static func scheduleNotification(title: String, message: String, soundName: String?, date: Date, userInfo: Dictionary<String, Any>) {
        let center = UNUserNotificationCenter.current()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.userInfo = userInfo
        
        // Set the sound: If soundName is nil, use default sound
        if let soundName = soundName {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        } else {
            content.sound = UNNotificationSound.default
        }
        
        // Trigger notification at a specific date
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create the request with a unique identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Schedule the notification
        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
    
    // Method to cancel pending notifications that match a specific userInfo key-value pair
    @objc public static func cancelPendingNotification(matchingUserInfo userInfoKey: String, value: String) {
        let center = UNUserNotificationCenter.current()
        
        // Fetch all pending notification requests
        center.getPendingNotificationRequests { (requests) in
            for request in requests {
                if let userInfo = request.content.userInfo as? [String: Any] {
                    // Check if the userInfo contains the matching key and value
                    if let userInfoValue = userInfo[userInfoKey] as? String, userInfoValue == value {
                        // Cancel the notification with the matching identifier
                        center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                        print("Cancelled notification with identifier: \(request.identifier)")
                    }
                }
            }
        }
    }
    
    // Cancel all notifications
    @objc public static func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        
        // Remove all pending notifications
        center.removeAllPendingNotificationRequests()
        
        // Remove all delivered notifications
        center.removeAllDeliveredNotifications()
        
        print("All notifications have been cancelled.")
    }
}

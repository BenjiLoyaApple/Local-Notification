# SwiftUI Local Notifications Example

This project provides a comprehensive example of how to implement and use different types of local notifications in SwiftUI. It serves as a reference guide for developers who want to integrate local notifications into their own projects.

## Features

- **Immediate Notifications**: Trigger notifications to be delivered immediately.
- **Scheduled Notifications**: Schedule notifications to be delivered at a specific date and time.
- **Repeating Notifications**: Set up notifications that repeat at regular intervals.
- **Location-Based Notifications**: Trigger notifications based on geographic location.
- **Actionable Notifications**: Include custom actions that users can perform directly from the notification.

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/SwiftUILocalNotificationsExample.git
    ```
2. Open the project in Xcode:
    ```bash
    cd SwiftUILocalNotificationsExample
    open SwiftUILocalNotificationsExample.xcodeproj
    ```

## Usage

1. **Requesting Permission**:
    Before sending notifications, make sure to request user permission:
    ```swift
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Error requesting notification authorization: \(error.localizedDescription)")
        }
        if granted {
            print("Notification permission granted.")
        } else {
            print("Notification permission denied.")
        }
    }
    ```

2. **Scheduling an Immediate Notification**:
    ```swift
    let content = UNMutableNotificationContent()
    content.title = "Immediate Notification"
    content.body = "This notification is triggered immediately."
    content.sound = .default

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request)
    ```

3. **Scheduling a Timed Notification**:
    ```swift
    let content = UNMutableNotificationContent()
    content.title = "Scheduled Notification"
    content.body = "This notification is scheduled to appear at a specific time."
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
    ```

4. **Creating a Repeating Notification**:
    ```swift
    let content = UNMutableNotificationContent()
    content.title = "Repeating Notification"
    content.body = "This notification repeats every day."
    content.sound = .default

    var dateComponents = DateComponents()
    dateComponents.hour = 9
    dateComponents.minute = 0

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
    ```

5. **Location-Based Notification**:
    ```swift
    let content = UNMutableNotificationContent()
    content.title = "Location-Based Notification"
    content.body = "This notification is triggered when entering a specific location."
    content.sound = .default

    let center = CLLocationCoordinate2D(latitude: 37.335400, longitude: -122.009201)
    let region = CLCircularRegion(center: center, radius: 100, identifier: UUID().uuidString)
    region.notifyOnEntry = true
    region.notifyOnExit = false

    let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
    ```

6. **Actionable Notifications**:
    ```swift
    let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Accept", options: .foreground)
    let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION", title: "Decline", options: .destructive)
    let category = UNNotificationCategory(identifier: "ACTION_CATEGORY", actions: [acceptAction, declineAction], intentIdentifiers: [], options: [])

    UNUserNotificationCenter.current().setNotificationCategories([category])

    let content = UNMutableNotificationContent()
    content.title = "Actionable Notification"
    content.body = "This notification has actions."
    content.categoryIdentifier = "ACTION_CATEGORY"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
    ```

## Contributing

Contributions are welcome! If you have any suggestions, bug fixes, or enhancements, please create a pull request or open an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

Special thanks to the Swift community and all contributors to the SwiftUI framework.

---

Feel free to use this project as a reference for implementing local notifications in your SwiftUI applications. Happy coding!

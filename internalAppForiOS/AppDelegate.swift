//
//  AppDelegate.swift
//  internalAppForiOS
//
//  Created by Magtonic on 2021/10/21.
//

import UIKit
import UserNotifications
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    
                }
        UIApplication.shared.registerForRemoteNotifications()
                
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        print("=======>1")
        //Get the push notification when app is not open
        let remoteNotify = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification]
        print("=======>2")
        if (remoteNotify != nil) {
            self.handleRemoteNotification(userInfo: remoteNotify as! NSDictionary)
        } else {
            print("remoteNotify = nil")
        }
        //NSDictionary *remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
        
        //if(remoteNotif){
        //    [self handleRemoteNotification:application userInfo:remoteNotif];
        //} else {
        //    NSLog(@"remoteNotif = null");
        //}
        Messaging.messaging().subscribe(toTopic: "topic") { error in
          print("Subscribed to test topic")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to get token, error: %s", error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //[[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
        let deviceTokenString = deviceToken.reduce("") {
            $0 + String(format: "%02x", $1)
        }
        print("deviceToken", deviceTokenString)
        Messaging.messaging().apnsToken = deviceToken
        
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                       -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
              print("Message ID: \(messageID)")
        }

        // Print full message.
        //print(userInfo)
        
        if let aps = userInfo["aps"] as? NSDictionary {
            //print("===>1")
            if let alert = aps["alert"] as? NSDictionary {
                //print("===>2")
                //print(alert)
                if let title = alert["title"] as? NSString {
                   //Do stuff
                    print(title)
                }
                if let body = alert["body"] as? NSString {
                    //Do stuff
                    print(body)
                }
            } 
        }
        
        //NSString *title = [userInfo objectForKey:@"title"];
        //let title = userInfo["title"] as? String
        //NSLog("title = %s", title!);
        //NSString *body  = [userInfo objectForKey:@"body"];
        //let body = userInfo["body"] as? String
        //NSLog("body = %s", body!);
        //NSInteger badge = [[userInfo objectForKey:@"badge"] integerValue];
        
        NSLog("current badge = %ld", UIApplication.shared.applicationIconBadgeNumber);
        //print("current badge = %ld", UIApplication.shared.applicationIconBadgeNumber)
        
        
        
        //completionHandler(UIBackgroundFetchResultNewData);
        completionHandler(UIBackgroundFetchResult.newData)
        
        /*if (title != nil && body != nil) {
        
            //NSDictionary *notifyDetail = @{@"title": title,
            //                             @"body": body};
        
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self userInfo:nil];
            NotificationCenter.default.post(name: NSNotification.Name("TestNotification"), object: self, userInfo: nil)
        }*/
    }
    func handleRemoteNotification(userInfo: NSDictionary) {
        
        if (userInfo != nil) {
            let sFuncID = userInfo.object(forKey: "notification")
            
            print("title = %s", sFuncID as Any)
        } else {
            print("userInfo = null")
        }
        
        /*
         if(userInfo){
             //TODO: Handle the userInfo here
             NSString *sFuncID = [[userInfo objectForKey:@"notification"] objectForKey:@"title"];
             NSLog(@"title = %@", sFuncID);
             //[[NSUserDefaults standardUserDefaults] setValue:sFuncID forKey:Key_ID_notification];
             //[[NSUserDefaults standardUserDefaults] synchronize];
         } else {
             NSLog(@"userInfo = null");
         }
         */
    }
    

}
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    // ??????????????????????????????
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function)
        let content = response.notification.request.content
        print(content.userInfo)
        completionHandler()
    }
    
    // ??? App ???????????????????????????
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }
}
extension AppDelegate: MessagingDelegate {
   
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("fcm Token", fcmToken ?? "")
        // ??? fcm token ???????????????
    }
}


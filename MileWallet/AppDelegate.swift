//
//  AppDelegate.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

class CameraQR {
    public var payment:(publicKey: String, assets: String?, amount: String?, name: String?)?
    public static var shared = CameraQR()
    private init (){}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    var leftNavigationController:UINavigationController {
        let sc = window?.rootViewController as! UISplitViewController 
        return sc.viewControllers.first as! UINavigationController
    }
    
    var detailNavigationController:UINavigationController {
        let sc = window?.rootViewController as! UISplitViewController 
        return sc.viewControllers.last as! UINavigationController
    }
    
    var masterController:MasterViewController? {
        return leftNavigationController.topViewController as? MasterViewController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let splitViewController = window!.rootViewController as! UISplitViewController
        splitViewController.delegate = self
        
        //let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        leftNavigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        CameraQR.shared.payment = nil
        
        Swift.print(" .... didFinishLaunchingWithOptions")
        

        var isUniversalLinkClick: Bool = false

        if let options = launchOptions {
            if let activityDictionary = options[UIApplicationLaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] {
                isUniversalLinkClick = activityDictionary[UIApplicationLaunchOptionsKey.userActivityDictionary] as? NSUserActivity != nil
            }
        }
        
        if isUniversalLinkClick {
            Swift.print(" UNIVERSAL LINK!!!  ")
            // app opened via clicking a universal link.
        } else {
            // set the initial viewcontroller
        }

        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.wallet == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
    func application(_ application: UIApplication, 
                     continue userActivity: NSUserActivity, 
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
                
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            guard let url = userActivity.webpageURL else {
                return false
            }

                                
            CameraQR.shared.payment = url.absoluteString.qrCodePayment                         

        }
        
        NotificationCenter.default.post(Notification(name: Notification.Name("CameraQRDidUpdate")))
        
        return true
    }

}


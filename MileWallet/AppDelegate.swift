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
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    var navigationController:RootController?
    var viewController:WalletCardsController?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        for n in UIFont.familyNames {
            for f in UIFont.fontNames(forFamilyName: n) {
                print("font: \(n) : \(f)")
            }
        }
        
        UINavigationBar.appearance()
            .titleTextAttributes = [NSAttributedStringKey.foregroundColor: Config.Colors.navigationBarTitle,
                                    NSAttributedStringKey.font: Config.Fonts.navigationBarTitle]

        UINavigationBar.appearance().largeTitleTextAttributes =
            [NSAttributedStringKey.foregroundColor: Config.Colors.navigationBarLargeTitle,
             NSAttributedStringKey.font: Config.Fonts.navigationBarLargeTitle]
        
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Config.Colors.title,
                                     NSAttributedStringKey.font: Config.Fonts.title], for: .normal)
        
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().barStyle = .default
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()

        UIButton.appearance().setTitleColor(Config.Colors.button, for: .normal)
        UIButton.appearance().substituteFont = Config.Fonts.button
        
        UIButton.appearance().adjustsImageWhenHighlighted = true
        UIButton.appearance().showsTouchWhenHighlighted = true
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
        UIPageControl.appearance().hidesForSinglePage = true

        UIApplication.shared.statusBarStyle = .default

        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.backgroundColor = Config.Colors.background
        
        viewController = WalletCardsController()
        
        navigationController = RootController(rootViewController: viewController!)
        
        window?.rootViewController = navigationController;
        window?.makeKeyAndVisible()
        
        return true
    }
}

//@UIApplicationMain
class AppDelegate__: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

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
    
    func application(_ app: UIApplication, open url: URL, 
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Determine who sent the URL. 
        let sendingAppID = options[.sourceApplication]
        
        // Process the URL.
        
        Swift.print("UIApplicationOpenURLOptionsKey : \(sendingAppID), url: \(url)")
        
        let newUrl = url.absoluteString.replacingOccurrences(of: Config.appSchema, with: "https:")
        CameraQR.shared.payment = newUrl.qrCodePayment                         
        NotificationCenter.default.post(Notification(name: Notification.Name("CameraQRDidUpdate")))

        return true
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


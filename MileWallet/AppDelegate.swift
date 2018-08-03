//
//  AppDelegate.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit
import CoreData


public class WalletUniversalLink {
 
    public typealias Invoice = (publicKey: String, assets: String?, amount: String?, name: String?)
    
    public static let kDidUpdateNotification = Notification.Name("CameraQRDidUpdate")
    
    public var invoice:Invoice?
    public static var shared = WalletUniversalLink()
    private init (){}
}

extension UINavigationBar {
    @objc public var substituteTitleColor : [NSAttributedStringKey : Any]? {
        get {
            return largeTitleTextAttributes
        }
        set {
            largeTitleTextAttributes = newValue
        }
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIToolbarDelegate {
    
    
    var window: UIWindow?
    var navigationController:RootController?
    var viewController:WalletsPager?
    
    var passcodeScreen = PasscodeScreen()

    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        for n in UIFont.familyNames {
            for f in UIFont.fontNames(forFamilyName: n){
                print(" ### font [\(n)] ==> \(f)")
            }
        }
        
        Config.url = "https://wallet.testnet.mile.global"
        
        WalletUniversalLink.shared.invoice = nil
        
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

        
        UINavigationBar.appearance()
            .titleTextAttributes = [NSAttributedStringKey.font: Config.Fonts.navigationBarTitle]
      
        UINavigationBar.appearance(whenContainedInInstancesOf: [Controller.self])
            .titleTextAttributes = [NSAttributedStringKey.foregroundColor: Config.Colors.navigationBarTitle]

        UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self])
            .titleTextAttributes = [NSAttributedStringKey.foregroundColor: Config.Colors.navigationBarTitle]

        
        UINavigationBar.appearance().substituteTitleColor =
            [NSAttributedStringKey.foregroundColor: Config.Colors.navigationBarLargeTitle,
             NSAttributedStringKey.font: Config.Fonts.navigationBarLargeTitle]
        
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSAttributedStringKey.font: Config.Fonts.title], for: .normal)

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [Controller.self])
            .setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Config.Colors.title], for: .normal)

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
            .setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Config.Colors.title], for: .normal)

        
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().barStyle = .blackTranslucent
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()

        UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).setTitleColor(UIColor.white, for: .normal)
        UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).substituteFont = Config.Fonts.caption

        UIButton.appearance().setTitleColor(Config.Colors.button, for: .normal)
        UIButton.appearance().adjustsImageWhenHighlighted = true
        UIButton.appearance().showsTouchWhenHighlighted = true
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
        UIPageControl.appearance().hidesForSinglePage = true

        UIApplication.shared.statusBarStyle = .default

        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.backgroundColor = Config.Colors.background
        
        viewController = WalletsPager()

        navigationController = RootController()
        navigationController?.setViewControllers([viewController!], animated: true)

        if PasscodeStrore.shared.isRegistered {
            window?.rootViewController = passcodeScreen
        }
        else {
            window?.rootViewController = navigationController
        }
        window?.makeKeyAndVisible()

        passcodeScreen.didVerifyHandler = { controller in
            
            guard PasscodeStrore.shared.isRegistered else { return }
            
            self.navigationController?.view.alpha = 0

            UIView.animate(withDuration: Config.animationDuration, animations: {
                
                self.passcodeScreen.view.alpha = 0
                
            }, completion: { (flag) in
                
                self.passcodeScreen.removeFromParentViewController()
                
                self.window?.rootViewController = self.navigationController
            
                UIView.animate(withDuration: Config.animationDuration, animations: {
                    
                    self.navigationController?.view.alpha = 1
                    
                }, completion: { (flag) in
                    if WalletUniversalLink.shared.invoice != nil {
                        NotificationCenter.default.post(Notification(name: WalletUniversalLink.kDidUpdateNotification))
                    }
                })
            })
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        guard PasscodeStrore.shared.isRegistered else { return }

        UIView.animate(withDuration: Config.animationDuration, animations: {
            
            self.navigationController?.view.alpha = 0
            
        }) { (flag) in
            self.passcodeScreen.view.alpha = 1
            self.window?.rootViewController = self.passcodeScreen
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if WalletUniversalLink.shared.invoice != nil {
            
            viewController?.removeFromParentViewController()
            navigationController?.removeFromParentViewController()
            navigationController = RootController()
            navigationController?.setViewControllers([viewController!], animated: true)
            
            if PasscodeStrore.shared.isRegistered {
                window?.rootViewController = passcodeScreen
            }
            else {
                window?.rootViewController = navigationController
            }
        }
        else {
            PasscodeScreen.isUnlocked = false
            viewController?.presentPasscodeScreen()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Determine who sent the URL.
        // let sendingAppID = options[.sourceApplication]
        
        // Process the URL.
        let newUrl = url.absoluteString.replacingOccurrences(of: Config.appSchema, with: "https:")
        if let url = URL(string: newUrl) {
            updateUniversalLinkClick(url: url)
        }
        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            guard let url = userActivity.webpageURL else {
                return false
            }
            updateUniversalLinkClick(url: url)
        }
        return true
    }
    
    private func updateUniversalLinkClick(url:URL) {
        if  url.absoluteString.qrCodePayment != nil {
            window?.rootViewController?.dismiss(animated: false)
            navigationController?.popToRootViewController(animated: false)
            WalletUniversalLink.shared.invoice = url.absoluteString.qrCodePayment
        }
   }
}

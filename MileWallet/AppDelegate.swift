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
    
    public typealias Invoice = (
        publicKey: String,
        assets: String?,
        amount: String?,
        name: String?)
    
    public static let kDidUpdateNotification = Notification.Name("WalletIniversalLinkDidUpdate")
    
    public var invoice:Invoice?
    public static var shared = WalletUniversalLink()
    private init (){}
}

extension UINavigationBar {
    @objc public var substituteTitleColor : [NSAttributedString.Key : Any]? {
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
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Config.isWalletKeychainSynchronizable = UserDefaults.standard.bool(forKey: Config.keychainSynchronizable)
        
        //
        //
        // Config.url = "https://wallet.testnet.mile.global"
        //
        
        WalletUniversalLink.shared.invoice = nil
        
        var isUniversalLinkClick: Bool = false
        
        if let options = launchOptions {
            if let activityDictionary = options[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] {
                isUniversalLinkClick = activityDictionary[UIApplication.LaunchOptionsKey.userActivityDictionary] as? NSUserActivity != nil
            }
        }
        
        if isUniversalLinkClick {
            // app opened via clicking a universal link.
        } else {
            // set the initial viewcontroller
        }
        
        
        UINavigationBar.appearance()
            .titleTextAttributes = [NSAttributedString.Key.font: Config.Fonts.navigationBarTitle]
        
        UINavigationBar.appearance(whenContainedInInstancesOf: [Controller.self])
            .titleTextAttributes = [NSAttributedString.Key.foregroundColor: Config.Colors.navigationBarTitle]
        
        UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self])
            .titleTextAttributes = [NSAttributedString.Key.foregroundColor: Config.Colors.navigationBarTitle]
        
        
        UINavigationBar.appearance().substituteTitleColor =
            [NSAttributedString.Key.foregroundColor: Config.Colors.navigationBarLargeTitle,
             NSAttributedString.Key.font: Config.Fonts.navigationBarLargeTitle]
        
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSAttributedString.Key.font: Config.Fonts.title], for: .normal)
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [Controller.self])
            .setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Config.Colors.title], for: .normal)
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
            .setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Config.Colors.title], for: .normal)
        
        
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
        
        //UIApplication.shared.statusBarStyle = .default
        
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
                
                self.passcodeScreen.removeFromParent()
                
                self.window?.rootViewController = self.navigationController
                
                UIView.animate(withDuration: Config.animationDuration, animations: {
                    
                    self.navigationController?.view.alpha = 1
                    
                }, completion: { (flag) in
                    
                    self.passcodeScreen.view.alpha = 1
                    
                    if WalletUniversalLink.shared.invoice != nil {
                        NotificationCenter.default.post(Notification(name: WalletUniversalLink.kDidUpdateNotification))
                    }
                })
            })
        }
        
        return true
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        passcodeScreenTimer?.invalidate()
        passcodeScreenTimer = nil
        becomePasscodeScreen()
    }
    
    
    func becomePasscodeScreen() {
        guard PasscodeStrore.shared.isRegistered else { return }
        self.window?.rootViewController = self.passcodeScreen
    }
    
    func becomeActive()  {
        
        if WalletUniversalLink.shared.invoice != nil {
            
            viewController?.removeFromParent()
            navigationController?.removeFromParent()
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
    
    var passcodeScreenTimer:Timer?
    
    @objc func passcodeScreenTimerHandler(timer:Timer?) {
        timer?.invalidate()
        becomePasscodeScreen()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        passcodeScreenTimer?.invalidate()
        if window?.rootViewController === passcodeScreen {
            return
        }
        passcodeScreenTimer = Timer.scheduledTimer(timeInterval: 10,
                                                   target: self,
                                                   selector: #selector(passcodeScreenTimerHandler(timer:)),
                                                   userInfo: nil,
                                                   repeats: false)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        passcodeScreenTimer?.invalidate()
        becomeActive()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data Saving support    
    func saveContext () {
        let context = Model.shared.context
        if context.hasChanges {
            do {
                try context.save()
            } catch {}
        }
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Determine who sent the URL.
        let sendingAppID = options[.sourceApplication]
        
        // Process the URL.
        let newUrl = url.absoluteString.replacingOccurrences(of: Config.appSchema, with: "https:")
        if let url = URL(string: newUrl) {
            updateUniversalLinkClick(url: url)
        }
        return true
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
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

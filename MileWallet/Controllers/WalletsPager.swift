//
//  WalletCardsController.swift
//  MileWallet
//
//  Created by denn on 23.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import SnapKit
import MileWalletKit

class WalletsPager: Controller {

    public var currentIndex:Int {
        return _currentIndex ?? NSNotFound
    }
        
    static private let networkOn = UIBarButtonItem(customView: UIImageView(image: UIImage(named:"icon-network-on")))
    static private let networkOff = UIBarButtonItem(customView: UIImageView(image: UIImage(named:"icon-network-off")))
    
    override func didNetworkChangeStatus(reachable: Bool) {
        networkState(reachable: reachable)
    }
    
    private func networkState(reachable:Bool) {
        DispatchQueue.main.async {
            if reachable {
                self.navigationItem.rightBarButtonItem = WalletsPager.networkOn
            }
            else {
                self.navigationItem.rightBarButtonItem = WalletsPager.networkOff
            }
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
            
        navigationItem.rightBarButtonItem = WalletsPager.networkOff
        
        contentView.addSubview(newWalletButton)
        contentView.addSubview(archiveButton)
        contentView.addSubview(contactsButton)
        contentView.addSubview(verticalLineLeft)
        contentView.addSubview(verticalLineRight)
        
        var h:CGFloat = 88
            if UIScreen.main.bounds.size.height < 640 {
                    h = 66
            }
        
        verticalLineLeft.snp.makeConstraints { (m) in
            m.centerX.equalTo(contentView.snp.right).multipliedBy(1.0/3.0)
            m.height.equalTo(h)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            m.width.equalTo(1)
        }
        
        verticalLineRight.snp.makeConstraints { (m) in
            m.centerX.equalTo(contentView.snp.right).multipliedBy(2.0/3.0)
            m.height.equalTo(verticalLineLeft.snp.height)
            m.bottom.equalTo(verticalLineLeft.snp.bottom)
            m.width.equalTo(verticalLineLeft.snp.width)
        }
        
        newWalletButton.snp.makeConstraints { (m) in
            m.centerX.equalTo(contentView.snp.right).multipliedBy(1.0/6.0)
            m.top.equalTo(verticalLineLeft.snp.top).offset(15)
            m.bottom.equalTo(verticalLineLeft.snp.bottom).offset(-15)
        }
        
        archiveButton.snp.makeConstraints { (m) in
            m.centerX.equalTo(contentView.snp.right).multipliedBy(5.0/6.0)
            m.centerY.equalTo(newWalletButton.snp.centerY)
            m.bottom.equalTo(newWalletButton.snp.bottom)
        }
        
        contactsButton.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.centerY.equalTo(newWalletButton.snp.centerY)
            m.bottom.equalTo(newWalletButton.snp.bottom)
        }
        
        addChildViewController(pageViewController)
        contentView.addSubview(pageViewController.view)
        
        pageViewController.view.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Config.iPhoneX ? 20 : 0)
            //m.top.equalTo(view).offset(UIApplication.shared.statusBarFrame.size.height)
            m.left.equalTo(contentView).offset(0)
            m.right.equalTo(contentView).offset(0)
            pagerOffset = m.bottom
                .equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .offset(Config.iPhoneX ? -160 : -140)
                .constraint
        }
        
        pageViewController.didMove(toParentViewController: self)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pushDetails(gesture:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        pageViewController.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(universalLinkUpdated(notification:)), name: WalletUniversalLink.kDidUpdateNotification, object: nil)
    }
    
    private func universalLinkOpen() {

        if WalletUniversalLink.shared.invoice?.amount != nil {
            let wallet_name = WalletUniversalLink.shared.invoice?.name ?? WalletUniversalLink.shared.invoice?.publicKey ?? ""
            UIAlertController(title: NSLocalizedString("Invoice", comment: ""),
                              message: NSLocalizedString("Choose Wallet to send coins to: ", comment: "") + wallet_name,
                              preferredStyle: UIAlertControllerStyle.actionSheet)
                .addAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                    WalletUniversalLink.shared.invoice = nil
                }
                .addAction(title: NSLocalizedString("Send", comment: ""), style: .default) { (action) in
                    
                }
                .present(by: self)
        }
        else if  WalletUniversalLink.shared.invoice?.publicKey != nil {
            _walletContacts.walletKey = WalletStore.shared.acitveWallets[currentIndex].wallet?.publicKey
            presentInNavigationController(_walletContacts, animated: true)
        }
    }
    
    @objc private func universalLinkUpdated(notification:Notification) {
        universalLinkOpen()
    }
    
    private var pagerOffset:Constraint?
    
    func updateConstraints()  {
        UIView.animate(withDuration: Config.animationDuration) {
            if WalletStore.shared.archivedWallets.count == 0 {
                if self.viewControllers.first!.isKind(of: EmptyWallet.self) {
                    self.newWalletButton.alpha = 0
                    self.verticalLineLeft.alpha = 0
                    self.verticalLineRight.alpha = 0
                    self.archiveButton.alpha = 0
                }
                else {
                    self.newWalletButton.alpha = 1
                    self.verticalLineLeft.alpha = 1
                    self.verticalLineRight.alpha = 1
                    self.archiveButton.alpha = 1
                }
            }
            
            if self.viewControllers.count > 1 {
                self.pagerOffset?.update(offset: Config.iPhoneX ? -140 : UIScreen.main.bounds.height < 640 ? -90 : -120)
            }
            else {
                self.pagerOffset?.update(offset: Config.iPhoneX ? -160 : UIScreen.main.bounds.height < 640 ? -110  : -140)
            }
        }
    }

    private let verticalLineLeft:UIView = {
        let v = UIView()
        v.backgroundColor = Config.Colors.infoLine
        return v
    }()
    
    private let verticalLineRight:UIView = {
        let v = UIView()
        v.backgroundColor = Config.Colors.infoLine
        return v
    }()
    
    private lazy var newWalletButton:UIButton = UIButton
        .toolBarButton(image: UIImage(named: "button-new-wallet"),
                       title: NSLocalizedString("Add Wallet", comment: ""),
                       target: self, action: #selector(newWallet(sender:)))
    
    private lazy var contactsButton:UIButton = UIButton
        .toolBarButton(image: UIImage(named: "button-contact-book"),
                       title: NSLocalizedString("Contacts", comment: ""),
                       target: self, action:  #selector(openContact(sender:)))
    
    private lazy var archiveButton:UIButton = UIButton
        .toolBarButton(image: UIImage(named: "button-archive-wallets"),
                       title: NSLocalizedString("Archive", comment: ""),
                       target: self, action: #selector(archiveWallet(sender:)))
    
    fileprivate var lastIndex = 0
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lastIndex = _currentIndex ?? 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    ///
    /// Apple does not motivate to use UIPageViewController with dinamic content.
    /// so, TODO: rewrite the part of the code with custom controller.
    ///
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        view.backgroundColor = Config.Colors.background
        contentView.backgroundColor = Config.Colors.background
        
        navigationController?.navigationBar.prefersLargeTitles = false

        var newIndex = lastIndex
        
        if viewControllers.count != WalletStore.shared.acitveWallets.count
        || viewControllers.count == 1 {
            if viewControllers.count < WalletStore.shared.acitveWallets.count {
                newIndex = viewControllers.count
            }
            else if newIndex >= WalletStore.shared.acitveWallets.count {
                newIndex -= 1
                if newIndex < 0 {
                    newIndex = 0
                }
            }
            reloadData()
        }
        
        if viewControllers.count > 0 {
            pageViewController.setViewControllers(
                [viewControllerAtIndex(0)!],
                direction: .forward,
                animated: false,
                completion: { flag in

                    guard let vc = self.viewControllerAtIndex(newIndex) else { return }
                    
                    self._currentIndex=newIndex
                    
                    self.pageViewController.setViewControllers([vc],
                                                               direction: .forward,
                                                               animated: false, completion: nil)
            })
            
            updateConstraints()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc private func pushDetails(gesture:UITapGestureRecognizer) {
        if viewControllers.count > 0 {
            if viewControllers.first!.isKind(of: EmptyWallet.self) {
                return
            }
            _walletDetailsController.qrFrame =  pageViewController.view.frame
            _walletDetailsController.walletKey = WalletStore.shared.acitveWallets[currentIndex].wallet?.publicKey
            navigationController?.pushViewController(_walletDetailsController, animated: true)
        }
    }
    
    @objc private func newWallet(sender:UIButton) {
        if WalletStore.shared.acitveWallets.count > Config.activeWalletsLimit {
            UIAlertController(title: NSLocalizedString("Limit exeeded", comment: ""),
                              message: NSLocalizedString("Please archive your inactive wallets", comment: ""),
                              preferredStyle: .alert)
                .addAction(title: NSLocalizedString("Close", comment: ""))
                .present(by: self)
        }
        else {
            presentInNavigationController(_newWalletController, animated: true)
        }
    }
    
    @objc private func openContact(sender:UIButton) {
        if viewControllers.count > 0 {
            if viewControllers.first!.isKind(of: EmptyWallet.self) {
                //return
            }
            else {
                _walletContacts.walletKey = WalletStore.shared.acitveWallets[currentIndex].wallet?.publicKey
            }
            presentInNavigationController(_walletContacts, animated: true)
        }
    }
    
    @objc private func archiveWallet(sender:UIButton) {
        guard WalletStore.shared.archivedWallets.count > 0 else {
            UIAlertController(title: NSLocalizedString("You don't have any archive wallets", comment: ""),
                              message: "Arhived wallets appear when you decide to remove your active wallets...",
                              preferredStyle: UIAlertControllerStyle.alert)
            .addAction(title: NSLocalizedString("OK", comment: ""),
                       style: UIAlertActionStyle.cancel)
            .present(by: self)
            return
        }
        if currentIndex < WalletStore.shared.acitveWallets.count {
            _archivedWallets.wallet = WalletStore.shared.acitveWallets[currentIndex]
        }
        presentInNavigationController(_archivedWallets, animated: true)
    }
    
    private lazy var pageViewController: UIPageViewController = {
        let p = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        if viewControllers.count > 0 {
            p.setViewControllers([viewControllerAtIndex(0)!], direction: .forward, animated: true, completion: nil)
        }

        p.dataSource = self
        p.delegate = self
        p.view.backgroundColor = UIColor.clear
        return p
    }()
    
    fileprivate lazy var viewControllers:[UIViewController] = {
        return makeControllers()
    }()
    
    fileprivate func reloadData() {
        viewControllers = makeControllers()
    }
    
    fileprivate func makeControllers() -> [WalletCell] {
        var u = [WalletCell]()
        for i in 0..<WalletStore.shared.acitveWallets.count {
            let v = WalletCardPreview()
            v.delegate = self
            v.walletIndex = i
            u.append(v)
        }
        if u.count == 0 {
            let v = EmptyWallet()
            v.addWalletHandler = {
                self.presentInNavigationController(self._newWalletController, animated: true)
            }
            u.append(v)
        }
        return u
    }
    
    fileprivate var _currentIndex: Int?
    fileprivate var _pendingIndex: Int?
    
    fileprivate var _walletDetailsController = WalletDetails()
    fileprivate var _newWalletController = WalletSettings()
    fileprivate var _walletContacts = WalletContacts()
    fileprivate var _archivedWallets = ArchivedWallets()
}


extension WalletsPager: WalletCellDelegate {
    func walletCell(_ item: WalletCell, didPress wallet: WalletContainer?)
    {
        _walletDetailsController.qrFrame =  pageViewController.view.frame
        _walletDetailsController.walletKey = wallet?.wallet?.publicKey
        navigationController?.pushViewController(_walletDetailsController, animated: true)
    }
    
    func walletCell(_ item: WalletCell, didPresent wallet: WalletContainer?) {
        navigationItem.title = wallet?.wallet?.name ?? "-"
        (navigationController as? NavigationController)?.titleColor = UIColor(hex: wallet?.attributes?.color ?? 255)
    }
}

// MARK: - UIPageViewController DataSource
extension WalletsPager: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController)
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if index == viewControllers.count {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        let count = viewControllers.count
        return  count > Config.pageControlsNumbers ? Config.pageControlsNumbers : count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return (_currentIndex ?? 0) % Config.pageControlsNumbers
    }
}

extension WalletsPager: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard pendingViewControllers.count > 0 else { return }
        _pendingIndex = indexOfViewController(pendingViewControllers[0])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            _currentIndex = _pendingIndex
        }
    }
}

// MARK: - Helpers
extension WalletsPager {
    fileprivate func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        if viewControllers.count == 0 || index >= viewControllers.count {
            return nil
        }
        return viewControllers[index]
    }
    
    fileprivate func indexOfViewController(_ viewController: UIViewController) -> Int {
        return viewControllers.index(of: viewController) ?? NSNotFound
    }
}



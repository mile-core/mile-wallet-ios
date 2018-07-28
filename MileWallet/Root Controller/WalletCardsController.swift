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

class WalletCardsController: UIViewController {

    public var currentIndex:Int {
        return _currentIndex ?? NSNotFound
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false

        //view.backgroundColor = UIColor.clear
        
        view.addSubview(newWalletButton)
        view.addSubview(archiveButton)
        view.addSubview(contactsButton)
        view.addSubview(verticalLineLeft)
        view.addSubview(verticalLineRight)

        
//        try? WalletStore.shared.keychain.removeAll()
// // !!!
//        for w in WalletStore.shared.wallets {
//            print("... p[\(w.wallet?.name)] = \(w.wallet?.publicKey) \(w.wallet?.privateKey)")
//            if let key = w.wallet?.name, key == "local" {
//                continue
//            }
//            try? WalletStore.shared.keychain.remove(w.wallet!.publicKey!)
//            try? WalletStore.shared.keychain.removeWalletAttr(w.wallet!.publicKey!)
//        }

        verticalLineLeft.snp.makeConstraints { (m) in
            m.centerX.equalTo(view.snp.right).multipliedBy(1.0/3.0)
            m.height.equalTo(84)
            m.bottom.equalToSuperview().offset(-20)
            m.width.equalTo(1)
        }
        
        verticalLineRight.snp.makeConstraints { (m) in
            m.centerX.equalTo(view.snp.right).multipliedBy(2.0/3.0)
            m.height.equalTo(verticalLineLeft.snp.height)
            m.bottom.equalTo(verticalLineLeft.snp.bottom)
            m.width.equalTo(verticalLineLeft.snp.width)
        }
        
        newWalletButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(verticalLineLeft.snp.centerY).offset(-7)
            m.centerX.equalTo(view.snp.right).multipliedBy(1.0/6.0)
            m.bottom.equalToSuperview().offset(-27)
            m.width.equalTo(88)
        }
        
        archiveButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(newWalletButton.snp.centerY)
            m.centerX.equalTo(view.snp.right).multipliedBy(5.0/6.0)
            m.bottom.equalTo(newWalletButton.snp.bottom)
            m.width.equalTo(88)
        }
        
        contactsButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(newWalletButton.snp.centerY)
            m.centerX.equalToSuperview()
            m.width.equalTo(88)
        }
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        
        pageViewController.view.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Config.iPhoneX ? 20 : 0)
            m.left.equalTo(view).offset(0)
            m.right.equalTo(view).offset(0)
            pagerOffset = m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(Config.iPhoneX ? -160 : -140).constraint
        }
        
        pageViewController.didMove(toParentViewController: self)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pushDetails(gesture:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        pageViewController.view.addGestureRecognizer(tap)
    }
    
    private var pagerOffset:Constraint?
    
    func updateConstraints()  {
        UIView.animate(withDuration: Config.animationDuration) {
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
            
            if self.viewControllers.count > 1 {
                self.pagerOffset?.update(offset: Config.iPhoneX ? -140 : -110)
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
    
    private lazy var newWalletButton:UIButton = {
        let b = UIButton.app()
        b.setImage(UIImage(named: "button-new-wallet"), for: UIControlState.normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.setTitle(NSLocalizedString("Add Wallet", comment: ""), for: .normal)
        b.addTarget(self, action:#selector(newWallet(sender:)), for: UIControlEvents.touchUpInside)
        return b
    }()

    private lazy var contactsButton:UIButton = {
        let b = UIButton.app()
        b.setImage(UIImage(named: "button-contact-book"), for: UIControlState.normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.setTitle(NSLocalizedString("Contacts", comment: ""), for: .normal)
        b.addTarget(self, action:#selector(openContact(sender:)), for: UIControlEvents.touchUpInside)
        return b
    }()

    private lazy var archiveButton:UIButton = {
        let b = UIButton.app()
        b.setImage(UIImage(named: "button-archive-wallets"), for: UIControlState.normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.setTitle(NSLocalizedString("Archive", comment: ""), for: .normal)
        b.addTarget(self, action:#selector(openContact(sender:)), for: UIControlEvents.touchUpInside)
        return b
    }()
    
    fileprivate var lastIndex = 0
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lastIndex = _currentIndex ?? 0
    }
    
    ///
    /// Apple does not motivate to use UIPageViewController with dinamic content.
    /// so, TODO: rewrite the part of the code with custom controller.
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false

        var newIndex = lastIndex
        
        if viewControllers.count != WalletStore.shared.acitveWallets.count
        || viewControllers.count == 1 {
            if viewControllers.count < WalletStore.shared.acitveWallets.count {
                newIndex = viewControllers.count
            }
            else if newIndex >= WalletStore.shared.acitveWallets.count {
                newIndex -= 1
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
        present(_newWalletController, animated: true)
    }
    
    @objc private func openContact(sender:UIButton) {
        print("Open contact")        
        if viewControllers.count > 0 {
            if viewControllers.first!.isKind(of: EmptyWallet.self) {
                return
            }
            _walletContacts.walletKey = WalletStore.shared.acitveWallets[currentIndex].wallet?.publicKey
            navigationController?.pushViewController(_walletContacts, animated: true)
        }
    }
    
    @objc private func archiveWallet(sender:UIButton) {
        print("Archive wallet")
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
                 self.present(self._newWalletController, animated: true)
            }
            u.append(v)
        }
        return u
    }
    
    fileprivate var _currentIndex: Int?
    fileprivate var _pendingIndex: Int?
    
    fileprivate var _walletDetailsController = WalletDetails()
    fileprivate var _newWalletController = WalletOptions()
    fileprivate var _walletContacts = WalletContacts()
}


extension WalletCardsController: WalletCellDelegate {
    func walletCell(_ item: WalletCell, didPress wallet: WalletContainer?)
    {
        _walletDetailsController.qrFrame =  pageViewController.view.frame
        _walletDetailsController.walletKey = wallet?.wallet?.publicKey
        navigationController?.pushViewController(_walletDetailsController, animated: true)
    }
    
    func walletCell(_ item: WalletCell, didPresent wallet: WalletContainer?) {
        navigationItem.title = wallet?.wallet?.name ?? "-"
    }
}

// MARK: - UIPageViewController DataSource
extension WalletCardsController: UIPageViewControllerDataSource {
    
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

extension WalletCardsController: UIPageViewControllerDelegate {
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
extension WalletCardsController {
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


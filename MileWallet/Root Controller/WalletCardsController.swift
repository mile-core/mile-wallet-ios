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
        
        view.backgroundColor = UIColor.clear
        
        view.addSubview(newWalletButton)
        view.addSubview(contactsButton)
        view.addSubview(verticalLine)
        
        verticalLine.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.height.equalTo(84)
            m.bottom.equalToSuperview().offset(-20)
            m.width.equalTo(1)
        }
        
        newWalletButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(verticalLine.snp.centerY).offset(-7)
            m.right.equalTo(verticalLine.snp.left).offset(-34)
            m.bottom.equalToSuperview().offset(-27)
            m.width.equalTo(88)
        }
        
        contactsButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(verticalLine.snp.centerY).offset(-7)
            m.left.equalTo(verticalLine.snp.right).offset(34)
            m.width.equalTo(88)
        }
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        
        let top = navigationController!.navigationBar.frame.height
        pageViewController.view.snp.makeConstraints { (m) in
            m.edges.equalTo(UIEdgeInsets(top: top + 20,
                                         left: 10,
                                         bottom: 140,
                                         right: 10))
        }
        
        pageViewController.didMove(toParentViewController: self)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pushDetails(gesture:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        pageViewController.view.addGestureRecognizer(tap)
    }
    

    private let verticalLine:UIView = {
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
        b.setImage(UIImage(named: "button-contacts"), for: UIControlState.normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.setTitle(NSLocalizedString("Contacts", comment: ""), for: .normal)
        b.addTarget(self, action:#selector(openContact(sender:)), for: UIControlEvents.touchUpInside)
        return b
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc private func pushDetails(gesture:UITapGestureRecognizer) {
        if viewControllers.count > 0 {
            navigationController?.pushViewController(_walletDetailsController, animated: true)
        }
    }
    
    @objc private func newWallet(sender:UIButton) {
        present(_newWalletController, animated: true)
    }
    
    @objc private func openContact(sender:UIButton) {
        print("Open contact")
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
       var u = [UIViewController]()
        for i in 0..<Store.shared.items.count {
            let v = WalletItemController()
            v.delegate = self
            v.walletIndex = i
            u.append(v)
        }
        return u
    }()
    
    fileprivate var _currentIndex: Int?
    fileprivate var _pendingIndex: Int?
    
    fileprivate var _walletDetailsController = WalletDetailsController()
    fileprivate var _newWalletController = NewWalletController()
}


extension WalletCardsController: WalletItemDelegate {
    func walletItem(_ item: WalletItemController, didPress: Wallet?) {
        navigationController?.pushViewController(_walletDetailsController, animated: true)
    }
    
    func walletItem(_ item: WalletItemController, didPresent wallet: Wallet?) {
        navigationItem.title = wallet?.name ?? "-"
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
        let count = Store.shared.items.count
        return  count > 5 ? 5 : count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
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
//            if let index = currentIndex {
//            }
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


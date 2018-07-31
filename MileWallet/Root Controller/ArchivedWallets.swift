//
//  ArchivedWallets.swift
//  MileWallet
//
//  Created by denn on 31.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

class ArchivedWallets: Controller {
    public var wallet:WalletContainer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.backgroundColor = UIColor.white
        title = NSLocalizedString("Archived wallets", comment: "")

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closeHandler(sender:)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (navigationController as? NavigationController)?.titleColor = UIColor(hex: wallet?.attributes?.color ?? 255)
    }
    
    @objc private func closeHandler(sender:Any){
        dismiss(animated: true)
    }
    
}

fileprivate class WalletsController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor.clear
        //tableView.register(ConactCell.self, forCellReuseIdentifier: cellReuseIdendifier)
    }
    
    var didLayout = false
    override func viewDidLayoutSubviews() {
        if !self.didLayout {
            self.didLayout = true // only need to do this once
            self.tableView.reloadData()
        }
    }
    
    fileprivate var list:[WalletContainer] {
        return WalletStore.shared.archivedWallets
    }
    
}


// MARK: - Datasource
extension WalletsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}


// MARK: - Delegate
extension WalletsController {
    
}

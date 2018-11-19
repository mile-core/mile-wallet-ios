//
//  WalletSorter.swift
//  MileWallet
//
//  Created by denn on 20.09.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation

import MileWalletKit
import SnapKit

class WalletsSorter: Controller {
    
    //private let bg = UIImageView(image: Config.Images.basePattern)

    public var didDismiss: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel,
                                                           target: self, action: #selector(back(sender:)))
      
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                                            target: self, action: #selector(done(sender:)))
        
        //contentView.addSubview(bg)
        //bg.contentMode = .scaleAspectFill
        //bg.snp.makeConstraints { (m) in
        //    m.edges.equalTo(view.snp.edges)
        //}
        
        addChild(_tableController)
        view.addSubview(_tableController.view)
        _tableController.didMove(toParent: self)
        
        _tableController.view.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            m.left.right.equalTo(contentView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.backgroundColor = Config.Colors.defaultColor
//        navigationController?.navigationBar.prefersLargeTitles = false
        title = NSLocalizedString("Sort wallets", comment: "")
    }
    
    @objc private func back(sender:Any) {
        dismiss(animated: true)
    }
    
    @objc private func done(sender:Any) {
        for (i, var o) in _tableController.list.enumerated() {
            o.attributes?.sortOrder = i
            try? WalletStore.shared.save(wallet: o)
        }
        dismiss(animated: true)
        self.didDismiss?()
        _tableController.list = []
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    fileprivate lazy var _tableController = SortController()
}

fileprivate class SortController: UITableViewController {
    
    fileprivate var isBook:Bool = false
    
    let cellReuseIdendifier = "sortCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor.clear
        tableView.register(WalletTableCell.self, forCellReuseIdentifier: cellReuseIdendifier)
    }
    
    private var didLayout = false
    override func viewDidLayoutSubviews() {
        if !self.didLayout {
            self.didLayout = true // only need to do this once
            self.tableView.reloadData()
        }
    }
    
    fileprivate var list:[WalletContainer] = []

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIButton.appearance().setTitleColor(UIColor.white, for: .normal)
        list = [WalletContainer](WalletStore.shared.acitveWallets)
        tableView.isEditing = true
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIButton.appearance().setTitleColor(Config.Colors.button, for: .normal)
        tableView.setEditing(false, animated: true)
    }
}

// MARK: - Datasource
extension SortController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! WalletTableCell
        
        let list = self.list
        
        let wallet = list[indexPath.row]
        cell.wallet = wallet
        
        if let w = wallet.wallet {
            
            Balance.update(wallet: w, error: { (error) in
                
                UIAlertController(title: NSLocalizedString("Balance error", comment: ""),
                                  message:  error?.description,
                                  preferredStyle: .alert)
                    .addAction(title: "Close", style: .cancel)
                    .present(by: self)
                
                cell.stopActivities()
                
            }, complete: { (balance) in
                
                Chain.update(error: { (e) in
                    
                    UIAlertController(title: NSLocalizedString("Balance error", comment: ""),
                                      message:  e?.description,
                                      preferredStyle: .alert)
                        .addAction(title: "Close", style: .cancel)
                        .present(by: self)
                    
                    cell.stopActivities()
                    
                }) { (chain) in
                    self.update(cell: cell, chain: chain, balance: balance)
                    cell.stopActivities()
                }
            })
        }
        
        return cell
    }
    
    private func update(cell: WalletTableCell,  chain:Chain, balance:Balance) {
        
        cell.xdrValue = 0
        cell.mileValue = 0
        
        for k in balance.available_assets {
            
            let b = balance.amount(k) ?? 0 //Float(balance.balance[k] ?? "0") ?? 0
            
            if k == Asset.xdr.code {
                cell.xdrValue = b
            }
            else if k == Asset.mile.code {
                cell.mileValue = b
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}


// MARK: - Delegate
extension SortController {
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = UIColor.black.withAlphaComponent(0.03)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = UIColor.clear
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WalletTableCell
        cell.backgroundColor = UIColor.clear
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let movedObject = self.list[sourceIndexPath.row]
        self.list.remove(at: sourceIndexPath.row)
        self.list.insert(movedObject, at: destinationIndexPath.row)
    }
}

//
//  ArchivedWallets.swift
//  MileWallet
//
//  Created by denn on 31.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import SnapKit
import MileWalletKit

class ArchivedWallets: Controller {
    public var wallet:WalletContainer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.backgroundColor = UIColor.white
        title = NSLocalizedString("Archived wallets", comment: "")

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closeHandler(sender:)))
        
        addChildViewController(_tableController)
        view.addSubview(_tableController.view)
        _tableController.didMove(toParentViewController: self)
        
        _tableController.view.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            m.left.right.equalTo(view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        (navigationController as? NavigationController)?.titleColor = Config.Colors.defaultColor //UIColor(hex: wallet?.attributes?.color ?? 255)
        _tableController.tableView.reloadData()
    }
    
    @objc private func closeHandler(sender:Any){
        dismiss(animated: true)
    }
    
    fileprivate let _tableController = WalletsController()
}

fileprivate class WalletTableCell: UITableViewCell {
    
    var wallet:WalletContainer? {
        didSet{
            name.text = wallet?.wallet?.name
            let c = UIColor(hex: wallet?.attributes?.color ?? UIColor.black.hex)
            containerView.backgroundColor = Config.Colors.archivedCell.mix(infusion: c, alpha: 0.03)
            startActivities()
        }
    }
    
    private var containerView = UIView()
    private var name:UILabel = UILabel()

    var xdrLabel:UILabel = UILabel()
    var mileLabel:UILabel = UILabel()

    var xdrAmountLabel:UILabel = UILabel()
    var mileAmountLabel:UILabel = UILabel()
    
    private func activityLoader(place:UIView)  -> UIActivityIndicatorView {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .white)
        a.hidesWhenStopped = true
        place.addSubview(a)
        a.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return a
    }
    
    fileprivate func startActivities()  {
        for a in activities { a.startAnimating() }
    }
    
    fileprivate func stopActivities()  {
        for a in activities { a.stopAnimating() }
    }
    
    private lazy var activities:[UIActivityIndicatorView] = [self.activityLoader(place: self.xdrAmountLabel),
                                                             self.activityLoader(place: self.mileAmountLabel)]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let bg = containerView
        
        bg.layer.cornerRadius = Config.buttonRadius
        bg.layer.masksToBounds = true
        bg.clipsToBounds = true
        
        bg.backgroundColor = Config.Colors.archivedCell
        contentView.addSubview(bg)
        contentView.addSubview(name)
        bg.addSubview(xdrLabel)
        bg.addSubview(mileLabel)
        bg.addSubview(xdrAmountLabel)
        bg.addSubview(mileAmountLabel)

        name.textAlignment = .left
        name.numberOfLines = 3
        name.textColor = UIColor.black
        name.font = Config.Fonts.name
        
        xdrLabel.textColor = UIColor.white
        mileLabel.textColor = UIColor.white
        
        xdrAmountLabel.textAlignment = .left
        xdrAmountLabel.textColor = UIColor.white
        xdrAmountLabel.font = Config.Fonts.caption
        xdrAmountLabel.minimumScaleFactor = 0.5
        xdrAmountLabel.adjustsFontSizeToFitWidth = true
        
        mileAmountLabel.textAlignment = .left
        mileAmountLabel.textColor = UIColor.white
        mileAmountLabel.font = Config.Fonts.caption
        mileAmountLabel.minimumScaleFactor = 0.5
        mileAmountLabel.adjustsFontSizeToFitWidth = true

        name.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(25)
            m.top.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }
        
        bg.snp.makeConstraints { (m) in
            m.top.equalTo(name.snp.bottom).offset(6)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.height.equalTo(60)
        }
        
        xdrLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(18)
            m.bottom.equalToSuperview()
            m.width.equalTo(40)
        }
        
        mileLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalTo(bg.snp.centerX)
            m.bottom.equalToSuperview()
            m.width.equalTo(40)
        }
        
        xdrAmountLabel.snp.makeConstraints { (m) in
            m.left.equalTo(xdrLabel.snp.right).offset(10)
            m.top.equalTo(xdrLabel)
            m.bottom.equalTo(xdrLabel)
            m.right.equalTo(bg.snp.centerX).offset(-20)
        }

        mileAmountLabel.snp.makeConstraints { (m) in
            m.left.equalTo(mileLabel.snp.right).offset(10)
            m.top.equalTo(mileLabel)
            m.bottom.equalTo(mileLabel)
            m.right.equalToSuperview().offset(-20)
        }

//        add(border: .bottom,
//            color: Config.Colors.bottomLine,
//            width: 1,
//            padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


fileprivate class WalletsController: UITableViewController {
    
    //fileprivate var chainInfo:Chain?
    fileprivate let cellReuseIdendifier = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor.clear
        tableView.allowsSelectionDuringEditing = true
        tableView.register(WalletTableCell.self, forCellReuseIdentifier: cellReuseIdendifier)
    }
    
    private var didLayout = false
    override func viewDidLayoutSubviews() {
        if !self.didLayout {
            self.didLayout = true // only need to do this once
            self.tableView.reloadData()
        }
    }
    
    fileprivate var list:[WalletContainer] {
        return WalletStore.shared.archivedWallets
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIButton.appearance().setTitleColor(UIColor.white, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIButton.appearance().setTitleColor(Config.Colors.button, for: .normal)
        tableView.setEditing(false, animated: true)
    }
}

// MARK: - Datasource
extension WalletsController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! WalletTableCell

        let list = self.list
        
        let wallet = list[indexPath.row]
        cell.wallet = wallet
        cell.xdrLabel.text = Asset.xdr.name
        cell.mileLabel.text = Asset.mile.name
        
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

        cell.xdrAmountLabel.text = Asset.xdr.stringValue(0)
        cell.mileAmountLabel.text = Asset.mile.stringValue(0)

        for k in balance.balance.keys {
            
            let b = Float(balance.balance[k] ?? "0") ?? 0
            
            if chain.assets[k] == Asset.xdr.name {
                cell.xdrAmountLabel.text = Asset.xdr.stringValue(b)
            }
            else if chain.assets[k] == Asset.mile.name {
                cell.mileAmountLabel.text = Asset.mile.stringValue(b)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}


// MARK: - Delegate
extension WalletsController {
    
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
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let list = self.list
        let wallet = list[indexPath.row]
        
        let delete = UITableViewRowAction(style: .destructive,
                                          title: NSLocalizedString("Delete", comment: ""))
        { (action, indexPath) in
            self.tableView(tableView,
                           commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
        }
        
        let restore = UITableViewRowAction(style: UITableViewRowActionStyle.default,
                                        title: NSLocalizedString("Restore", comment: ""))
        { (action, indexPath) in
            
            UIAlertController(title: nil,
                              message: NSLocalizedString("Restore wallet", comment: ""),
                              preferredStyle: .actionSheet)
                .addAction(title: NSLocalizedString("Cancel", comment: ""),
                           style: UIAlertActionStyle.cancel)
                .addAction(title: NSLocalizedString("Restore!", comment: ""),
                           style: UIAlertActionStyle.default, handler: { (action) in
                            
                            if self.restore(wallet: wallet) {
                                self.tableView.beginUpdates()
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                                self.tableView.endUpdates()
                            }
                            
                })
                .present(by: self)
        }
        
        restore.backgroundColor = UIColor(hex: wallet.attributes?.color ?? Config.Colors.defaultColor.hex)
        
        return [delete, restore]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WalletTableCell
        cell.backgroundColor = UIColor.clear
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

            let list = self.list
            let wallet = list[indexPath.row]

            UIAlertController(title: NSLocalizedString("Delete: ", comment: "") + (wallet.wallet?.name ?? " - "),
                              message: NSLocalizedString("Are you sure you want to permanently delete the wallet?", comment: ""),
                              preferredStyle: .actionSheet)
                .addAction(title: NSLocalizedString("Cancel", comment: ""),
                           style: .cancel)
                .addAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { (action) in
                    do{
                        if let pk = wallet.wallet?.publicKey {
                            try WalletStore.shared.remove(key: pk)
                            
                            //tableView.setEditing(false, animated: true)

                            if list.count >= 1 {
                                self.tableView.beginUpdates()
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        }
                    }
                    catch let error {
                        print("Model error: \(error)")
                    }
                }
                .present(by: self)
        }
    }
    
    private func restore(wallet:WalletContainer?) -> Bool {
        guard var wallet = wallet else { return false }
        
        if WalletStore.shared.acitveWallets.count >= Config.activeWalletsLimit {
            UIAlertController(title: NSLocalizedString("Limit exeeded", comment: ""),
                              message: NSLocalizedString("Please archive your inactive wallets", comment: ""),
                              preferredStyle: .alert)
                .addAction(title: NSLocalizedString("Close", comment: ""))
                .present(by: self)
            return false
        }
        
        wallet.attributes?.isActive = true
        do {
            try WalletStore.shared.save(wallet: wallet)
            return true
        }
        catch let error {
            UIAlertController(title: NSLocalizedString("Wallet error", comment: ""),
                              message:  error.description,
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel)
                .present(by: self)
            return false
        }
    }
}

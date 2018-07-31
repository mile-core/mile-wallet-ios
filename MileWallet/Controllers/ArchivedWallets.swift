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
        contentView.addSubview(_tableController.view)
        _tableController.didMove(toParentViewController: self)
        
        _tableController.view.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            m.left.right.equalTo(contentView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        (navigationController as? NavigationController)?.titleColor = UIColor(hex: wallet?.attributes?.color ?? 255)
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
            name.textColor = UIColor(hex: wallet?.attributes?.color ?? UIColor.black.hex)
            startActivities()
        }
    }
    
    private var name:UILabel = UILabel()

    var xdrLabel:UILabel = UILabel()
    var mileLabel:UILabel = UILabel()

    var xdrAmountLabel:UILabel = UILabel()
    var mileAmountLabel:UILabel = UILabel()
    
    private var line = UIView()
    
    private func activityLoader(place:UIView)  -> UIActivityIndicatorView {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
        contentView.addSubview(name)
        contentView.addSubview(line)
        contentView.addSubview(xdrLabel)
        contentView.addSubview(mileLabel)
        contentView.addSubview(xdrAmountLabel)
        contentView.addSubview(mileAmountLabel)

        name.textAlignment = .left
        name.numberOfLines = 3
        name.font = Config.Fonts.amount

        line.backgroundColor = Config.Colors.bottomLine
        
        xdrAmountLabel.textAlignment = .left
        xdrAmountLabel.textColor = UIColor.black
        xdrAmountLabel.font = Config.Fonts.amount
        xdrAmountLabel.minimumScaleFactor = 0.5
        xdrAmountLabel.adjustsFontSizeToFitWidth = true
        
        mileAmountLabel.textAlignment = .left
        mileAmountLabel.textColor = UIColor.black
        mileAmountLabel.font = Config.Fonts.amount
        mileAmountLabel.minimumScaleFactor = 0.5
        mileAmountLabel.adjustsFontSizeToFitWidth = true

        name.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.bottom.top.equalToSuperview()
            m.right.equalTo(contentView.snp.centerX).multipliedBy(2.0/3.0)
        }
        
        xdrLabel.snp.makeConstraints { (m) in
            m.left.equalTo(name.snp.right).offset(10)
            m.width.equalTo(40)
            m.top.equalToSuperview().offset(5)
            m.bottom.equalTo(contentView.snp.centerY)
        }
        
        mileLabel.snp.makeConstraints { (m) in
            m.left.equalTo(xdrLabel.snp.left)
            m.width.equalTo(40)
            m.top.equalTo(contentView.snp.centerY)
            m.bottom.equalToSuperview().offset(-5)
        }
        
        line.snp.makeConstraints { (m) in
            m.centerY.equalTo(contentView.snp.centerY)
            m.left.equalTo(xdrLabel.snp.left)
            m.right.equalToSuperview().offset(-20)
            m.height.equalTo(1)
        }
        
        xdrAmountLabel.snp.makeConstraints { (m) in
            m.left.equalTo(xdrLabel.snp.right).offset(10)
            m.top.equalTo(xdrLabel)
            m.bottom.equalTo(xdrLabel)
            m.right.equalToSuperview().offset(-20)
        }

        mileAmountLabel.snp.makeConstraints { (m) in
            m.left.equalTo(mileLabel.snp.right).offset(10)
            m.top.equalTo(mileLabel)
            m.bottom.equalTo(mileLabel)
            m.right.equalToSuperview().offset(-20)
        }

        add(border: .bottom,
            color: Config.Colors.bottomLine,
            width: 1,
            padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
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
        tableView.register(WalletTableCell.self, forCellReuseIdentifier: cellReuseIdendifier)
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
        return 90
    }
}


// MARK: - Delegate
extension WalletsController {
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.03)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WalletTableCell
        cell.backgroundColor = UIColor.clear
        
        UIAlertController(title: nil,
                          message: NSLocalizedString("Restore wallet", comment: ""),
                          preferredStyle: .actionSheet)
            .addAction(title: NSLocalizedString("Cancel", comment: ""),
                       style: UIAlertActionStyle.cancel)
            .addAction(title: NSLocalizedString("Restore!", comment: ""),
                       style: UIAlertActionStyle.default, handler: { (action) in
                        self.restore(wallet: cell.wallet)
                        
                        
            })
            .present(by: self)
    }
    
    private func restore(wallet:WalletContainer?)  {
        guard var wallet = wallet else { return }
        wallet.attributes?.isActive = true
        do {
            try WalletStore.shared.save(wallet: wallet)
            tableView.reloadData()
        }
        catch let error {
            UIAlertController(title: NSLocalizedString("Wallet error", comment: ""),
                              message:  error.description,
                              preferredStyle: .alert)
                .addAction(title: "Close", style: .cancel)
                .present(by: self)
            self.tableView.reloadData()
        }
    }
}

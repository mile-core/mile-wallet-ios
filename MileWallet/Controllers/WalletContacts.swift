//
//  Contacts.swift
//  MileWallet
//
//  Created by denn on 28.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit
import SnapKit

class WalletContacts: Controller {
    
    public var sendingConinsState:Bool = false {
        didSet{
            _tableController.isBook = sendingConinsState
        }
    }
    
    public var walletKey:String? {
        didSet{
            if let w = walletKey {
                wallet = WalletStore.shared.wallet(by: w)
            }
        }
    }
    
    private let bg = UIImageView(image: Config.Images.basePattern)
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storageDidLoadError(notification:)),
                                               name: Model.kDidLoadErrorNotification,
                                               object: nil)

        contentView.addSubview(bg)
        bg.contentMode = .scaleAspectFill
        bg.snp.makeConstraints { (m) in
            m.edges.equalTo(view.snp.edges)
        }
        
        addChild(_tableController)
        contentView.addSubview(_tableController.view)
        _tableController.didMove(toParent: self)
        
        _tableController.view.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            m.left.right.equalTo(contentView)
        }
        
        _tableController._walletContacts = self
    }
    
    @objc func storageDidLoadError(notification:Notification) {
        if let error = notification.object as? Error {
            UIAlertController(title: "Device storage error",
                              message: error.localizedDescription,
                              preferredStyle: .alert)
            .addAction(title: "Close", style: .cancel)
            .present(by: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if sendingConinsState {
            title = NSLocalizedString("Send coins", comment: "")
        }
        else {
            title = NSLocalizedString("Address Book", comment: "")
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel,
                                                           target: self, action: #selector(back(sender:)))
        
        if !sendingConinsState {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                                                                target: self,
                                                                action: #selector(add(sender:)))
        }
        
        if let walletKey = walletKey,
            let w = WalletStore.shared.wallet(by: walletKey) {
            wallet = w
            bg.backgroundColor = UIColor(hex: w.attributes?.color ?? 0)
        }
        
        if WalletUniversalLink.shared.invoice != nil {
            add(sender: self)
        }

        _tableController.tableView.reloadData()
    }
    
    private var wallet:WalletContainer? {
        didSet{
            _tableController.wallet = wallet
            bg.backgroundColor = UIColor(hex: wallet?.attributes?.color ?? 0)
        }
    }
    
    @objc private func back(sender:Any) {
        dismiss(animated: true)
    }
    
    @objc private func add(sender:Any) {
        update(contact: nil)
    }
    
    fileprivate func update(contact:Contact?) {
        _contactOptionsController.isEdited = true
        _contactOptionsController.contact = contact
        _contactOptionsController.wallet = self.wallet
        presentInNavigationController(_contactOptionsController, animated: true) {
            self._contactOptionsController.isEdited = false
        }
    }
    
    fileprivate lazy var _tableController = ContactsController()
    fileprivate lazy var _contactOptionsController = WalletContactOptions()
}

fileprivate class ContactsController: UITableViewController {
    
    fileprivate weak var _walletContacts:WalletContacts?
    
    fileprivate var style:CoinsOperation.Style  {
        set{
            _sendCoinsController.style = newValue
        }
        get {
            return _sendCoinsController.style
        }
    }
    
    fileprivate var isBook:Bool = false

    fileprivate var wallet:WalletContainer?
    
    let cellReuseIdendifier = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor.clear
        tableView.register(ConactCell.self, forCellReuseIdentifier: cellReuseIdendifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIButton.appearance().setTitleColor(UIColor.white, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIButton.appearance().setTitleColor(Config.Colors.button, for: .normal)
    }
    
    private var didLayout = false
    override func viewDidLayoutSubviews() {
        if !self.didLayout {
            self.didLayout = true // only need to do this once
            self.tableView.reloadData()
        }
    }
    
    fileprivate var _sendCoinsController = CoinsOperation()
}


// MARK: - Datasource
extension ContactsController {

    var list:[Contact] {
        return Contact.list
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! ConactCell
        
        let list = self.list
        
        let contact = list[indexPath.row]
        cell.name = contact.name
        cell.publicKey = contact.publicKey
        cell.avatar = contact.photo
        
        cell.setNeedsDisplay()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

// MARK: - Delegate
extension ContactsController {
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.03)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.03)
        _sendCoinsController.wallet = self.wallet
        _sendCoinsController.contact = Contact.list[indexPath.row]
        presentInNavigationController(_sendCoinsController, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive,
                                          title: NSLocalizedString("Delete", comment: ""))
        { (action, indexPath) in
            self.tableView(tableView,
                           commit: UITableViewCell.EditingStyle.delete, forRowAt: indexPath)
        }
        
        let edit = UITableViewRowAction(style: UITableViewRowAction.Style.default,
                                          title: NSLocalizedString("Edit", comment: ""))
        { (action, indexPath) in
            self._walletContacts?.update(contact: self.list[indexPath.row])
        }
        
        edit.backgroundColor = Config.Colors.defaultColor
        
        
        let send = UITableViewRowAction(style: UITableViewRowAction.Style.default,
                                        title: NSLocalizedString("Send Coins", comment: ""))
        { (action, indexPath) in
            self.tableView(tableView, didSelectRowAt: indexPath)
        }
        
        send.backgroundColor = UIColor(hex: wallet?.attributes?.color ?? Config.Colors.defaultColor.hex)
        
                
        return [delete, edit, send]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isBook
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

            var list = self.list
            let contact = list[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! ConactCell

            UIAlertController(title: NSLocalizedString("Delete: ", comment: "") + (contact.name ?? " - "),
                              message: NSLocalizedString("Are you sure you want to permanently delete the contact?", comment: ""),
                              preferredStyle: .actionSheet)
                .addAction(title: NSLocalizedString("Cancel", comment: ""),
                           style: .cancel)
                .addAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { (action) in
                    
                    contact.name = nil
                    contact.photo = nil
                    
                    Model.shared.context.delete(contact)
                    
                    do{
                        try Model.shared.context.save()
                       
                        if list.count >= 1 {
                            self.tableView.beginUpdates()
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            self.tableView.endUpdates()
                            cell.avatar = nil
                        }
                    }
                    catch let error {
                        print("Model error: \(error)")
                    }
            }
            .present(by: self)
        }
    }
}

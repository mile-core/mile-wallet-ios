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
        
        contentView.addSubview(bg)
        bg.contentMode = .scaleAspectFill
        bg.snp.makeConstraints { (m) in
            m.edges.equalTo(view.snp.edges)
        }
        
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
        
        if sendingConinsState {
            title = NSLocalizedString("Send coins", comment: "")
        }
        else {
            title = NSLocalizedString("Address Book", comment: "")
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel,
                                                           target: self, action: #selector(back(sender:)))
        
        if !sendingConinsState {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,
                                                                target: self,
                                                                action: #selector(add(sender:)))
        }
        
        if let walletKey = walletKey,
            let w = WalletStore.shared.wallet(by: walletKey) {
            wallet = w
            bg.backgroundColor = UIColor(hex: w.attributes?.color ?? 0)
        }
        
        _tableController.tableView.reloadData()
        
        if WalletUniversalLink.shared.invoice != nil {
            add(sender: self)
        }
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
        _contactOptionsController.contact = nil
        _contactOptionsController.wallet = self.wallet
        presentInNavigationController(_contactOptionsController, animated: true)
    }
    
    fileprivate let _tableController = ContactsController()
    private let _contactOptionsController = WalletContactOptions()
}

fileprivate class ContactsController: UITableViewController {
    
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
    
    var didLayout = false
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
        
        cell.contentView.remove(border: .bottom)
        
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isBook
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let l = list
            let contact = l[indexPath.row]
                        
            Model.shared.context.delete(contact)
            
            do{
                try Model.shared.context.save()
                
                if l.count >= 1 {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
            catch let error {
                print("Model error: \(error)")
            }
        }
    }
}

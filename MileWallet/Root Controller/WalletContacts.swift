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

class ContactView: UIView {
    
    public var isEdited = false {
        didSet{
            pablicKeyLabelConstraint()
            iconView.alpha = isEdited ? 0.0 : 1.0
            publicKeyLabel.isUserInteractionEnabled = isEdited
            publicKeyLabel.placeholder = isEdited ? NSLocalizedString("Type or paste transfer address", comment: "") : ""
        }
    }
    
    public var avatar:Data? {
        didSet{
            guard let d = avatar else {
                return
            }
            iconView.image = UIImage(data: d)
        }
    }
    
    public var publicKey:String? {
        set{
            publicKeyLabel.text = newValue
        }
        get {
            return publicKeyLabel.text
        }
    }
    
    public var name:String? = "" {
        didSet{
            if let str = name, str.count > 0 {
                litera.text = String(str.prefix(1))
            }
            nameLabel.text = name
        }
    }
    
    fileprivate var nameLabel = UILabel()
    
    private lazy var publicKeyLabel:UITextField = {
        let t = UITextField.nameField(placeholder: "")
        t.font = Config.Fonts.address
        t.adjustsFontSizeToFitWidth = true
        t.isUserInteractionEnabled = false
        t.clearButtonMode = .whileEditing
        return t
    }()
    
    fileprivate var iconView = UIImageView()
    fileprivate var litera = UILabel()
    
    fileprivate var publicKeyLeft:ConstraintMakerExtendable!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconView.backgroundColor = UIColor(hex: 0xD5E9F5)
        iconView.layer.cornerRadius = iconView.frame.size.width  / 2
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFill
        
        addSubview(nameLabel)
        addSubview(publicKeyLabel)
        addSubview(iconView)
        
        iconView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.top.equalTo(self).offset(16)
            m.bottom.equalTo(self).offset(-16)
            m.width.equalTo(iconView.snp.height)
        }
        
        nameLabel.textAlignment = .left
        nameLabel.font = Config.Fonts.caption
        nameLabel.textColor = UIColor.black
        nameLabel.backgroundColor = UIColor.clear
        
        publicKeyLabel.textAlignment = .left
        publicKeyLabel.font = Config.Fonts.contacts
        publicKeyLabel.textColor = UIColor.black
        publicKeyLabel.backgroundColor = UIColor.clear
        
        nameLabel.snp.makeConstraints { (m) in
            m.left.equalTo(iconView.snp.right).offset(10)
            m.top.equalToSuperview().offset(5)
            m.bottom.equalTo(self.snp.centerY)
            m.right.equalToSuperview().offset(-10)
        }
        
        pablicKeyLabelConstraint()
        
        litera.textAlignment = .center
        litera.font = Config.Fonts.header
        litera.textColor = UIColor.white
        litera.backgroundColor = UIColor.clear
        
        iconView.addSubview(litera)
        litera.snp.makeConstraints { (m) in
            m.center.equalTo(iconView)
            m.width.equalTo(iconView)
            m.height.equalTo(litera.snp.width)
        }
    }
    
    private func pablicKeyLabelConstraint() {
        publicKeyLabel.snp.remakeConstraints { (m) in
            if !isEdited {
                m.left.equalTo(iconView.snp.right).offset(10)
            }
            else {
                m.left.equalToSuperview().offset(20)
            }
            m.top.equalTo(nameLabel.snp.centerY).offset(5)
            m.bottom.equalTo(self).offset(5)
            m.right.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.layer.cornerRadius = iconView.frame.size.width  / 2
        iconView.layer.masksToBounds = true
        iconView.clipsToBounds = true
        if avatar == nil {
            litera.alpha = 1
        }
        else {
            litera.alpha = 0
        }
    }
}

class ConactCell: UITableViewCell {
    
    var avatar:Data? {
        set{ contactView.avatar = newValue}
        get{ return contactView.avatar }
    }
    
    var publicKey:String?  {
        set{ contactView.publicKey = newValue}
        get{ return contactView.publicKey }
    }
    
    var name:String? {
        set{ contactView.name = newValue}
        get{ return contactView.name }
    }
    
    fileprivate let contactView = ContactView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(contactView)
        contactView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let c = contactView.iconView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        backgroundColor = UIColor.clear
        contactView.iconView.backgroundColor = c
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let c = contactView.iconView.backgroundColor
        super.setSelected(selected, animated: animated)
        contactView.iconView.backgroundColor = c
    }
}

class ContactsController: UITableViewController {
    
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
        cell.contentView.add(border: .bottom,
                             color: Config.Colors.bottomLine,
                             width: 1,
                             padding: UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 0)
        )
        
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
        present(_sendCoinsController, animated: true)

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
                if l.count == 1 {
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    tableView.reloadRows(at:[indexPath], with: .automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
            catch let error {
                print("Model error: \(error)")
            }
        }
    }
}

class WalletContacts: Controller {
    
    fileprivate var isModal:Bool = false
    
   
    public var isBook:Bool = false {
        didSet{
            _tableController.isBook = isBook
        }
    }
    
    private var wallet:WalletContainer? {
        didSet{
            _tableController.wallet = wallet
            bg.backgroundColor = UIColor(hex: wallet?.attributes?.color ?? 0)
        }
    }
    
    public var walletKey:String? {
        didSet{
            if let w = walletKey {
                wallet = WalletStore.shared.wallet(by: w)
            }
        }
    }
    
    fileprivate let _tableController = ContactsController()
    private let _contactOptionsController = WalletContactOptions()

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
        
        title = NSLocalizedString("Send coins", comment: "")

        navigationController?.navigationBar.prefersLargeTitles = true

        if isModal {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel,
                                                               target: self, action: #selector(back(sender:)))
        }
        else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "button-back"),
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(back(sender:)))
        }
        
        if !isBook {
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
    }
    
    @objc private func back(sender:Any) {
        if isModal {
            dismiss(animated: true)
        }
        else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc private func add(sender:Any) {
        _contactOptionsController.contact = nil
        _contactOptionsController.wallet = self.wallet
        present(_contactOptionsController, animated: true)
    }
}

class WalletContactsModal: NavigationController {

    public var style:CoinsOperation.Style = .contact {
        didSet{
            contentController._tableController._sendCoinsController.style = style
        }
    }
    
    public var isBook:Bool = false {
        didSet{
            contentController.isBook = true
        }
    }

    public var walletKey:String? {
        didSet{
           contentController.walletKey = walletKey
        }
    }

    let contentController = WalletContacts()
    override func viewDidLoad() {
        super.viewDidLoad()
        contentController.isBook = isBook
        contentController.isModal = true
        view.backgroundColor = Config.Colors.background
        setViewControllers([contentController], animated: true)
    }
}


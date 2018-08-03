//
//  SendChosser.swift
//  MileWallet
//
//  Created by denn on 29.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit
import QRCodeReader

class SendCoinsChooser: Controller {
    
    public var wallet:WalletContainer? {
        didSet {
            _tableController.wallet = wallet
        }
    }
    
    private let bg = UIImageView(image: Config.Images.basePattern)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(self.close(sender:)))
        
        contentView.addSubview(bg)
        bg.contentMode = .scaleAspectFill
        bg.snp.makeConstraints { (m) in
            m.edges.equalTo(view.snp.edges)
        }
        
        addChildViewController(_tableController)
        view.addSubview(_tableController.view)
        _tableController.didMove(toParentViewController: self)
        
        _tableController.view.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            m.left.right.equalTo(contentView)
        }
    }
    
    @objc private func close(sender:Any){
        dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let a = wallet?.attributes else {
            return
        }
        //navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("Send coins", comment: "")
        bg.backgroundColor = UIColor(hex: a.color)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    fileprivate lazy var _tableController = SendConisChooserController()
}

class CoinsChooserCell: UITableViewCell {
    
    public var actionHandler:((_ sender:CoinsChooserCell)->Void)?
   
    public var actionIcon:UIImage? {
        didSet{
            accessor.image = actionIcon
        }
    }
    
    public var title:String? {
        didSet{
            label.text = title
        }
    }
    
    public var placeHolder:String? {
        didSet {
            textField.placeholder = placeHolder
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(textField)
        contentView.addSubview(accessor)
        selectionStyle = .none

        accessor.sizeToFit()
        accessor.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(20)
            m.bottom.equalToSuperview().offset(-20)
            m.centerX.equalTo(contentView.snp.right).offset(-40)
        }
        
        label.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.right.equalTo(accessor.snp.left).offset(-10)
            m.top.equalToSuperview().offset(10)
            m.bottom.equalTo(contentView.snp.centerY)
        }
        
        textField.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.right.equalTo(accessor.snp.left).offset(-10)
            m.bottom.equalToSuperview().offset(-10)
            m.top.equalTo(contentView.snp.centerY)
        }

    }

    private lazy var accessor:UIImageView = {
        let b = UIImageView()
        b.contentMode = .scaleAspectFit
        return b
    }()

    private lazy var textField:UITextField = {
        let t = UITextField.nameField(placeholder: "")
        t.font = Config.Fonts.address
        t.adjustsFontSizeToFitWidth = true
        t.isUserInteractionEnabled = false
        return t
    }()
    
    private let label:UILabel = {
        let l = UILabel()
        return l
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("CoinsChooserCell ... ")
    }
}

fileprivate class SendConisChooserController: UITableViewController {
    fileprivate let cellReuseIdendifier = "cell"
    public lazy var qrCodeReader:QRReader = {return QRReader(controller: self)}()

    public var wallet:WalletContainer?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor.clear
        tableView.keyboardDismissMode = .onDrag
        tableView.register(CoinsChooserCell.self, forCellReuseIdentifier: cellReuseIdendifier)
    }
        
    class Action {
        @objc var action:((_ sender:CoinsChooserCell) -> ())?
        let title:String?
        let placeHolder:String?
        let icon:UIImage?
        
        init(action:((_ sender:CoinsChooserCell) -> ())?,placeHolder:String?,title:String?,icon:UIImage?) {
            self.action = action
            self.title = title
            self.icon = icon
            self.placeHolder = placeHolder
        }
    }
    
    lazy var actions:[Action] = [
       
        Action(action: { (cell) in
            
            self._walletContacts.walletKey = self.wallet?.wallet?.publicKey
            self.presentInNavigationController(self._walletContacts, animated: true)
            
        }, placeHolder: NSLocalizedString("Choose recipient from address book", comment: ""),
           title: NSLocalizedString("To contact", comment: ""),
           icon: UIImage(named: "button-to-contact")),
        
        Action(action: { (cell) in
            
            self.qrCodeReader.open { (reader, result) in
                self.reader(reader, didScanResult: result)
            }
            
        }, placeHolder: NSLocalizedString("Scan address from phone camera", comment: ""),
           title: NSLocalizedString("Read", comment: ""),
           icon: UIImage(named: "button-read")),
        
        Action(action: { (cell) in
            
            //cell.placeHolder = UIPasteboard.general.string
            self._sendCoinsController.style = .publicKey
            self._sendCoinsController.contact = nil
            self._sendCoinsController.wallet = self.wallet
            self.presentInNavigationController(self._sendCoinsController, animated: true)
            
            
        }, placeHolder: NSLocalizedString("Type or paste transfer address", comment: ""),
           title: NSLocalizedString("To address", comment: ""),
           icon: UIImage(named: "button-to-address")),
        
        ]
    
    fileprivate var _sendCoinsController:CoinsOperation = CoinsOperation()
    
    fileprivate var _walletContacts:WalletContacts = {
        let w = WalletContacts()
        w.sendingConinsState = true
        return w
    }()
    
    var currentPuKeyQr:String?
    var currentNameQr:String?
}

extension SendConisChooserController {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {

        reader.stopScanning()

        if result.value.hasPrefix(Config.Shared.Wallet.publicKey) {
            
            reader.dismiss(animated: true) {
                let pk = result.value.replacingOccurrences(of: Config.Shared.Wallet.publicKey, with: "")
                self._sendCoinsController.style = .publicKey
                self._sendCoinsController.contact = nil
                self._sendCoinsController.newPublicKey = pk
                self._sendCoinsController.wallet = self.wallet
                self.presentInNavigationController(self._sendCoinsController, animated: true)
            }
            
        }
        else if let invoice = result.value.qrCodePayment {
            
            reader.dismiss(animated: true) {
                self._sendCoinsController.contact = nil
                self._sendCoinsController.style = .publicKey
                self._sendCoinsController.invoice = (publicKey:invoice.publicKey, assets:invoice.assets, amount:invoice.amount, name:nil)
                self._sendCoinsController.wallet = self.wallet
                self.presentInNavigationController(self._sendCoinsController, animated: true)
            }
            
        }
        else {
            reader.dismiss(animated: true) {
                UIAlertController(title: nil,
                                  message: NSLocalizedString("Public key is not valid", comment: ""),
                                  preferredStyle: .actionSheet)
                    .addAction(title: NSLocalizedString("Close", comment: ""), style: .cancel)
                    .present(by: self)
            }
        }
    }
}

// MARK: - Datasource
extension SendConisChooserController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for i in 0..<actions.count {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! CoinsChooserCell
            let action = actions[i]
            cell.placeHolder = action.placeHolder
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! CoinsChooserCell
        
        let action = actions[indexPath.row]
        
        cell.actionIcon = action.icon
        cell.placeHolder = action.placeHolder
        cell.title = action.title
        cell.actionHandler = action.action
        
        cell.contentView.add(border: .bottom,
                             color: Config.Colors.bottomLine,
                             width: 1,
                             padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        )
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

extension SendConisChooserController {
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.03)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CoinsChooserCell
        cell.backgroundColor = UIColor.clear
        
        let action = actions[indexPath.row]
        action.action?(cell )
    }
}

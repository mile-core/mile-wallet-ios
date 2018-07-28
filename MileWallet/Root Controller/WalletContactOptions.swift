//
//  WalletContactOptions.swift
//  MileWallet
//
//  Created by denn on 28.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

class WalletContactOptions: NavigationController {
    
    public var wallet:WalletContainer? {
        set{
            contentController.wallet = newValue
        }
        get {
            return contentController.wallet
        }
    }
    public var contact:Contact? {
        set{
            contentController.contact = newValue
        }
        get {
            return contentController.contact
        }
    }

    let contentController = WalletContactOptionsControllerImp()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Config.Colors.background
        setViewControllers([contentController], animated: true)
    }
}

class WalletContactOptionsControllerImp: Controller, UITextFieldDelegate {
    
    fileprivate var wallet:WalletContainer?
    fileprivate var contact:Contact? {
        didSet{
            if contact == nil {
                _tableController.avatarImage = nil
                _tableController.name.text = nil
                _tableController.publicKey.text = nil
                _tableController.loadButton.setImage(_tableController.loadImage, for: .normal)
            }
        }
    }
    
    private let _tableController = ContactController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closePayments(sender:)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneHandler(_:)))
        
        addChildViewController(_tableController)
        view.addSubview(_tableController.view)
        _tableController.didMove(toParentViewController: self)
        
        _tableController.view.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            m.left.right.equalTo(contentView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //_tableController.load.setImage(_tableController.loadImage, for: .normal)
        
        if let contact = self.contact {
            title = NSLocalizedString("Send coins to", comment: "") + ": " + contact.name!
            if let photo = contact.photo {
            let image = UIImage(data: photo)
                _tableController.loadButton.setImage(image, for: .normal)
            }
        }
        else {
            title = NSLocalizedString("New contact", comment: "")
        }
        
        if let a = wallet?.attributes{
            (navigationController as? NavigationController)?.titleColor = UIColor(hex: a.color)
        }
    }
    
    @objc private func closePayments(sender:Any){
        dismiss(animated: true)
    }
    
    @objc private func doneHandler(_ sender: UIButton) {
        if let contact = self.contact {
            //self.updateWallet(wallet: wallet)
        }
        else {
            addContact()
        }
    }
    
    private func addContact() {
        guard let name = self._tableController.name.text,
            let publicKey = self._tableController.publicKey.text, !name.isEmpty, !publicKey.isEmpty
            else {
               UIAlertController(title: nil,
                                 message: NSLocalizedString("Name and Public key must be defined", comment: ""),
                                 preferredStyle: .actionSheet)
                .addAction(title: NSLocalizedString("Close", comment: ""), style: .cancel)
                .present(by: self)
                return
        }
        
        let newContact = Contact()
        
        newContact.name = name
        newContact.publicKey = publicKey
        if let avatar = _tableController.avatarImage {
            let data = UIImageJPEGRepresentation(avatar, 0.85)
            newContact.photo = data
        }
        
        do {
            try Model.shared.context.save()
        }
        catch let error {
            print("Add new contact error: \(error)")
        }
        
        dismiss(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

class ContactController: UITableViewController {
    
    let cellReuseIdendifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor.clear
        tableView.keyboardDismissMode = .onDrag
    }
    
    var didLayout = false
    override func viewDidLayoutSubviews() {
        if !self.didLayout {
            self.didLayout = true // only need to do this once
            self.tableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    var avatarImage:UIImage?
    
    let loadImage = UIImage(named: "button-load-contact-image")
    
    lazy var loadButton:RoundButton = {
        let load = RoundButton(image: self.loadImage,
               action: { (sender) in
                self.imagePicker()
        })
        return load
    }()
    
    lazy var name:UITextField = UITextField.nameField(placeholder: NSLocalizedString("Contact name", comment: ""))
    lazy var publicKey:UITextField = UITextField.nameField(placeholder: NSLocalizedString("Public key", comment: ""))

    fileprivate lazy var list:[UIView] = [
        {
            return self.name
        }(),
        {
            return self.publicKey
        }(),
        {
            let v = UIView()
            let u = UITextField.nameField(placeholder: NSLocalizedString("Contact image", comment: ""))
            u.isUserInteractionEnabled = false

            v.addSubview(u)
            v.addSubview(self.loadButton)
            
            u.snp.makeConstraints({ (m) in
                m.right.left.equalTo(v)
                m.top.equalTo(v)
                m.bottom.equalTo(v.snp.centerY).offset(-25)
            })
            
            self.loadButton.snp.makeConstraints({ (m) in
                m.left.equalTo(v)
                m.width.equalTo(self.loadButton.snp.height)
                m.bottom.equalTo(v)
                m.top.equalTo(v.snp.centerY).offset(-20)
            })
            
            return v
        }()
    ]
}

class PickerController: UIImagePickerController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = Config.Colors.defaultColor
        navigationBar.tintColor = UIColor.white
        navigationBar.backgroundColor = Config.Colors.defaultColor
        navigationBar.setBackgroundImage(Config.Images.basePattern, for: UIBarMetrics.default)
        
        navigationBar.titleTextAttributes=[
            NSAttributedStringKey.font : Config.Fonts.toolBar,
            NSAttributedStringKey.foregroundColor : Config.Colors.button,
        ]
    }
}

extension ContactController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static let heights:[CGFloat] = [ 80, 80, 160]
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let size =  CGSize(width: image.size.width/4, height: image.size.height/4)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        image.draw(in: CGRect(origin: .zero, size:size))
        avatarImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        let copy = UIImage(cgImage: avatarImage!.cgImage!)
        
        loadButton.setImage(copy, for: .normal)
        
        picker.dismiss(animated: true)
    }
    
    func imagePicker()  {
        let picker = PickerController()
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        let v = list[indexPath.row]
        cell.addSubview(v)
        v.snp.makeConstraints { (m) in
            m.left.right.equalTo(cell).offset(30)
            m.bottom.equalTo(cell).offset(-20)
            m.top.equalTo(cell).offset(20)
        }
        if indexPath.row < list.count - 1 {
            cell.contentView.add(border: .bottom,
                                 color: UIColor.black.withAlphaComponent(0.1),
                                 width: 1,
                                 padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            )
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ContactController.heights[indexPath.row]
    }
    
}

extension ContactController {
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = UIColor.clear
    }
}

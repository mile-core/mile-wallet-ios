//
//  SuccessController.swift
//  MileWallet
//
//  Created by denn on 03.08.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import MileWalletKit

class SuccessController: UIViewController {

    public var publicKey:String?
    public var amount:String?
    public var asset:Asset?

    @IBOutlet weak var defaultImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet fileprivate weak var closeButton: UIButton!
    @IBOutlet fileprivate weak var amountLabel: UILabel!
    @IBOutlet fileprivate weak var messageLabel: UILabel!
    
    @IBOutlet weak var publicKeyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.layer.cornerRadius = Config.buttonRadius
        
        closeButton.layer.masksToBounds = true
        closeButton.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.borderWidth = 2
        avatarImageView.contentMode = .scaleAspectFill
    }

    private var defaultAvatar:UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeButton.setTitleColor(UIColor.black, for: .normal)
        amountLabel.text = amount

        publicKeyLabel.text = ""

        guard let pk = publicKey else {
            messageLabel.text = (asset?.name ?? "") + " " + NSLocalizedString("sent!", comment: "")
            defaultImageView.alpha = 1
            avatarImageView.alpha = 0
            return
        }

        if let contact = Contact.find(pk, for: "publicKey").first,
            let photo = contact.photo,
            let name = contact.name {
            
            messageLabel.text = (asset?.name ?? "") + " " + NSLocalizedString("sent for ", comment: "") + name + "!"
            
            defaultImageView.alpha = 0
            avatarImageView.alpha = 1
            avatarImageView.image = UIImage(data: photo)
        }
        else {
            messageLabel.text = (asset?.name ?? "") + NSLocalizedString(" sent to ", comment: "")
            publicKeyLabel.text = pk
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        publicKey = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeHandler(_ sender: UIButton) {
        if let pc = self.presentingViewController {
            dismiss(animated: false) {
                pc.dismiss(animated: true)
            }
        }
        else {
          dismiss(animated: true)
        }
    }
}

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

    public var amount:String?
    public var message:String?
    
    @IBOutlet fileprivate weak var closeButton: UIButton!
    @IBOutlet fileprivate weak var amountLabel: UILabel!
    @IBOutlet fileprivate weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.layer.cornerRadius = Config.buttonRadius
        closeButton.layer.masksToBounds = true
        closeButton.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeButton.setTitleColor(UIColor.black, for: .normal)
        amountLabel.text = amount
        messageLabel.text = message
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

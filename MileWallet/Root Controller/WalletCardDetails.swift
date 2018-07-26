//
//  WalleDetailsController.swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import SnapKit
import MileWalletKit

class WalletCardDetails: UIViewController {
    
    let detailsView:UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(detailsView)
        detailsView.backgroundColor = Config.Colors.background
        detailsView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }
    
}

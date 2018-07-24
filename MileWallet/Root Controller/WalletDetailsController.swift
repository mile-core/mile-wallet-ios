//
//  WalleDetailsController.swift
//  MileWallet
//
//  Created by denn on 24.07.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import SnapKit

class WalletDetailsView: UIView {
    
}

class WalletDetailsController: UIViewController {
    
    let detailsView:WalletDetailsView = WalletDetailsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(detailsView)
        detailsView.backgroundColor = UIColor(hex: 0x6679FD)
        detailsView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }
    
}

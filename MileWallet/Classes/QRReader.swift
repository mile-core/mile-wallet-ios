//
//  QRReader.swift
//  MileWallet
//
//  Created by denis svinarchuk on 19.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation

class QRReader: QRCodeReaderViewControllerDelegate {
    
    var controller:UIViewController
    
    init(controller: UIViewController) {
        self.controller = controller
    }
    
    func open(complete:((_ reader: QRCodeReaderViewController, _ result: QRCodeReaderResult)->Void)?) {
        
        guard checkScanPermissions() else { return }
        
        self.complete = complete
        
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate               = self        
        
        controller.present(readerVC, animated: true, completion: nil)
    }
    
    private var complete:((_ reader: QRCodeReaderViewController, _ result: QRCodeReaderResult)->Void)?
    
    // MARK: - QRCodeReader Delegate Methods
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            
            $0.reader                  = QRCodeReader(metadataObjectTypes:  [.qr], 
                                                      captureDevicePosition: .back)
            $0.showTorchButton         = true
            $0.preferredStatusBarStyle = .lightContent
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - Actions
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: { (flag) in
                                
                            }) //.openURL(settingsURL)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            controller.present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        complete?(reader,result)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()        
        controller.dismiss(animated: true, completion: nil)
    }
}

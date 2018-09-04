//
//  SingleKeyWalletController.swift
//  BankexWallet
//
//  Created by Vladislav on 18.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import UIKit
import QRCodeReader
import Amplitude_iOS

class SingleKeyWalletController: UIViewController,UITextFieldDelegate,ScreenWithContentProtocol {
    
    
    
    enum State {
        case notAvailable,available
    }
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var clearButton:UIButton!
    @IBOutlet weak var privateKeyTextView:UITextView!
    @IBOutlet weak var singleKeyView:SingleKeyView!
    @IBOutlet weak var separator1:UIView!
    @IBOutlet weak var separator2:UIView!
    @IBOutlet weak var importButton:UIButton!
    @IBOutlet weak var pasteButton:UIButton!
    
    
    //MARK: - Properties
    
    let privateKeyView = SingleKeyView()
    
    let service = SingleKeyServiceImplementation()
    let router = WalletCreationTypeRouterImplementation()
    
    lazy var readerVC:QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes:[.qr],captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
        builder.showSwitchCameraButton = false
    }()
    
    var state:State = .notAvailable {
        didSet {
            if state == .notAvailable {
                clearButton.isHidden = true
                importButton.isEnabled = false
                importButton.backgroundColor = WalletColors.defaultGreyText.color()
                privateKeyTextView.returnKeyType = .next
            }else {
                clearButton.isHidden = false
                importButton.isEnabled = true
                importButton.backgroundColor = WalletColors.blueText.color()
                privateKeyTextView.returnKeyType = .done
            }
        }
    }

    
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        state = .notAvailable
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let text = privateKeyTextView.text {
            if text == "\n" {
                privateKeyTextView.applyPlaceHolderText(with: "Enter your passphrase")
            }
        }
        view.endEditing(true)
    }
    
    
    
    //MARK: - Methods
    
    func clearTextFields() {
        singleKeyView.nameWalletTextField.text = ""
        view.endEditing(true)
    }
    
    func configure() {
        privateKeyTextView.delegate = self
        singleKeyView.delegate = self
        privateKeyTextView.contentInset.bottom = 10.0
        privateKeyTextView.applyPlaceHolderText(with: NSLocalizedString("Enter your private key", comment: ""))
        privateKeyTextView.autocorrectionType = .no
        privateKeyTextView.autocapitalizationType = .none
        setupPasteButton()
    }
    
   
    
    //MARK: - IBActions
    @IBAction func clearTextView(_ sender:Any) {
        privateKeyTextView.applyPlaceHolderText(with: NSLocalizedString("Enter your private key", comment: ""))
        privateKeyTextView.moveCursorToStart()
        state = .notAvailable
    }
    
    @IBAction func createPrivateKeyWallet(_ sender:Any) {
        service.createNewSingleAddressWallet(with: singleKeyView.nameWalletTextField.text, fromText: privateKeyTextView.text, password: nil) { (error) in
            if let _ = error {
                self.showCreationAlert()
            }
            Amplitude.instance().logEvent("Wallet Imported")
            if !UserDefaults.standard.bool(forKey: "passcodeExists") {
                self.performSegue(withIdentifier: "goToPinFromImportSingleKey", sender: self)
            } else {
                self.performSegue(withIdentifier: "showProcessFromImportSecretKey", sender: self)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PasscodeLockController {
            destinationViewController.newWallet = false
        }
        if let vc = segue.destination as? SendingInProcessViewController {
            vc.fromEnterScreen = true
        }
    }
    
    fileprivate func setupPasteButton() {
        pasteButton.layer.borderColor = WalletColors.blueText.color().cgColor
        pasteButton.layer.borderWidth = 2.0
        pasteButton.layer.cornerRadius = 15.0
        pasteButton.setTitle(NSLocalizedString("Paste", comment: ""), for: .normal)
        pasteButton.setTitleColor(WalletColors.blueText.color(), for: .normal)
    }
    
    
}




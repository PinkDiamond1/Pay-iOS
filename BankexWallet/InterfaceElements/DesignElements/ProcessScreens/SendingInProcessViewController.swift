//
//  SendingInProcessViewController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/8/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

protocol SendingResultInformation: class {
    func transactionDidSucceed(withAmount: String, address: String)
    
    func transactionDidFail()
    
    func transactionCanProceed(withAmount: String,
                               address: String,
                               transactionToSend: TransactionIntermediate,
                               password: String)
}

class SendingInProcessViewController: UIViewController,
SendingResultInformation {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var processTitleLabel: UILabel?

    
    var amountToSend: String?
    var destinationAddressToSend: String?
    var transactionToSend: TransactionIntermediate?
    var inputtedPassword: String?
    
    var fromEnterScreen = false
    var textToShow: String?
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SendingSuccessViewController {
            controller.transactionAmount = transactionAmount
            controller.addressToSend = recipientAddress
        }
        guard segue.identifier == "showConfirmation",
            let confirmation = segue.destination as? SendingConfirmationController else {
                return
        }
        confirmation.amount = amountToSend
        confirmation.destinationAddress = destinationAddressToSend
        confirmation.transaction = transactionToSend
        confirmation.inputtedPassword = inputtedPassword
        amountToSend = nil
        destinationAddressToSend = nil
        transactionToSend = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel?.text = textToShow == nil ? "Sending funds" : textToShow!
        processTitleLabel?.text = "Retrieving data"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textToShow = nil
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if fromEnterScreen {
            DefaultTokensServiceImplementation().downloadAllAvailableTokensIfNeeded {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showTabBar()
            }
        }
    }
    
    
    var transactionAmount: String?
    var recipientAddress: String?
    func transactionDidSucceed(withAmount: String, address: String) {
        transactionAmount = withAmount
        recipientAddress = address
        performSegue(withIdentifier: "showSuccess", sender: self)
    }
    
    func transactionDidFail() {
        performSegue(withIdentifier: "showError", sender: self)
    }
    
    func transactionCanProceed(withAmount: String, address: String, transactionToSend: TransactionIntermediate,
                               password: String) {
        amountToSend = withAmount
        destinationAddressToSend = address
        self.transactionToSend = transactionToSend
        inputtedPassword = password
        performSegue(withIdentifier: "showConfirmation", sender: self)
    }
}

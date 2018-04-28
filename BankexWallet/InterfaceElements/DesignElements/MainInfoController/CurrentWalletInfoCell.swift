//
//  CurrentWalletInfoCell.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina  on 4/4/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class CurrentWalletInfoCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var amountInDollars: UILabel!
    
    let keyService = SingleKeyServiceImplementation()
    
    var utilsService: UtilTransactionsService!
    let tokensService = CustomERC20TokensServiceImplementation()
    

    @IBOutlet weak var tokenIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.amountLabel.text = "..."
        utilsService = tokensService.selectedERC20Token().address.isEmpty ? UtilTransactionsServiceImplementation() :
            CustomTokenUtilsServiceImplementation()
        updateBalance()
        
        // Initialization code
        tokenIconImageView.image = PredefinedTokens(with: tokensService.selectedERC20Token().symbol).image()
        walletNameLabel.text = keyService.selectedWallet()?.name
        symbolLabel.text = tokensService.selectedERC20Token().symbol.capitalized
        
    }

    // MARK: Balance
    func updateBalance() {
        guard let selectedAddress = keyService.selectedAddress() else {
            return
        }
        utilsService.getBalance(for: tokensService.selectedERC20Token().address, address: selectedAddress) { (result) in
            switch result {
            case .Success(let response):
                // TODO: it shouldn't be here anyway and also, lets move to background thread
                let formattedAmount = Web3.Utils.formatToEthereumUnits(response, toUnits: .eth, decimals: 4)
                self.amountLabel.text = formattedAmount!
            case .Error(let error):
                self.amountLabel.text = "..."

                print("\(error)")
            }
        }
    }
    
}

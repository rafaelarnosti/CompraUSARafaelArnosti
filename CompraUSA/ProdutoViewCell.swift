//
//  ProdutoViewCell.swift
//  CompraUSA
//
//  Created by rafael on 16/10/17.
//  Copyright © 2017 rafael. All rights reserved.
//

import UIKit

class ProdutoViewCell: UITableViewCell {
    @IBOutlet weak var ivImagem: UIImageView!
    @IBOutlet weak var lbProduto: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  InputCell.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 21/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

/// Displays a label and takes a number as input.
class NumberInputCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var inputField: UITextField!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        inputField.keyboardType = .NumberPad
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

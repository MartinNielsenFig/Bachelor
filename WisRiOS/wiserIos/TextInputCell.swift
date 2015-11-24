//
//  InputCell.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 02/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

/// Displays a label and takes text input.
class TextInputCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var inputField: UITextField!

    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Utilities
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

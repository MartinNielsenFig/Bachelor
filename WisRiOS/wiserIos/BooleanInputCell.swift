//
//  BooleanInputCell.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 03/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

/// Displays a label and shows a UISwitch
class BooleanInputCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var uiSwitch: UISwitch!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

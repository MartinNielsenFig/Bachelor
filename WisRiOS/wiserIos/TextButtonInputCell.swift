//
//  TextButtonInputCell.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 24/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class TextButtonInputCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

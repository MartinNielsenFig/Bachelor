//
//  QuestionViewCell
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 24/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class QuestionViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var downvoteCounter: UILabel!
    @IBOutlet weak var downvoteImage: UIImageView!
    
    @IBOutlet weak var upvoteCounter: UILabel!
    @IBOutlet weak var upvoteImage: UIImageView!
    
    override func awakeFromNib() {
        upvoteImage.image = UIImage(named: "Upvote")
        downvoteImage.image = UIImage(named: "Downvote")
        
        downvoteCounter.text = "0"
        upvoteCounter.text = "0"
        
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

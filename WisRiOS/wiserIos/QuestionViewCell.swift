//
//  QuestionViewCell
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 24/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

/// Displays a Question on a list with up/down vote graphics and text.
class QuestionViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var label: UILabel!
    
    /// The downvote counter is shown in the cell
    @IBOutlet weak var downvoteCounter: UILabel!
    @IBOutlet weak var downvoteImage: UIImageView!
    
    /// The upvote counter is shown in the cell
    @IBOutlet weak var upvoteCounter: UILabel!
    @IBOutlet weak var upvoteImage: UIImageView!
    
    //MARK: Lifecycle
    
    override func awakeFromNib() {
        defaultImage()
        
        downvoteCounter.text = "0"
        upvoteCounter.text = "0"
        
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK: Utilities
    
    func defaultImage() {
        upvoteImage.image = UIImage(named: "ThumbsUp")
        downvoteImage.image = UIImage(named: "ThumbsDown")
    }
    
    func userHasVoted(up up: Bool) {
        downvoteImage.image = up ? UIImage(named: "ThumbsDown") : UIImage(named: "ThumbsDownBlue")
        upvoteImage.image = !up ? UIImage(named: "ThumbsUp") : UIImage(named: "ThumbsUpBlue")
    }
    
}

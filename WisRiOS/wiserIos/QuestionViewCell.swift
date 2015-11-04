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
    
    var callback: ((UILongPressGestureRecognizer) -> Void)?
    
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
    
    /**
     Enables this cell to have long press action. Takes a callback that is called when the long press on this cell is triggered.
     - parameter callback:	The function to call when this cell is long pressed
     */
    func enableLongPressMenu(callback: (UILongPressGestureRecognizer) -> Void) {
        self.callback = callback
        let gesture = UILongPressGestureRecognizer(target: self, action: "gestureCall:")
        gesture.minimumPressDuration = 2
        self.addGestureRecognizer(gesture)
    }
    
    func gestureCall(gesture: UILongPressGestureRecognizer) {
        self.callback!(gesture)
    }
    
    func defaultImage() {
        upvoteImage.image = UIImage(named: "ThumbsUp")
        downvoteImage.image = UIImage(named: "ThumbsDown")
    }
    
    func userHasVoted(up up: Bool) {
        downvoteImage.image = up ? UIImage(named: "ThumbsDown") : UIImage(named: "ThumbsDownBlue")
        upvoteImage.image = !up ? UIImage(named: "ThumbsUp") : UIImage(named: "ThumbsUpBlue")
    }
    
}

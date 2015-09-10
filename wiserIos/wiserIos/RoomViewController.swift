//
//  RoomViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 31/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController {
    
    //Passed from previous viewcontroller
    var room: Room? = nil

    
    @IBOutlet weak var roomName: UITextView!
    
    override func viewDidLoad() {
        print(room)
        roomName.text = room?.Name
    }
}

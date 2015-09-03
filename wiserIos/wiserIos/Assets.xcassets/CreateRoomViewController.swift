//
//  CreateRoomViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 02/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class CreateRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Fields
    var enablePwSwitch: UISwitch? = nil
    var pwInputCell: TextInputCell? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addRoomButtonPressed:"))
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cellIdentifier = "TextInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
            cell.label.text = "Room name"
            return cell
        }
            
        else if indexPath.row == 1 {
            let cellIdentifier = "TextInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
            cell.label.text = "Room tag"
            return cell
        }
        
        else if indexPath.row == 2 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            
            //Save as field and add a delegate function to this viewcontroller with name stateChanged
            enablePwSwitch = cell.uiSwitch
            enablePwSwitch?.addTarget(self, action: Selector("enablePwSwitchChanged:"), forControlEvents: UIControlEvents.ValueChanged)
            
            cell.label.text = "Enable password"
            return cell
        }
        
        else if indexPath.row == 3 {
            
            let cellIdentifier = "TextInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
            cell.label.text = "Password"
            cell.inputField.secureTextEntry = true
            
            pwInputCell = cell
            
            if let uiSwitch = enablePwSwitch {
                if !uiSwitch.on {
                    cell.inputField.enabled = false
                }
                else {
                    cell.inputField.enabled = true
                }
            }
            
            return cell
            
        }
            
        else if indexPath.row == 4 {
            let cellIdentifier = "SegmentedInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SegmentedInputCell
            cell.label.text = "Room radius"
            return cell

        }
            
        else if indexPath.row == 5 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = "Enable chat"
            return cell
        }
        
        else if indexPath.row == 6 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = "Enable anonymous"
            return cell
        }
        
        else if indexPath.row == 7 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = "Enable user questions"
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    
    //Handle selector events
    
    //Password switch
    func enablePwSwitchChanged(uiSwitch: UISwitch) {
        print("password switch pressed")
        pwInputCell?.inputField.enabled = uiSwitch.on
    }
    
    //Add room
    func addRoomButtonPressed(button: UIBarButtonItem) {
        print("add room button pressed")
    }
    
    
    
    
    
    
    
    
    
    
    
    
}

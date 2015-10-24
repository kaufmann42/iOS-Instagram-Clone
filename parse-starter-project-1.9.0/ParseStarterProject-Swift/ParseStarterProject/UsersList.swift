//
//  UsersList.swift
//  ParseStarterProject-Swift
//
//  Created by John Kaufmann on 10/20/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

var usernames = [""]
var userids = [""]
var isFollowing = ["":false]

class UsersList: UITableViewController {
    var currUser = PFUser.currentUser()!.username!
    
    @IBOutlet weak var userNameTitle: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTitle.title = "All Users List"
        
        var query = PFUser.query()
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects {
                
                usernames.removeAll(keepCapacity: true)
                userids.removeAll(keepCapacity: true)
                isFollowing.removeAll(keepCapacity: true)
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        if user.objectId! != PFUser.currentUser()?.objectId {
                            
                            usernames.append(user.username!)
                            userids.append(user.objectId!)
                            
                            var query = PFQuery(className: "followers")
                            
                            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
                            query.whereKey("following", equalTo: user.objectId!)
                            
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                
                                if let objects = objects {
                                    
                                    if objects.count > 0 {
                                        
                                        isFollowing[user.objectId!] = true
                                        
                                    } else {
                                        
                                        isFollowing[user.objectId!] = false
                                        
                                    }
                                }
                                
                                if isFollowing.count == usernames.count {
                                    
                                    self.tableView.reloadData()
                                    
                                }
                                
                                
                            })
                            
                            
                            
                        }
                    }
                    
                }
                
                
                
            }
            
            
            
        })
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return usernames.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = usernames[indexPath.row]
        
        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == true {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        }
        
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == false {
            
            isFollowing[followedObjectId] = true
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var following = PFObject(className: "followers")
            following["following"] = userids[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId
            
            following.saveInBackground()
            
        } else {
            
            isFollowing[followedObjectId] = false
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            var query = PFQuery(className: "followers")
            
            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        object.deleteInBackground()
                        
                    }
                }
                
                
            })
            
            
            
        }
        
    }
}

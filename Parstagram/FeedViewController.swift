//
//  FeedViewController.swift
//  Parstagram
//
//  Created by MannieC on 3/19/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    
    var posts = [PFObject]() //array called posts
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated) //after you compose a post you want view to refresh again
        
        //Create a query
        let query = PFQuery(className:"Posts")
        query.includeKeys( ["author", "comments", "comments.author"] ) //author column stores a pointer, we want it to return actuall object with this line
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{ //if posts isnt empty
                self.posts = posts! //Store ur data, put posts in array
                self.tableView.reloadData() //refresh feed to display posts
            }
        }
    }
    
    //Following MessageInputBar Pod
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //Two required functions for datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 1
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get post from query
        let post = posts[indexPath.section]
        //get comments
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if (indexPath.row == 0){
            //grab the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell //corresponds to postcell swift file, so u can use outlets
            
            let user = post["author"] as! PFUser //cast author item as PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            //get image url
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
        
        
        
    }

    @IBAction func onLogout(_ sender: Any) {
        //Create logout action.
        PFUser.logOut() //Clears parse cache
        
        //Display Login Screen
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        //Access window and rootViewController from SceneDelegate class
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginViewController
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Specify the post your commenting to
        let post = posts[indexPath.row]
        
        //Create comment object
        let comment = PFObject(className: "Comments")
        //Add Comment elements (columns to Comment table)
        comment["text"] = "This is a random comment"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment, forKey: "comments")
        post.saveInBackground { (success, error) in
            if success{
                print("Comment Saved!")
            }else{
                print("Error saving comment")
            }
        }
    }

}

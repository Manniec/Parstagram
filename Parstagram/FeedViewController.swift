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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false //hide text input bar by default
    var selectedPost: PFObject!
    
    var posts = [PFObject]() //array called posts
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //Configure text input to say
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        //Dismiss keyboard by dragging down on table view
        tableView.keyboardDismissMode = .interactive
        
        //Allow creating notificatiosn
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
    
    //Hide keyboard input
    @objc func keyboardWillBeHidden(note: Notification){
        //clear textfield
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        
    }
    
    //Following MessageInputBar Pod
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //Action when send/post button is clicked
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create the comment
        
        //Create comment object
        let comment = PFObject(className: "Comments")
        
        //Get text
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
       
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success{
                print("Comment Saved!")
            }else{
                print("Error saving comment")
            }
    
        }
        
        tableView.reloadData() //refresh so comment appears
        
        //Clear and dismiss input bar (same as keyboardWillBeHidden
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
        
    }
    
    //Two required functions for datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
        //the 2 counts the post and AddComment cells
        
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
            
        } else if (indexPath.row <= comments.count){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
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
        let post = posts[indexPath.section]
        //need to change this to section instead of row
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //Display comment text bar if add comment cell is tapped
        if (indexPath.row == comments.count + 1) {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            //Remember selected post
            selectedPost = post
        }
        
        
        /*
        //Add Fake Comment elements (columns to Comment table)
         
         //Create comment object
         let comment = PFObject(className: "Comments")
         
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
         */
    }

}

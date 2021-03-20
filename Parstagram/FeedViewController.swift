//
//  FeedViewController.swift
//  Parstagram
//
//  Created by MannieC on 3/19/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
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
        query.includeKey("author") //author column stores a pointer, we want it to return actuall object with this line
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{ //if posts isnt empty
                self.posts = posts! //Store ur data, put posts in array
                self.tableView.reloadData() //refresh feed to display posts
            }
        }
    }
    
    //Two required functions for datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //grab the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell //corresponds to postcell swift file, so u can use outlets
        
        //get post from query
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser //cast author item as PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        
        //get image url
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

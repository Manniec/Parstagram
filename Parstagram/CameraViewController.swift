//
//  CameraViewController.swift
//  Parstagram
//
//  Created by MannieC on 3/19/21.
//

import UIKit
import AlamofireImage //for resizeing image
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageField: UIImageView!
    
    @IBOutlet weak var captionTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        //special built in view controller
        let picker = UIImagePickerController()
        picker.delegate = self //returns photo when return from camera view controller
        picker.allowsEditing = true //shows photo editing screen for tweaking before finishing up photo
        
        //Check to see if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        } else{//if camera is not available
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //retrieve image from returned dictionary
        let image = info[.editedImage] as! UIImage
        //resize image so not too big
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        imageField.image = scaledImage
        
        //dismiss camera view
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func onPostButton(_ sender: Any) {
        //Create new PF Object
        let post = PFObject(className: "Posts") //className = DB table name; Parse automatically creates table for u if you dont have one
        
        //create values to save to columns of table
        post["caption"] = captionTextField.text!
        post["author"] = PFUser.current()!
        
        //Create binary object for image
        let imageData = imageField.image!.pngData()
        let file = PFFileObject(data: imageData!) //saves image to separate file
        //url to image
        post["image"] = file
        
        post.saveInBackground(block: { (success, error) in
                if success{
                    self.dismiss(animated: true, completion: nil)
                    print("saved!")
                }else{
                    print("error!")
                }
            })
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

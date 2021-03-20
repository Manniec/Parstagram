//
//  CameraViewController.swift
//  Parstagram
//
//  Created by MannieC on 3/19/21.
//

import UIKit

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
    
    @IBAction func onPostButton(_ sender: Any) {
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

//
//  CustomerProfileViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class CustomerProfileViewController: UIViewController {

    // the profile tab outlet
    @IBOutlet var roundedViews: [UIView]!
    
    
    
    
// Edit Profile Page section
    
    //Outlet
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtDateOfBirth: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!

    //Actions
    @IBAction func ChangeImageTapped(_ sender: UIButton) {
        changeTheUserImage(sender)
    }
    
    @IBAction func SaveButtonTaped(_ sender: Any) {
        saveUserChanges(sender)
    }
    
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        DeleteAccount(sender)
    }
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    



        
    

} //end of the class


// ------------------------------------------------------------//

//Customer Profile Tab functions
extension CustomerProfileViewController{
    
    
    //function to make the provided list of views circle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in roundedViews{
            view.layer.cornerRadius = view.frame.height / 2
            view.clipsToBounds = true
        }
        
    }
    
    
    
}


// edit profile page
extension CustomerProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // function show two options (camera, photo library)
    func changeTheUserImage(_ sender: Any){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let menue = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        menue.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            menue.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            menue.addAction(photoLibraryAction)
        }
        
        
        
        
        
        menue.popoverPresentationController?.sourceView = sender as? UIView
        present(menue, animated: true)
        
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //1. get the selected image
        //2. minimize it is size
        //3. change the user image data info
        //4. call the updateview method
        //5. dismis the view
    }
    
    
    
    // if the user click cancel run this method
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        //1. close the screen
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func saveUserChanges(_ sender: Any){
        //1. change the user information to the new information
        
        
        
        
        //2. show an alert notifying the user that the chnages saved into the database
        let saveAlert = UIAlertController(title: "Save Changes", message: "Your changes have been saved successfully.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            print("done")
        }
        
        saveAlert.addAction(okAction)
        
        present(saveAlert, animated: true, completion: nil)
    }
    
    
    func DeleteAccount(_ sender: Any){
        
        let DeleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to permanently delete your account? This action cannot be undone.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("cancel pressed")
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            
            if let LaunchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController() {
                LaunchScreen.modalPresentationStyle = .fullScreen
                self.present(LaunchScreen, animated: true, completion: nil)
            } else {
                print("LaunchScreen could not be instantiated.")
            }
        }
        
        DeleteAlert.addAction(cancelAction)
        
        DeleteAlert.addAction(deleteAction)
        
        present(DeleteAlert, animated: true)
        
    }
    
    
}

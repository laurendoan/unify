//
//
//  NotesViewController.swift
//  MessageKitTest
//
//  Created by Julian Ricky Moore on 4/6/19.
//  Copyright © 2019 JulianMoore. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase

class NotesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    // Instance variables.
    @IBOutlet weak var noteCollectionView: UICollectionView!
    @IBOutlet var toolbar: UIToolbar!
    var className = "CS439"
    var classId = ""
    var pics = [UIImage]()
    let noteCellIdentifier = "noteCellIdentifier"
    let viewImageSegueIdentifier = "viewImageSegueIdentifier"
    let backToMessagesSegueIdentifier = "backToMessagesSegueIdentifier"
    var imageSelected: UIImage!
    let picker = UIImagePickerController()
    
    // Sets up initial notes collection view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteCollectionView.delegate = self
        noteCollectionView.dataSource = self
        picker.delegate = self
        
        // Set title of chatroom.
        title = "Notes"
        
        // Gets database reference for current class images.
        let databaseClass = Database.database().reference().child("images").child(className)
        let query = databaseClass.queryLimited(toLast: 100)
        query.removeAllObservers()
        
        // Loads in current class images.
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data                = snapshot.value as? [String: String],
                let downloadURL         = data["downloadURL"],
                !downloadURL.isEmpty
            {
                let storageRef = Storage.storage().reference(forURL: downloadURL)
                // Download the data.
                storageRef.getData(maxSize: 4 * 1024 * 1024) { data, error in
                    if let _ = error {
                        print("AN ERROR READING NOTES") // Uh-oh, an error occurred!
                    } else {
                        // Data for image is returned.
                        let image = UIImage(data: data!)
                        if (image != nil && self != nil) {
                            self!.pics.append(image!)
                            self!.noteCollectionView.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show navigation bar when view appears.
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Set background color to panel background color.
        self.view.backgroundColor = JDColor.appSubviewBackground.color
        noteCollectionView.backgroundColor = JDColor.appSubviewBackground.color
        
        // Customize toolbar colors.
        self.toolbar.barTintColor = JDColor.appTabBarBackground.color
        self.toolbar.tintColor = JDColor.appAccent.color
    }
    
    // Return number of notes.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pics.count
    }

    // Set data for cell depending on row.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noteCellIdentifier, for: indexPath) as! NoteCollectionViewCell
        
        let img: UIImage = pics[indexPath.row]
        cell.imageView.image = img
        
        return cell
    }
    
    // Perform segue to view displaying image selected.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.imageSelected = pics[indexPath.row]
        performSegue(withIdentifier: viewImageSegueIdentifier, sender: self)
    }
    
    // Only 1 image per collection view section.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Brings up UIImagePickerController to allow user to select image from photo gallery to upload.
    @IBAction func uploadNoteButtonPressed(_ sender: UIBarButtonItem) {
        // Whole picture, not an edited version.
        picker.allowsEditing = false
        
        // Set the source to be the Photo Library.
        picker.sourceType = .photoLibrary
        
        // Present the picker in a full screen popover.
        picker.modalPresentationStyle = .popover
        
        present(picker, animated: true, completion: nil)
        
        // Popovers are REQUIRED to view the Photo Library.
        picker.popoverPresentationController?.barButtonItem = sender
    }
    
    // If no camera is available on the device, pop up an alert. (used from camera demo).
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    // Brings up camera to allow user to take image to upload.
    @IBAction func takePhotoButtonPressed(_ sender: UIBarButtonItem) {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            
            // Whole picture, not an edited version.
            picker.allowsEditing = false
            
            // Set the source to be the camera.
            picker.sourceType = .camera
            
            // Set camera mode to "photo".
            picker.cameraCaptureMode = .photo
            
            present(picker, animated: true, completion: nil)
            
        } else {
            noCamera()
        }
    }
    
    // Save image upon selection/ photo taken.
    internal func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // Get the selected picture.
        if let image = info[.originalImage] as? UIImage, let optimizedImageData = image.jpegData(compressionQuality: 0.6)
        {
            // Upload image from here.
            uploadImage(imageData: optimizedImageData)
        }
        picker.dismiss(animated: true, completion: {
            self.parent?.navigationController?.isNavigationBarHidden = true
        })
    }
    
    // Allows user to cancel and not take photo.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: {
            self.parent?.navigationController?.isNavigationBarHidden = true
        })
        
    }
    
    // Uploads image to database.
    func uploadImage(imageData: Data)
    {
        // Sets up loading icon.
        let activityIndicator = UIActivityIndicatorView.init(style: .gray)
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        // Generate data and database reference to upload.
        let uuid = UUID().uuidString
        let storageReference = Storage.storage().reference()
        let imageRef = storageReference.child("images").child(className).child(uuid)
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        // Places data in database with auto generated ID.
        imageRef.putData(imageData, metadata: uploadMetaData).observe(.success) { (metadata) in
            // Stop loading icon.
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Saves download URL to realtime databse with className to allow loading images by class.
                let databaseReference = Database.database().reference().child("images").child(self.className).child(uuid)
                let url = ["downloadURL": downloadURL.absoluteString]
                databaseReference.setValue(url)
            }
        }
    }
    
    // Segues to viewnoteviewcontroller to view note fullscreen.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == viewImageSegueIdentifier, let destination = segue.destination as? ViewNoteViewController {
            self.navigationController!.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            destination.newImage! = imageSelected
            destination.className = self.className
            destination.classId = classId
        }
    }
}

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

/*protocol BackDelegate {
    func backPressed()
}*/

class NotesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //var delegate: BackDelegate?

    //instance variables
    var className = "CS439"
    var classId = ""
    @IBOutlet weak var noteCollectionView: UICollectionView!
    @IBOutlet var toolbar: UIToolbar!
    var pics = [UIImage]()
    let noteCellIdentifier = "noteCellIdentifier"
    let viewImageSegueIdentifier = "viewImageSegueIdentifier"
    let backToMessagesSegueIdentifier = "backToMessagesSegueIdentifier"
    var imageSelected: UIImage!
    
    // sets up initial notes collection view
    override func viewDidLoad() {
        super.viewDidLoad()
        noteCollectionView.delegate = self
        noteCollectionView.dataSource = self
        
        // Set title of chatroom.
        self.navigationController?.isNavigationBarHidden = false
        title = "\(classId)"
        
        // gets database reference for current class images
        let databaseClass = Database.database().reference().child("images").child(className)
        let query = databaseClass.queryLimited(toLast: 10)
        query.removeAllObservers()
        
        // loads in current class images
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data                = snapshot.value as? [String: String],
                let downloadURL         = data["downloadURL"],
                !downloadURL.isEmpty
            {
                let storageRef = Storage.storage().reference(forURL: downloadURL)
                // Download the data
                storageRef.getData(maxSize: 4 * 1024 * 1024) { data, error in
                    if let _ = error {
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for image is returned
                        let image = UIImage(data: data!)
                        self!.pics.append(image!)
                        self!.noteCollectionView.reloadData()
                    }
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.backgroundColor = JDColor.appSubviewBackground.color
        noteCollectionView.backgroundColor = JDColor.appSubviewBackground.color
    }
    
    // return number of notes
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pics.count
    }
    
    /*@IBAction func backButtonPressed(_ sender: Any) {
        delegate?.backPressed()
    }*/
    
    // set data for cell depending on row
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noteCellIdentifier, for: indexPath) as! NoteCollectionViewCell
        
        let img: UIImage = pics[indexPath.row]
        cell.imageView.image = img
        
        return cell
    }
    
    // perform segue to view displaying image selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.imageSelected = pics[indexPath.row]
        performSegue(withIdentifier: viewImageSegueIdentifier, sender: self)
    }
    
    // only 1 image per collection view section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // brings up UIImagePickerController to allow user to select image from photo gallery to upload
    @IBAction func uploadNoteButtonPressed(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    // brings up camera to allow user to take image to upload
    @IBAction func takePhotoButtonPressed(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker, animated: true, completion: nil)
        } else {
            // if no camera available (simulation) display alert and cancel
            let alert = UIAlertController(title: "This device has no camera", message: "Please try again with a device supporting camera use.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    // save image upon selection/ photo taken
    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard (info[.originalImage] as? UIImage) != nil else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let optimizedImageData = image.jpegData(compressionQuality: 0.6)
        {
            // upload image from here
            uploadImage(imageData: optimizedImageData)
        }
        picker.dismiss(animated: true, completion: {
            self.view.frame = CGRect(x: self.view.frame.width/3, y: 0, width: self.view.frame.width*2/3, height: self.view.frame.height)
        })
    }
    
    // allows user to cancel and not take photo
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion:nil)
    }
    
    // uploads image to database
    func uploadImage(imageData: Data)
    {
        // sets up loading icon
        let activityIndicator = UIActivityIndicatorView.init(style: .gray)
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        // generate data and database reference to upload
        let uuid = UUID().uuidString
        let storageReference = Storage.storage().reference()
        let imageRef = storageReference.child("images").child(className).child(uuid)
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        // places data in database with auto generated ID
        imageRef.putData(imageData, metadata: uploadMetaData).observe(.success) { (metadata) in
            // stop loading icon
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                // saves download URL to realtime databse with className to allow loading images by class
                let databaseReference = Database.database().reference().child("images").child(self.className).child(uuid)
                let url = ["downloadURL": downloadURL.absoluteString]
                databaseReference.setValue(url)
            }
        }
    }
    
    // segues to viewnoteviewcontroller to view note fullscreen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == viewImageSegueIdentifier, let destination = segue.destination as? ViewNoteViewController {
            destination.newImage! = imageSelected
            destination.className = self.className
            destination.classId = classId
        }
    }
}

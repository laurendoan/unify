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

protocol BackDelegate {
    func backPressed()
}

class NotesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var delegate: BackDelegate?

    
    var className = "CS439"
    @IBOutlet weak var noteCollectionView: UICollectionView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var navBar: UINavigationBar!
    var pics = [UIImage]()
    let noteCellIdentifier = "noteCellIdentifier"
    let viewImageSegueIdentifier = "viewImageSegueIdentifier"
    var imageSelected: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteCollectionView.delegate = self
        noteCollectionView.dataSource = self
        
        // Sets the background color.
        UIColourScheme.instance.set(for:self)
        // Set title of chatroom.
        self.navigationController?.isNavigationBarHidden = false
        title = "\(className)"
        noteCollectionView.backgroundColor = UIColor(red: 230/255, green: 241/255, blue: 253/255, alpha: 1)
        
        let databaseClass = Database.database().reference().child("images").child(className)
        let query = databaseClass.queryLimited(toLast: 10)
        query.removeAllObservers()
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data                = snapshot.value as? [String: String],
                let downloadURL         = data["downloadURL"],
                !downloadURL.isEmpty
            {
                let storageRef = Storage.storage().reference(forURL: downloadURL)
                // Download the data, assuming a max size of 1MB (you can change this as necessary)
                storageRef.getData(maxSize: 4 * 1024 * 1024) { data, error in
                    if let _ = error {
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        self!.pics.append(image!)
                        self!.noteCollectionView.reloadData()
                    }
                }
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pics.count
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        delegate?.backPressed()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noteCellIdentifier, for: indexPath) as! NoteCollectionViewCell
        
        let img: UIImage = pics[indexPath.row]
        
        cell.imageView.image = img
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.imageSelected = pics[indexPath.row]
        performSegue(withIdentifier: viewImageSegueIdentifier, sender: self)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @IBAction func uploadNoteButtonPressed(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func takePhotoButtonPressed(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "This device has no camera", message: "Please try again with a device supporting camera use.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard (info[.originalImage] as? UIImage) != nil else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        if let profileImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let optimizedImageData = profileImage.jpegData(compressionQuality: 0.6)
        {
            // upload image from here
            uploadImage(imageData: optimizedImageData)
        }
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func uploadImage(imageData: Data)
    {
        let activityIndicator = UIActivityIndicatorView.init(style: .gray)
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        let uuid = UUID().uuidString
        let storageReference = Storage.storage().reference()
        let imageRef = storageReference.child("images").child(className).child(uuid)
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: uploadMetaData).observe(.success) { (metadata) in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                let databaseReference = Database.database().reference().child("images").child(self.className).child(uuid)
                let url = ["downloadURL": downloadURL.absoluteString]
                databaseReference.setValue(url)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == viewImageSegueIdentifier, let destination = segue.destination as? ViewNoteViewController {
            destination.newImage! = imageSelected
        }
    }
}

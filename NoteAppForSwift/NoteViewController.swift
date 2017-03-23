//
//  NoteViewController.swift
//  NoteAppForSwift
//
//  Created by 陳昶安 on 2017/3/23.
//  Copyright © 2017年 ANAN. All rights reserved.
//

import UIKit

protocol NoteViewControllerDelegate: class {
    
    func didFinishUpdateNote(note: Note)
    
}

class NoteViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var note: Note?
    
    var isNewImage: Bool = false
    
    
    weak var delegate: NoteViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.text = self.note?.text
        self.imageView.image = self.note?.image()
        
        //Autolayout - Remove at build time
        let ratioConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.imageView, attribute: NSLayoutAttribute.width, multiplier: 0.75, constant: 0)
        
        ratioConstraint.isActive = true
    }
    
    //MARK: IBAction
    
    @IBAction func done(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
        
        self.note?.text = self.textView.text
        //self.note?.image = self.imageView.image
        
        if self.isNewImage {
            
            let uuid = NSUUID()
            let homeURL = NSURL(fileURLWithPath: NSHomeDirectory())
            let documentURL = homeURL.appendingPathComponent("Documents")
            let imageName = "\(uuid.uuidString).jpg"
            let fileURL = documentURL?.appendingPathComponent(imageName)
            
            if let image = self.imageView.image,
                let imageData = UIImageJPEGRepresentation(image, 1) {
                do{
                    try imageData.write(to: fileURL!, options: [.atomicWrite])
                    //將舊的檔案名稱找出來
                    if let oldImageNmae = self.note?.imageName {
                        
                        let oldFileURL = documentURL?.appendingPathComponent(oldImageNmae)
                        try FileManager.default.removeItem(at: oldFileURL!)
                        
                        
                    }
                    
                    note?.imageName = imageName
                    
                } catch {
                    
                    print("error: \(error)")
                    
                }
            }
            
        }
    
        self.delegate?.didFinishUpdateNote(note: self.note!)
        
    }
    @IBAction func camera(_ sender: Any) {
        
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .savedPhotosAlbum
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            imageView.image = image
            self.isNewImage = true
            self.dismiss(animated: true, completion: nil)
            
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = image
            self.isNewImage = true
            self.dismiss(animated: true, completion: nil)
            
        } else {
            
            imageView.image = nil
            self.isNewImage = true
            print("imagePickerController 出了點錯")
            self.dismiss(animated: true, completion: nil)
            
        }
//        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        
//        imageView.image = image
        
        //self.isNewImage = true
        
        //dismiss(animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

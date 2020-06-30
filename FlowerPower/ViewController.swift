//
//  ViewController.swift
//  FlowerPower
//  Created by Nareshri Babu on 2020-05-02.
//  Copyright © 2020 Nareshri Babu. All rights reserved.
//  This app was created for learning purposes.
//  All images were only used for learning purposes and do not belong to me.
//  All sounds were only used for learning purposes and do not belong to me.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            
            
            //allows us to use core image image
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage")
            }
            
            detect(image: ciimage)
            
            //image view set to the user's image from their camera
            //imageView.image = userPickedImage

        }
        
        
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(image: CIImage) {
     
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("Could not classify image.")
            }
            
            self.navigationItem.title = classification.identifier.capitalized
            
            self.requestInfo(flowerName: classification.identifier)
        }
    
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    
    func requestInfo(flowerName: String) {
        
        let parameters : [String:String] = [
         "format" : "json",
         "action" : "query",
         "prop" : "extracts|pageimages",
         "exintro" : "",
         "explaintext" : "",
         "titles" : flowerName,
         "indexpageids" : "",
         "redirects" : "1",
         "pithumbsize" : "500"
         ]
        
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                print("Got the wikipedia info.")
                print(response)
                
                //use json to extract info
                let flowerJSON : JSON = JSON(response.result.value!)
                
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                
                let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                
                self.imageView.sd_setImage(with: URL(string: flowerImageURL))
                
                self.label.text = flowerDescription
                
                
            }
        }
    }
    
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)

        
    }
    
    
    
}


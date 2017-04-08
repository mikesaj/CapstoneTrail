//
//  UIImageExtension.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-23.
//  Copyright © 2017 MSD. All rights reserved.
//

//This class assists to store images in cache, for saving time and data to display all images

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    //this method stores images in cache
    func loadImageUsingCacheWithUrlString(urlString: String){
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject){
            self.image = cachedImage as? UIImage
            return
        }
        
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            
            if error != nil{
                print(error)
                return
            }
            
            if var downloadedImage = UIImage(data: data!){
                
                let customSize: CGSize = CGSize(width: 205.0, height: 205.0)
                downloadedImage = self.resizeImage(image: downloadedImage, targetSize: customSize)
                
                imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                self.image = downloadedImage                
                
            }
            
        }).resume()
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        // Figure out what our orientation is, and use that to form the rectangle
        let newSize:CGSize = CGSize(width: targetSize.width,  height: targetSize.height)
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


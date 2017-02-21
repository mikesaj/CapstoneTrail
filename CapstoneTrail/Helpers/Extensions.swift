//
//  Extensions.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-11.
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
            
            if let downloadedImage = UIImage(data: data!){
            
                imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                self.image = downloadedImage
            }
            
        }).resume()
        
    }
    
}

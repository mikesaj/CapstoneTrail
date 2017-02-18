//
//  Extensions.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-11.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {

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

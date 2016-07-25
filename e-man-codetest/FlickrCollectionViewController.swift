//
//  FlickrCollectionViewController.swift
//  e-man-codetest
//
//  Created by Nigel Stuckey on 25/07/2016.
//  Copyright © 2016 Alex Stuckey. All rights reserved.
//

import UIKit
import Foundation

class FlickrCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "PhotoCell"
    private let showPhotoSegueIdentifier = "ShowPicDetail"
    
    // Construct API URL
    private let apiRoot = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    private let apiConfig: [String: String] = ["api_key": "4e3145251a841b136cbcc772ba27059f",
                                               "tags": "dog",
                                               "per_page": "100",
                                               "extras": "url_m",
                                               "format": "json",
                                               "nojsoncallback": "1"
                                               ]
    
    
    private let imageQueue = dispatch_queue_create("stuckey.e-man-codetest", nil)
    
    private var photos = [NSURL]()
    private var modifiedAt = NSDate.distantPast()
    private var cache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set indicator, using white to contrast with black background
        collectionView?.infiniteScrollIndicatorStyle = .White
        
        // Set indicator margin, gives space for user to anticipate more content
        collectionView?.infiniteScrollIndicatorMargin = 40
        
        // Add infinite scroll handler
        collectionView?.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            self?.fetchData() {
                scrollView.finishInfiniteScroll()
            }
        }
        
        fetchData(nil)

    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == showPhotoSegueIdentifier {
            if let indexPath = collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                let url = photos[indexPath.item]
                if let _ = cache.objectForKey(url) {
                    return true
                }
            }
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == showPhotoSegueIdentifier {
            if let indexPath = collectionView?.indexPathForCell(sender as! UICollectionViewCell) {
                let controller = segue.destinationViewController as! PicDetailViewController
                let url = photos[indexPath.item]
                
                controller.photo = cache.objectForKey(url) as? UIImage
            }
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        collectionViewLayout.invalidateLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
        // Configure the cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrPicCollectionViewCell
        let url = photos[indexPath.item]
        let image = cache.objectForKey(url) as? UIImage
        
        cell.flickrPicUIImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        cell.flickrPicUIImageView.image = image
        
        if image == nil {
            downloadPhoto(url, completion: { (url, image) -> Void in
                let indexPath_ = collectionView.indexPathForCell(cell)
                if indexPath.isEqual(indexPath_) {
                    cell.flickrPicUIImageView.image = image
                }
            })
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    
    private func downloadPhoto(url: NSURL, completion: (url: NSURL, image: UIImage) -> Void) {
        dispatch_async(imageQueue, { () -> Void in
            if let data = NSData(contentsOfURL: url) {
                if let image = UIImage(data: data) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.cache.setObject(image, forKey: url)
                        completion(url: url, image: image)
                    })
                }
            }
        })
    }
    
    private func fetchData(handler: (Void -> Void)?) {
        
        // Construct URL
        var apiURL = apiRoot
        for (key, value) in apiConfig {
            apiURL = "\(apiURL)&\(key)=\(value)"
        }
        
        // Form an NSURL
        let requestURL = NSURL(string: apiURL)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(requestURL, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.handleResponse(data, response: response, error: error, completion: handler)
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            });
        })
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let delay = (photos.count == 0 ? 0 : 5) * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            task.resume()
        })
    }
    
    private func handleResponse(data: NSData!, response: NSURLResponse!, error: NSError!, completion: (Void -> Void)?) {
        if let _ = error {
//            showAlertWithError(error)
            completion?()
            return;
        }
        
        var parseError: NSError?
        var jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
        var responseDict: [String: AnyObject]?
        
        // Fix broken Flickr JSON
        jsonString = jsonString?.stringByReplacingOccurrencesOfString("\\'", withString: "'")
        let fixedData = jsonString?.dataUsingEncoding(NSUTF8StringEncoding)
        
        do {
            responseDict = try NSJSONSerialization.JSONObjectWithData(fixedData!, options: NSJSONReadingOptions()) as? [String: AnyObject]
        }
        catch {
            parseError = NSError(domain: "JSONError", code: 1, userInfo: [ NSLocalizedDescriptionKey: "Failed JSON parsing" ])
        }
        
        if let parseError = parseError {
            // Handle error properly... at some point
            NSLog("Error: \(parseError)")
            completion?()
            return
        }
        
        var indexPaths = [NSIndexPath]()
        let firstIndex = photos.count
        
        // Pull photos out of JSON
        if let items = responseDict?["photos"]!["photo"] as? NSArray {
            // Find the m-type URL for the photos (best size for this demo)
            if let urls = items.valueForKeyPath("url_m") as? [String] {
                for (i, url) in urls.enumerate() {
                    let indexPath = NSIndexPath(forItem: firstIndex + i, inSection: 0)
                    
                    photos.append(NSURL(string: url)!)
                    indexPaths.append(indexPath)
                }
            }
        }
        
        collectionView?.performBatchUpdates({ () -> Void in
            self.collectionView?.insertItemsAtIndexPaths(indexPaths)
            }, completion: { (finished) -> Void in
                completion?()
        });
    }


}

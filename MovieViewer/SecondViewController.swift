//
//  SecondViewController.swift
//  MovieViewer
//
//  Created by Isis Moran on 1/12/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import PKHUD
import AFNetworking

class SecondViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
 
    @IBOutlet weak var collectionView: UICollectionView!
    
    var refreshControl: UIRefreshControl!
    let delay = 3.0 * Double(NSEC_PER_SEC)
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.show()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double (NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
            PKHUD.sharedHUD.hide(afterDelay: 2.0)
        }
        
        refreshControl = UIRefreshControl()
        collectionView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                    }
                }
        });
        task.resume()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func delay(delay:Double, closure:() -> ()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCollection", forIndexPath: indexPath) as! MovieCollectionViewCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let posterPath = movie["poster_path"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
                
        if let posterPath = movie["poster_path"] as? String {
            cell.posterImage.setImageWithURL(imageUrl!)
        }
        
        return cell
    }
}
        
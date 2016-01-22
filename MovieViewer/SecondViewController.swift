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

class SecondViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
 
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var movieSearcher: UISearchBar!
    
    var filteredData: [NSDictionary]!
    var refreshControl: UIRefreshControl!
    let delay = 3.0 * Double(NSEC_PER_SEC)
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.show()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double (NSEC_PER_SEC)))
        
        refreshControl = UIRefreshControl()
        collectionView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        collectionView.dataSource = self
        movieSearcher.delegate = self
        
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
                            PKHUD.sharedHUD.hide(afterDelay: 1.5)
                            PKHUD.sharedHUD.contentView = PKHUDSuccessView()

                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                    }
                    self.filteredData = self.movies
                    self.collectionView.reloadData()
                }
        });
        task.resume()

    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? movies : movies!.filter({ (movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        self.collectionView.reloadData()
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
        
        if let filteredData = filteredData {
            return filteredData.count
        } else {
            return 0
        }
        
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCollection", forIndexPath: indexPath) as! MovieCollectionViewCell
        let movie = filteredData[indexPath.row]
        let title = movie["title"] as! String
        let posterPath = movie["poster_path"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
                
        if let posterPath = movie["poster_path"] as? String {
            cell.posterImage.setImageWithURL(imageUrl!)
        }
        
        return cell
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MovieSegue" {
            if let indexPath = self.collectionView?.indexPathForCell((sender as? MovieCollectionViewCell)!) {
                let detailVC = segue.destinationViewController as! TableViewMovieDetailsViewController
                detailVC.tableFilteredDict = self.filteredData[indexPath.row]
                
            }
        }
    }
    
    
}
        
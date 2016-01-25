//
//  TopRatedCollectionViewController.swift
//  MovieViewer
//
//  Created by Isis Moran on 1/19/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import PKHUD
import AFNetworking

class TopRatedCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var topMovieCollectionSearcher: UISearchBar!
    
    var filteredData: [NSDictionary]!
    var refreshControl: UIRefreshControl!
    let delay = 3.0 * Double(NSEC_PER_SEC)
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.show()
    
        let backImg: UIImage = UIImage(named: "table")!
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImg, forState: .Normal, barMetrics: .Default)
        
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        refreshControl = UIRefreshControl()
        topCollectionView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        refreshControl.backgroundColor = UIColor.blackColor()
        refreshControl.tintColor = UIColor(red: 127/255, green: 255/255, blue: 212/255, alpha: 1)
        
        topCollectionView.dataSource = self
        topCollectionView.delegate = self
        topMovieCollectionSearcher.delegate = self
        
        getNetworkData()
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        topMovieCollectionSearcher.showsCancelButton = true
        filteredData = searchText.isEmpty ? movies : movies!.filter({ (movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        self.topCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        topMovieCollectionSearcher.showsCancelButton = false
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
        delay(1, closure: {
            self.refreshControl.endRefreshing()
        })
    }
        
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = topCollectionView.dequeueReusableCellWithReuseIdentifier("TopCollectionCell", forIndexPath: indexPath) as! TopCollectionCell
        let movie = filteredData[indexPath.row]
        let title = movie["title"] as! String
        let posterPath = movie["poster_path"] as! String
            
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        let placeholderImage = UIImage(named: "placeholder")

        let imageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
        
        cell.topPosterView.setImageWithURLRequest(imageRequest, placeholderImage:  nil, success: {(imageRequest, imageResponse, image) -> Void in
            
            if imageResponse != nil {
                print("Image was not cached, fade in image")
                cell.topPosterView.alpha = 0.0
                cell.topPosterView.image = image
                UIView.animateWithDuration(0.7, animations: {() -> Void in
                    cell.topPosterView.alpha = 1.0
                })
            } else {
                print("Image was cached so just update the image")
                cell.topPosterView.image = image
            }
            },
            failure:  {(imageRequest, imageResponse, error) -> Void in
                cell.topPosterView.image = placeholderImage
                
        })
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "topMovieSegue" {
            if let indexPath = self.topCollectionView?.indexPathForCell((sender as? TopCollectionCell)!) {
                let detailVC = segue.destinationViewController as! MovieDetailsViewController
                detailVC.filteredDict = self.filteredData[indexPath.row]
            }
        }
    }
    
    func getNetworkData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)")
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
                            self.filteredData = self.movies
                            self.refreshControl.endRefreshing()
                            self.topCollectionView.reloadData()
                            PKHUD.sharedHUD.hide()
                            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
                            PKHUD.sharedHUD.dimsBackground = false
                            self.errorView.hidden = true
                    }
                } else {
                    print("error")
                    self.errorView.hidden = false
                    PKHUD.sharedHUD.hide()
                    PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
                    PKHUD.sharedHUD.dimsBackground = false
                    
                }
                
        });
        task.resume()
    }
    
    @IBAction func reconnectNetwork(sender: AnyObject) {
        getNetworkData()
    }
    
        
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         if let filteredData = filteredData {
           return filteredData.count
         } else {
           return 0
        }
    }
  }

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
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getNetworkData()
        
        let backImg: UIImage = UIImage(named: "table")!
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImg, forState: .Normal, barMetrics: .Default)
        
        self.movieSearcher.keyboardAppearance = UIKeyboardAppearance.Dark
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.show()
        
        refreshControl = UIRefreshControl()
        
        collectionView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        refreshControl.tintColor = UIColor(red: 127/255, green: 255/255, blue: 212/255, alpha: 1)
        
        collectionView.dataSource = self
        movieSearcher.delegate = self
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        movieSearcher.showsCancelButton = true
        filteredData = searchText.isEmpty ? movies : movies!.filter({ (movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        self.collectionView.reloadData()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        movieSearcher.showsCancelButton = false
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCollection", forIndexPath: indexPath) as! MovieCollectionViewCell
        let movie = filteredData[indexPath.row]
        let title = movie["title"] as! String
        let posterPath = movie["poster_path"] as? String
        


        if let posterPath = movie["poster_path"] as? String {
            
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            let imageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
        
        cell.posterImage.setImageWithURLRequest(imageRequest, placeholderImage:  nil, success: {(imageRequest, imageResponse, image) -> Void in
            
            if imageResponse != nil {
                print("Image was not cached, fade in image")
                cell.posterImage.alpha = 0.0
                cell.posterImage.image = image
                UIView.animateWithDuration(0.7, animations: {() -> Void in
                    cell.posterImage.alpha = 1.0
                })
            } else {
                print("Image was cached so just update the image")
                cell.posterImage.image = image
            }
            },
            failure:  {(imageRequest, imageResponse, error) -> Void in
                cell.posterImage.image = nil
                
         })
       }
        return cell
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MovieSegue" {
            if let indexPath = self.collectionView?.indexPathForCell((sender as? MovieCollectionViewCell)!) {
                let detailVC = segue.destinationViewController as! TableViewMovieDetailsViewController
                detailVC.tableFilteredDict = filteredData![indexPath.row]
                detailVC.movieID = filteredData![indexPath.row]["id"]!.integerValue
        
            }
        }
    }
    
    func getNetworkData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
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
                            self.collectionView.reloadData()
                            PKHUD.sharedHUD.hide()
                            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
                            PKHUD.sharedHUD.dimsBackground = false
                            
                    }
                } else {
                    print("error")
                    PKHUD.sharedHUD.hide()
                    PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
                    PKHUD.sharedHUD.dimsBackground = false
                    
                }
        });
        task.resume()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let filteredData = filteredData {
            return filteredData.count
        } else {
            return 0
        }
    }
}
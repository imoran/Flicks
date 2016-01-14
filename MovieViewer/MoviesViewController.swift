//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Isis Moran on 1/5/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import PKHUD
import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var refreshControl: UIRefreshControl!
    let delay = 3.0 * Double(NSEC_PER_SEC)
    var movies: [NSDictionary]?
//    let indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    var searchActive: Bool = false
    var filteredData: [String]!
    
    @IBOutlet weak var movieSearch: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         PKHUD.sharedHUD.contentView = PKHUDProgressView()
         PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
         PKHUD.sharedHUD.dimsBackground = true
         PKHUD.sharedHUD.show()
            
         let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double (NSEC_PER_SEC)))
            
         dispatch_after(delayTime, dispatch_get_main_queue()) {
             PKHUD.sharedHUD.contentView = PKHUDSuccessView()
             PKHUD.sharedHUD.hide(afterDelay: 2.0)
             }
        
//        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
//        tableView.addSubview(indicator)
//        indicator.startAnimating()
        
//        refreshControl.backgroundColor = UIColor.grayColor()
//        refreshControl.tintColor = UIColor.blackColor()
        
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)

        tableView.dataSource = self
        tableView.delegate = self
//        indicator.center = tableView.center
        
//        movieSearch.delegate = self
        
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
                            self.tableView.reloadData()
                            
                    }
                }
        });
        task.resume()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
//        self.indicator.stopAnimating()
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"]
        let posterPath = movie["poster_path"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        cell.titleLabel.text = title as String
        cell.overviewLabel.text = overview as? String
        
        if let posterPath = movie["poster_path"] as? String {
            cell.posterView.setImageWithURL(imageUrl!)
        }
        print("row\(indexPath.row)")
        return cell
    }
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
    }
}
}
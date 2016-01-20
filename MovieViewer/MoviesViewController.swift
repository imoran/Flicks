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
    
    @IBOutlet weak var movieSearch: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    
    var filteredData: [NSDictionary]!
    var refreshControl: UIRefreshControl!
    let delay = 3.0 * Double(NSEC_PER_SEC)
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//          UITabBar.appearance().barTintColor = UIColor.blackColor()
        
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
        tableView.addSubview(refreshControl)
        
        refreshControl.backgroundColor = UIColor.grayColor()
        refreshControl.tintColor = UIColor.darkGrayColor()
//        UITabBar.appearance().tintColor = UIColor(red: 49, green: 79, blue: 79, alpha: 1.0)
        
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)

        tableView.dataSource = self
        tableView.delegate = self
        movieSearch.delegate = self
        
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
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                    }
                    
                    self.filteredData = self.movies
                    self.tableView.reloadData()

                }
        });
        task.resume()
        
        if Reachability.isConnectedToNetwork() == true {
            networkErrorView.hidden = true
        } else {
            print("Internet connection FAILED")
            networkErrorView.hidden = false
        }

    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? movies : movies!.filter({ (movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
            self.tableView.reloadData()
    }
    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        
//    }
//    
//    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
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
        
        let movie = filteredData[indexPath.row]
        let title = movie["title"] as! String
//        let overview = movie["overview"]
        let posterPath = movie["poster_path"] as! String
        let popularity = movie["popularity"] as! Double
        let voterAverage = movie["vote_average"] as! Double
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        let request = NSURLRequest(URL: imageUrl!)
//        let placeholder = UIImage(named: "clapperboard")
        
        cell.titleLabel.text = title as String
//        cell.overviewLabel.text = overview as? String
        cell.popularityLabel.text = popularity as? String
        cell.voterAvgLabel.text = voterAverage as? String
        
        if let posterPath = movie["poster_path"] as? String {
            cell.posterView.setImageWithURL(imageUrl!)
        }
        
        cell.posterView.setImageWithURLRequest(request, placeholderImage: UIImage(named: "clapperboard"), success: { (request, imageResponse, image) -> Void in
            if imageResponse != nil {
                print("Image was not cached, fade in image")
                cell.posterView.alpha = 0.0
                cell.posterView.image = image
                UIView.animateWithDuration(0.3, animations: {() -> Void in
                    cell.posterView.alpha = 1.0
                })
            } else {
                print("Image was cached so just update the image")
                cell.posterView.image = image
            }
        }) { (imageRequest, imageResponse, error) -> Void in
            
        }
        return cell
    }
    
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filteredData = filteredData {
            return filteredData.count
        } else {
            return 0
        
  }
 }
}
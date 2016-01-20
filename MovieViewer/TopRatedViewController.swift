//
//  TopRatedViewController.swift
//  MovieViewer
//
//  Created by Isis Moran on 1/18/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import PKHUD
import AFNetworking

class TopRatedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var toptableView: UITableView!
    @IBOutlet weak var topMovieSearcher: UISearchBar!
    
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]!
    var refreshControl: UIRefreshControl!
    var delay = 3.0 * Double(NSEC_PER_SEC)

    override func viewDidLoad() {
//        UITabBar.appearance().barTintColor = UIColor.blackColor()
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.show()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double (NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
        }
        
        refreshControl = UIRefreshControl()
        toptableView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: "onRefresh",
        forControlEvents: UIControlEvents.ValueChanged)
        
        toptableView.dataSource = self
        toptableView.delegate = self
        topMovieSearcher.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)")
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
                            PKHUD.sharedHUD.hide()
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                    }
                    self.filteredData = self.movies
                    self.toptableView.reloadData()
                }
        });
        task.resume()
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? movies:movies!.filter({(movie:NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        self.toptableView.reloadData()
    }
    
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
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filteredData = filteredData  {
            return filteredData.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = toptableView.dequeueReusableCellWithIdentifier("TopMovieCell", forIndexPath: indexPath) as! TopMovieCell
        
        let movie =  filteredData[indexPath.row]
        let title = movie["title"] as! String
        let posterPath = movie["poster_path"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
//        let request = NSURLRequest(URL: imageUrl!)
        
        cell.topTitleLabel.text = title as String
        
        if let posterPath = movie["poster_path"] as? String {
            cell.topPosterView.setImageWithURL(imageUrl!)
        }

        return cell
    }
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    

}

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
    @IBOutlet weak var errorView: UIView!
    
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]!
    var refreshControl: UIRefreshControl!
    var delay = 3.0 * Double(NSEC_PER_SEC)

    override func viewDidLoad() {
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.show()
        
        refreshControl = UIRefreshControl()
        toptableView.addSubview(refreshControl)
        refreshControl.backgroundColor = UIColor.blackColor()
        refreshControl.tintColor = UIColor(red: 127/255, green: 255/255, blue: 212/255, alpha: 1)
        
        refreshControl.addTarget(self, action: "onRefresh",
        forControlEvents: UIControlEvents.ValueChanged)
        
        toptableView.dataSource = self
        toptableView.delegate = self
        topMovieSearcher.delegate = self
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        topMovieSearcher.showsCancelButton = true
        filteredData = searchText.isEmpty ? movies:movies!.filter({(movie:NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        self.toptableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        topMovieSearcher.showsCancelButton = false
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
        delay(1, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? TopMovieCell {
            let indexPath = self.toptableView.indexPathForCell(cell)!.row
            if segue.identifier == "topTableViewSegue" {
                let vc = segue.destinationViewController as! MovieDetailsViewController
                vc.filteredDict = filteredData![indexPath]
            }
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = toptableView.dequeueReusableCellWithIdentifier("TopMovieCell", forIndexPath: indexPath) as! TopMovieCell
        
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 127/255, green: 255/255, blue: 212/255, alpha: 1)
        cell.selectedBackgroundView = bgColorView
        
        let movie =  filteredData[indexPath.row]
        let title = movie["title"] as! String
        let posterPath = movie["poster_path"] as! String
        let popularity = movie["popularity"] as? Float
        let voterAverage = movie["vote_average"] as? Float
        
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        let request = NSURLRequest(URL: imageUrl!)
        let placeholderImage = UIImage(named: "placeholder")
        
        cell.topTitleLabel.text = title as String
        cell.topTitleLabel.adjustsFontSizeToFitWidth = true
        cell.popularityLabel.text = String(format: "%.2f%", popularity!)
        cell.voterAvgLabel.text = String(format: "%.2f", voterAverage!)

        
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
    
    func getNetworkData() {
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
                            NSLog("response: \(responseDictionary)")
                            PKHUD.sharedHUD.hide(afterDelay: 1.5)
                            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredData = self.movies
                            self.refreshControl.endRefreshing()
                            self.toptableView.reloadData()
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

    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filteredData = filteredData  {
            return filteredData.count
        } else {
            return 0
        }
        
    }
}
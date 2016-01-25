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
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var movieSearch: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    
    var filteredData: [NSDictionary]!
    var refreshControl: UIRefreshControl!
    let delay = 3.0 * Double(NSEC_PER_SEC)
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         errorView.hidden = true
        
         PKHUD.sharedHUD.contentView = PKHUDProgressView()
         PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
         PKHUD.sharedHUD.dimsBackground = true
         PKHUD.sharedHUD.show()

        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
                
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.backgroundColor = UIColor.blackColor()

        refreshControl.tintColor = UIColor(red: 127/255, green: 255/255, blue: 212/255, alpha: 1)
        
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
                            NSLog("response: \(responseDictionary)")
                            PKHUD.sharedHUD.hide(afterDelay: 1.5)
                            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredData = self.movies
                            self.refreshControl.endRefreshing()
                            self.tableView.reloadData()
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
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        movieSearch.showsCancelButton = true
        filteredData = searchText.isEmpty ? movies : movies!.filter({ (movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
            self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        movieSearch.showsCancelButton = false
        
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
        if let cell = sender as? MovieCell {
            let indexPath = self.tableView.indexPathForCell(cell)!.row
            if segue.identifier == "tableViewSegue" {
                let vc = segue.destinationViewController as! TableViewMovieDetailsViewController
                vc.tableFilteredDict = filteredData![indexPath]
            }
        }
   
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 127/255, green: 255/255, blue: 212/255, alpha: 1)
        cell.selectedBackgroundView = bgColorView
        
        let movie = filteredData[indexPath.row]
        let title = movie["title"] as! String
        let posterPath = movie["poster_path"] as! String
        let popularity = movie["popularity"] as? Float
        let voterAverage = movie["vote_average"] as? Float
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        let request = NSURLRequest(URL: imageUrl!)
        let placeholderImage = UIImage(named: "placeholder")
    
        
        cell.titleLabel.text = title as String
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.popularityLabel.text = String(format: "%.2f", popularity!)
        cell.voterAvgLabel.text = String(format: "%.2f", voterAverage!)
    
        let imageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
        
        cell.posterView.setImageWithURLRequest(imageRequest, placeholderImage:  nil, success: {(imageRequest, imageResponse, image) -> Void in
            
            if imageResponse != nil {
                print("Image was not cached, fade in image")
                cell.posterView.alpha = 0.0
                cell.posterView.image = image
                UIView.animateWithDuration(0.7, animations: {() -> Void in
                    cell.posterView.alpha = 1.0
                })
            } else {
                print("Image was cached so just update the image")
                cell.posterView.image = image
            }
            },
            failure:  {(imageRequest, imageResponse, error) -> Void in
                cell.posterView.image = placeholderImage
                
        })
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filteredData = filteredData {
            return filteredData.count
        } else {
            return 0
        
  }
 }
}
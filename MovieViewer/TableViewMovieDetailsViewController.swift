//
//  TableViewMovieDetailsViewController.swift
//  MovieViewer
//
//  Created by Isis Moran on 1/20/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class TableViewMovieDetailsViewController: UIViewController , UICollectionViewDelegate {
    
    @IBOutlet weak var largeImage: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var theOverviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var timeIcon: UIImageView!
    
    var tableFilteredDict: NSDictionary!
    var movieID = 0;
    var movie: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        func populateData() {
            var genres = [""]
            genres.removeAll()
            if movie == movie {
                
            if let movieRuntime = movie!["runtime"]!.integerValue {
                runtimeLabel.text = "\(movieRuntime)" + " minutes"
            } else {
                timeIcon.hidden = true
                runtimeLabel.text = "No runtime info avail."
            }
             
            if let tagline = movie!["tagline"] as? String {
                taglineLabel.text = tagline
                taglineLabel.adjustsFontSizeToFitWidth = true
            } else {
                taglineLabel.text = "No tagline info avail."
            }
            
            for genre in (movie!["genres"] as? [NSDictionary])! {
                genres.append(genre["name"] as! String)
            }
                genreLabel.text = genres.joinWithSeparator(", ")
            }
        }
    
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/\(movieID)?api_key=\(apiKey)")
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
                            self.movie = responseDictionary
                            populateData()

                    }
                } else {
                    print("error")

                    
                }
        });
        task.resume()
        
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let backImg: UIImage = UIImage(named: "table")!
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImg, forState: .Normal, barMetrics: .Default)
        
        let title = tableFilteredDict["title"] as! String
        let overview = tableFilteredDict["overview"] as! String
        let date = tableFilteredDict["release_date"] as! String
        let dateMod = date.componentsSeparatedByString("-")
        let year: String = dateMod[0]
        
        theTitleLabel.text = String(title + " (" + year + ")")
        theOverviewLabel.text = "Synopsis: \n" + overview as String
        theTitleLabel.sizeToFit()
        theOverviewLabel.sizeToFit()
        
        if let posterPath = tableFilteredDict["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            let low_resolution = "https://image.tmdb.org/t/p/w45"
            let high_resolution = "https://image.tmdb.org/t/p/original"
            let smallImageRequest = NSURLRequest(URL: NSURL(string:low_resolution + posterPath)!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: high_resolution + posterPath)!)
 
            self.largeImage.setImageWithURLRequest(
             smallImageRequest,
             placeholderImage: nil,
             success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                self.largeImage.alpha = 0.0
                self.largeImage.image = smallImage;
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    
                    self.largeImage.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        self.largeImage.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.largeImage.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                self.largeImage.image = UIImage(named: "placeholder")
                          
                        })
                })
            },
            failure: { (request, response, error) -> Void in
               
        })
        
     }
   }

}
    





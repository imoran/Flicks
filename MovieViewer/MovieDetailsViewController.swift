//
//  MovieDetailsViewController.swift
//  MovieViewer
//
//  Created by Isis Moran 1/17/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var topLargeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var informationView: UIView!
    
    var filteredDict: NSDictionary!
    var screen = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backImg: UIImage = UIImage(named: "collection")!
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImg, forState: .Normal, barMetrics: .Default)
        
        
        let posterPath = filteredDict["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        let title = filteredDict["title"] as! String
        let overview = filteredDict["overview"] as! String
        
       
        titleLabel.text = title as String
        overviewLabel.text = overview as String
        
        overviewLabel.adjustsFontSizeToFitWidth = true
        
        if let posterPath = filteredDict["poster_path"] as? String {
            topLargeImage.setImageWithURL(imageUrl!)
        }
        
        print(filteredDict)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTap(sender: AnyObject) {
        
        if screen {
            UIView.animateWithDuration(1.5, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations:  {
                self.informationView.transform = CGAffineTransformMakeTranslation(0, 170)
                }, completion: nil)
            screen = false
        } else {
            UIView.animateWithDuration(1.5, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations:  {
                self.informationView.transform = CGAffineTransformMakeTranslation(0, 0)
                }, completion: nil)
            screen = true
            
        }
    }
        
    }


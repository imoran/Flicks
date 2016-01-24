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
    
    var tableFilteredDict: NSDictionary!
//    var tableViewFilteredDict: NSDictionary!
    
    var screen = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = tableFilteredDict["title"] as! String
        let overview = tableFilteredDict["overview"] as! String
        let posterPath = tableFilteredDict["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
//        self.theOverviewLabel.sizeToFit()

        theTitleLabel.text = title as String
        theOverviewLabel.text = overview as String
        
        if let posterPath = tableFilteredDict["poster_path"] as? String {
            largeImage.setImageWithURL(imageUrl!)
        }
        
        print(tableFilteredDict)

    }

    @IBAction func onTap(sender: AnyObject) {
     
        if screen {
        UIView.animateWithDuration(1.5, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations:  {
            self.infoView.transform = CGAffineTransformMakeTranslation(0, 120)
        }, completion: nil)
            screen = false
       } else {
       UIView.animateWithDuration(1.5, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations:  {
       self.infoView.transform = CGAffineTransformMakeTranslation(0, 0)
    }, completion: nil)
            screen = true
            
     }
   }
}

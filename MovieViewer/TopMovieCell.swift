//
//  TopMovieCell.swift
//  MovieViewer
//
//  Created by Isis Moran on 1/19/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class TopMovieCell: UITableViewCell {
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var topPosterView: UIImageView!
    
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var voterAvgLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
//    
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(<#T##selected: Bool##Bool#>, animated: <#T##Bool#>)
//    }

}

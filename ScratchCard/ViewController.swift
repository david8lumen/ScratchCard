//
//  ViewController.swift
//  ScratchCard
//
//  Created by David Grigoryan
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var scratchCard: ScratchCardImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scratchCard.innerView = amountLabel
        scratchCard.image = UIImage(named: "card")?.imageResize(sizeChange: scratchCard.bounds.size)
        scratchCard.lineType = .round
        scratchCard.contentMode = .scaleAspectFit
        scratchCard.lineWidth = 15
        scratchCard.delegate = self
    }
}

extension ViewController: ScratchCardImageViewDelegate {
    
    func scratchCardImageViewContentPresentedCompletly(_ scratchCardImageView: ScratchCardImageView) {
        print("DONE")
    }
}



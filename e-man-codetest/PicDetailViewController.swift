//
//  PicDetailViewController.swift
//  e-man-codetest
//
//  Created by Nigel Stuckey on 25/07/2016.
//  Copyright © 2016 Alex Stuckey. All rights reserved.
//

import UIKit

class PicDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView?
    var photo: UIImage? {
        didSet {
            imageView?.image = photo
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView?.image = photo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func dismiss(sender: AnyObject!) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

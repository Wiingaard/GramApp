//
//  SignAndSendViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 11/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class SignAndSendViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func signAction(_ sender: Any) {
        performSegue(withIdentifier: "Show Signatures", sender: nil)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
    }
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var user: User!
    var sendAllowed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        user = realm.objects(User.self).first
        
        sendAllowed = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if sendAllowed {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
        updateFiles()
    }
    
    func updateFiles() {
        let generator = FileGenerator(report: report, user: user)
        let files = generator.generateFiles()
        if let image = files["sheetImage"] as? UIImage {
            print("Yay!")
            imageView.image = image
            
            let minimumZoomscale = view.frame.width / image.size.width
            scrollView.minimumZoomScale = minimumZoomscale
            scrollView.zoomScale = minimumZoomscale
        } else {
            print("Ahh :/")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Signatures" {
            let vc = segue.destination as! SignatureListViewController
            vc.reportID = self.reportID
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}

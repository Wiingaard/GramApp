//
//  AppDelegate.swift
//  GramApp
//
//  Created by Martin Wiingaard on 20/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let realm = try! Realm()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print("Realm path: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        let user = realm.objects(User.self)
        if user.first == nil {
            initiateOnboarding()
        }
        
        return true
    }
    
    
    func initiateOnboarding() {
        
        // Write the User object in the realm
        print("Onboarding - Get inspector! number here.!")
        
        let newUser = User()
        
        try! realm.write {
            realm.add(newUser)
        }
        
    }
}


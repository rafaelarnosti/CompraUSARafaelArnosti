//
//  UIViewController+CoreData.swift
//  CompraUSA
//
//  Created by rafael on 13/10/17.
//  Copyright © 2017 rafael. All rights reserved.
//
import CoreData
import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
}


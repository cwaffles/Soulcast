//
//  PushHandler.swift
//  Soulcast
//
//  Created by June Kim on 2016-11-19.
//  Copyright © 2016 Soulcast-team. All rights reserved.
//

import Foundation

//singleton for now...
let pushHandler = PushHandler()

class PushHandler {
  var bufferHash: [String:AnyObject]?
  
  func handle(_ soulHash: [String:AnyObject]) {
    guard let appDelegate = app.delegate as? AppDelegate else {
      bufferHash = soulHash
      return
    }
    guard app.applicationState == .active else {
      bufferHash = soulHash
      return
    }
    let coordinator = appDelegate.mainCoordinator
    // at mainVC screen
    let mainVC = coordinator.mainVC
    let historyVC = coordinator.historyVC
    if mainVC.view.window != nil && historyVC.view.window == nil{
      mainVC.receiveRemoteNotification(soulHash)
      return
    }
    // at historyVC screen
    if historyVC.view.window != nil && mainVC.view.window == nil {
      coordinator.scrollToMainVC() {
        mainVC.receiveRemoteNotification(soulHash)
      }
    }
      
      //DEBUG
    //        let soulObject = Soul.fromHash(soulHash)
    //        let alert = UIAlertController(title: "options", message: String(soulObject), preferredStyle: .Alert)
    //        self.window!.rootViewController!.presentViewController(alert, animated: true, completion: {
    //          //
    //        })

  }
  
  func activate() {
    if let hash = bufferHash {
      bufferHash = nil
      handle(hash)
    }
    //TODO: check soloQueue?
    /*
     if !soloQueue.isEmpty {
     delegate?.presentIncomingVC()
     }
     */
  }
  
}

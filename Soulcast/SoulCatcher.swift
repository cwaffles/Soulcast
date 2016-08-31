//
//  SoulCatcher.swift
//  SoulCast
//
//  Created by Camvy Films on 2015-03-13.
//  Copyright (c) 2015 June. All rights reserved.
//
import Foundation
import UIKit
import AWSS3

protocol SoulCatcherDelegate {
  func soulDidStartToDownload(soul:Soul)
  func soulIsDownloading(progress:Float)
  func soulDidFinishDownloading(soul:Soul)
  func soulDidFailToDownload()
}

//downloads a soul and puts it in a queue
class SoulCatcher: NSObject {
  
  var catchingSoul: Soul?
  var delegate: SoulCatcherDelegate?
  var progress: Float = 0
  
  var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?

  func setup() {

  }
  
  func catchSoul(userInfo:[NSObject : AnyObject]) {
    if let soulInfo = userInfo["soulObject"] as? [NSObject : AnyObject] {
      if soulInfo["type"] as? String == "broadcast" {
        print("Catching a broadcasted aps soul!")
        catchSoulObject(soulFromHash(soulInfo))
        
      } else if soulInfo["type"] as? String == "direct" {
        print("Catching a directed aps soul!")
        
      } else {
        assert(false, "Trying to catch a non-incoming soul!")
      }
    
    }
  }
  
  func catchSoulObject(incomingSoul:Soul) {
    startDownloading(incomingSoul)
  }
  
  private func startDownloading(incomingSoul:Soul) {
    let s3Key = incomingSoul.s3Key! as String + ".mp3"
    
    let expression = AWSS3TransferUtilityDownloadExpression()
    expression.progressBlock = {(task, progress) in
      dispatch_async(dispatch_get_main_queue(), {
        self.progress = Float(progress.fractionCompleted)
        self.delegate?.soulIsDownloading(self.progress)
      })
    }
    
    self.completionHandler = { (task, location, data, error) -> Void in
      dispatch_async(dispatch_get_main_queue(), {
        if ((error) != nil){
          print("FAIL! error:\(error!)")
          dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.soulDidFailToDownload()
          }
        } else if(self.progress != 1.0) {
          dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.soulDidFailToDownload()
          }
        } else{
          print("startDownloading incomingSoul success!!")
          //TODO: save data to local temp file...
          let filePath = self.saveToCache(data!, key:incomingSoul.s3Key!)
          incomingSoul.localURL = filePath
          dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.soulDidFinishDownloading(incomingSoul)
            
          }
          singleSoulQueue.enqueue(incomingSoul)
          
        }
      })
    }
    
    let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()

    transferUtility.downloadDataFromBucket(
      S3BucketName,
      key: s3Key,
      expression: expression,
      completionHander: completionHandler)
    //optional: .continuewithblock...
    
  }
  
  private func soulFromHash (soulHash:NSDictionary) -> Soul {
    let incomingSoul = Soul()
    let incomingDevice = Device()
    incomingDevice.id = soulHash["device_id"] as? Int
//    incomingSoul.device = incomingDevice
    incomingSoul.epoch = soulHash["epoch"] as? Int
    incomingSoul.latitude = (soulHash["latitude"] as? NSString)?.doubleValue
    incomingSoul.longitude = (soulHash["longitude"] as? NSString)?.doubleValue
    incomingSoul.radius = (soulHash["radius"] as? NSString)?.doubleValue
    incomingSoul.s3Key = soulHash["s3Key"] as? String
    incomingSoul.type = SoulType(rawValue: soulHash["type"] as! String)
    return incomingSoul
  }
  
  
  func saveToCache(data: NSData, key:String) -> String {
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    let tempPath = paths.first
    let filePath = tempPath! + "/" + key + ".m4a"
    do {
      if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
        try NSFileManager.defaultManager().removeItemAtPath(filePath)
      }
      data.writeToFile(filePath, atomically: true)
      
    } catch {
      print("movedFileToDocuments error!")
    }
    return filePath
  }
}


  

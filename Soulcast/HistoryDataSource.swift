//
//  HistoryDataSource.swift
//  Soulcast
//
//  Created by June Kim on 2016-11-19.
//  Copyright © 2016 Soulcast-team. All rights reserved.
//

import Foundation
import UIKit

protocol HistoryDataSourceDelegate: class {
  func willFetch()
  func didFetch(success:Bool)
  func didUpdate(soulCount:Int)
  func didFinishUpdating(soulCount:Int)
  func didConfirmBlock(soul: Soul)
}

class HistoryDataSource: NSObject, SoulCatcherDelegate {
  private var souls = [Soul]() 
  private var soulCatchers = Set<SoulCatcher>()
  weak var delegate: HistoryDataSourceDelegate?
  var updateTimer: NSTimer = NSTimer()
  
  func fetch() {
    delegate?.willFetch()
    MockServerFacade.getHistory({ souls in
      self.catchSouls(souls)
      self.delegate?.didFetch(true)
      }, failure:  { failureCode in
        self.delegate?.didFetch(false)
    })
  }
  func startTimer() {
    updateTimer.invalidate()
    updateTimer = NSTimer.scheduledTimerWithTimeInterval(
      0.25,
      target: self,
      selector: #selector(timerExpired),
      userInfo: nil,
      repeats: false)
  }
  func timerExpired() {
    updateTimer.invalidate()
    delegate?.didFinishUpdating(souls.count)
    print("HistoryDataSource timerExpired!!")
  }
  func soul(forIndex index:Int) -> Soul? {
    guard index < souls.count else {
      return nil
    }
    return souls[index]
  }
  func indexPath(forSoul soul:Soul) -> NSIndexPath {
    if let index = souls.indexOf(soul) {
      return NSIndexPath(forRow: index, inSection: 0)
    }
    return NSIndexPath()
  }
  func catchSouls(souls:[Soul]) {
    for eachSoul in souls {
      let catcher = SoulCatcher(soul: eachSoul)
      catcher.delegate = self
      soulCatchers.insert(catcher)
      
    }
  }
  func remove(soul:Soul) {
    if let index = souls.indexOf(soul) {
      souls.removeAtIndex(index)
      delegate?.didUpdate(souls.count)
    }
  }
  func insertByEpoch(soul: Soul) {
    let insertionIndex = souls.indexOf({$0.epoch < soul.epoch}) ?? 0
    souls.insert(soul, atIndex: insertionIndex)
    delegate?.didUpdate(souls.count)
  }
  
  //SoulCatcherDelegate
  
  func soulDidStartToDownload(catcher: SoulCatcher, soul: Soul) {
    //
  }
  func soulIsDownloading(catcher: SoulCatcher, progress: Float) {
    //
  }
  func soulDidFinishDownloading(catcher: SoulCatcher, soul: Soul) {
    insertByEpoch(soul)
    soulCatchers.remove(catcher)
    startTimer()
  }
  func soulDidFailToDownload(catcher: SoulCatcher) {
    //
    soulCatchers.remove(catcher)
  }
}

extension HistoryDataSource: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return souls.count
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "History"
  }
  
  func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return ""
  }
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    switch editingStyle {
    case .Delete:
      if let blockingSoul = soul(forIndex: indexPath.row) {
        delegate?.didConfirmBlock(blockingSoul)
      }
    case .Insert:      break
    case .None:      break
    }
  }
  
  func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: String(UITableViewCell))
    if let thisSoul = soul(forIndex: indexPath.row),
      let epoch = thisSoul.epoch,
      let radius = thisSoul.radius {
      cell.textLabel?.text = timeAgo(epoch: epoch)
      cell.detailTextLabel?.text = String(round(radius*10)/10) + "km away"
      cell.detailTextLabel?.textColor = UIColor.grayColor()
      cell.accessoryType = .DisclosureIndicator
    }
    return cell
  }
}
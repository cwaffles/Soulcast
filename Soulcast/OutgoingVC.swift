

import UIKit

protocol OutgoingVCDelegate {
  func outgoingRadius() -> Double
  func outgoingLongitude() -> Double
  func outgoingLatitude() -> Double
  func outgoingDidStart()
  func outgoingDidStop()
}

class OutgoingVC: UIViewController {
  
  var buttonSize:CGFloat = screenWidth * 1/3
  var outgoingButton: RecordButton!
    //  var outgoingButton: SimpleOutgoingButton!
  var outgoingSoul:Soul?
  var recordingStartTime:NSDate!
  var soulRecorder = SoulRecorder()
  var soulCaster = SoulCaster()
  var displayLink: CADisplayLink!
  var soulPlayer = SoulPlayer()

  var delegate: OutgoingVCDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addDisplayLink()
    addOutgoingButton()
    configureAudio()
    configureNetworking()
  }
  
  override func viewDidAppear(animated: Bool) {
    //requestStartRecording()
  }

  func configureAudio() {
    soulRecorder.delegate = self
    soulRecorder.setup()
    do {
      try audioController.start()
    } catch {
      print("audioController.start() fail!")
    }
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OutgoingVC.soulDidFailToPlay(_:)), name: "soulDidFailToPlay", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OutgoingVC.soulDidFinishPlaying(_:)), name: "soulDidFinishPlaying", object: nil)
  }
  
  func configureNetworking() {
    soulCaster.delegate = self
  }
  
  func addOutgoingButton() {
    view.frame = CGRectMake((screenWidth - buttonSize)/2, screenHeight - buttonSize, buttonSize, buttonSize)
    outgoingButton = RecordButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
    outgoingButton.backgroundColor = UIColor.redColor()
    //TODO: simplest implementation first.
    //TODO: make pixel perfect.
    outgoingButton.addTarget(self, action: #selector(OutgoingVC.outgoingButtonTouchedDown(_:)), forControlEvents: UIControlEvents.TouchDown)
    outgoingButton.addTarget(self, action: #selector(OutgoingVC.outgoingButtonTouchedUpInside(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    outgoingButton.addTarget(self, action: #selector(OutgoingVC.outgoingButtonTouchDraggedExit(_:)), forControlEvents: UIControlEvents.TouchDragExit)
    
    view.addSubview(outgoingButton)
  }
  
  func outgoingButtonTouchedDown(button:UIButton) {
    print("outgoingButtonTouchedDown")

//    outgoingButton.buttonState = .Recording
    if !SoulPlayer.playing {
      requestStartRecording()
    }
  }
  
  func outgoingButtonTouchedUpInside(button:UIButton) {
    print("outgoingButtonTouchedUpInside")
    //    outgoingButton.buttonState = .Enabled
        requestFinishRecording()
  }
  
  func outgoingButtonTouchDraggedExit(button:UIButton) {
    print("outgoingButtonTouchDraggedExit")
//    outgoingButton.buttonState = .Enabled
    requestFinishRecording()
  }
  
  func addDisplayLink() {
    displayLink = CADisplayLink(target: self, selector: #selector(OutgoingVC.displayLinkFired(_:)))
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
  }
  
  func displayLinkFired(link:CADisplayLink) {
    if soulRecorder.state == .RecordingStarted || soulRecorder.state == .RecordingLongEnough {
      incrementRecordingIndicator()
    }
    
  }
  func incrementRecordingIndicator() {
    //TODO: query soulRecorder to update UI.
//    let progress = Float(soulRecorder.displayCounter) / Float(soulRecorder.maximumRecordDuration) / 60
    
  }
  
  func resetRecordingIndicator() {
    //animate alpha = 0 ease out, upom completion, stroke = 0
    //TODO:
  }
  
  func requestStartRecording() {
    recordingStartTime = NSDate()
    soulRecorder.pleaseStartRecording()
    
  }
  
  func requestFinishRecording() {
    soulRecorder.pleaseStopRecording()
    //replay, save, change ui to disabled.
    
  }
  
  func playbackSoul(localSoul:Soul) {
    print("playbackSoul localSoul:\(localSoul)")
    soulPlayer.startPlaying(localSoul)
  }
  
  func disableButtonUI() {
    
  }
  
  func turnButtonTintDud() {
    
  }
  
  func turnButtonTintRecordingLongEnough() {
    
  }
  
  func turnButtonTintFinished() {
    
  }
  
  func animateNegativeShake() {
    //left to right a couple times, disable button in the meanwhile.
  }
  
}

extension OutgoingVC: SoulRecorderDelegate {
  func soulDidStartRecording() {
    turnButtonTintDud()
  }
  
  func soulDidFailToRecord() {
    //negative animation, go back to being enabled
    animateNegativeShake()
  }
  
  func soulDidReachMinimumDuration() {
    turnButtonTintRecordingLongEnough()
  }
  
  func soulDidFinishRecording(newSoul: Soul) {
    resetRecordingIndicator()
    playbackSoul(newSoul)
    newSoul.epoch = Int(NSDate().timeIntervalSince1970)
    newSoul.radius = delegate?.outgoingRadius()
    newSoul.s3Key = String(newSoul.epoch!)
    newSoul.longitude = delegate?.outgoingLongitude()
    newSoul.latitude = delegate?.outgoingLatitude()
    newSoul.token = Device.localDevice.token
    newSoul.type = .Broadcast
    soulCaster.cast(newSoul)
    //TODO: optimize later by concurrently uploading data and metadata concurrently
//    soulCaster.castSoulToServer(newSoul)

  }
}

extension OutgoingVC {
  func soulDidFailToPlay(notification:NSNotification) {
    let failSoul = notification.object as! Soul
    print("soulDidFailToPlay failSoul: \(failSoul)")
  }
  
  func soulDidFinishPlaying(notification:NSNotification) {
//    let finishedSoul = notification.object as! Soul
    print("soulDidFinishPlaying")
  }
}

extension OutgoingVC: SoulCasterDelegate {
  func soulDidStartUploading() {
    printline("soulDidStartUploading")
  }
  func soulIsUploading(progress:Float) {
    printline("soulIsUploading progress: \(progress)")
  }
  func soulDidFinishUploading(soul:Soul) {
    printline("soulDidFinishUploading")
  }
  func soulDidFailToUpload() {
    printline("soulDidFailToUpload")
  }
  func soulDidReachServer() {
    printline("soulDidReachServer")
  }
}

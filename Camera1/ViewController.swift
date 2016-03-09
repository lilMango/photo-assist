//
//  ViewController.swift
//  Camera1
//
//  Created by Miguel Paysan on 12/28/15.
//  Copyright © 2015 Miguel Paysan. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import CoreLocation

class ViewController: UIViewController,UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    CLLocationManagerDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate{

    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var processedVideoOutput: AVCaptureVideoDataOutput?
    var customPreviewLayer: CALayer?
    var queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL)
    
    var overlayImg:UIImage?=UIImage(named:"halfdome.jpg")
    var overlayImageView:UIImageView?
    
    var motionManager:CMMotionManager?
    var locationManager:CLLocationManager?
    
    //Attributes of current overlay
    var startLocation:CLLocation?
    var startOrientation:CMAcceleration?
    
    var possibleAVPresets = [AVCaptureSessionPresetPhoto, AVCaptureSessionPresetHigh, AVCaptureSessionPresetMedium, AVCaptureSessionPresetLow]

    var presetCursor=0
    
    //Frame Rate
    var frames = 0;
    var starttime = 0.0;
    var first = true;
    var fps = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialize overlay with some stock 
        let bounds = UIScreen.mainScreen().bounds
        overlayImageView=UIImageView(image: overlayImg)
        overlayImageView!.contentMode = .ScaleAspectFit
        overlayView.addSubview(overlayImageView!)
        
        libraryButton.imageView!.contentMode=UIViewContentMode.ScaleAspectFit
        
        motionManager=CMMotionManager()
        motionManager!.accelerometerUpdateInterval=0.1 //half-second
        
        locationManager=CLLocationManager()
        locationManager!.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        overlayImageView!.alpha=0.33//same as initial slider value
        showOverlay(true)
        
        switchUpdated()
        
    }
    
    
    /****
    * Helpers to stop and start accelerometer and location sensors
    */
    func startSensors() {
        print("Sensors:ON")
        motionManager!.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: {(accelerometerData: CMAccelerometerData?, error: NSError?)in
            self.outputOrientationData(accelerometerData!.acceleration)
            if (error != nil)
            {
                print("\(error)")
            }
        })
        locationManager!.startUpdatingLocation()

    }
    
    func stopSensors() {
        print("Sensors:OFF")
        motionManager?.stopAccelerometerUpdates()
        locationManager?.stopUpdatingLocation()
    }
    
    func outputOrientationData(rotationRate:CMAcceleration){
        let coords=self.locationManager!.location
        
        var resultText:String=""
        
        resultText+=String(format:"Current:\n%.5f\t%.5f\t%.5f\n",rotationRate.x,rotationRate.y,rotationRate.z)
        //resultText+=String("-location:")
        //resultText+=String(format:"(%.5f,%.5f)\nalt=%.5f",(coords?.coordinate.latitude)!, (coords?.coordinate.longitude)!, (coords?.altitude)!)
        
        if let i_rot=startOrientation,s_loc=startLocation {
            resultText+=String(format:"Previous:%.5f\t%.5f\t%.5f\n",i_rot.x,i_rot.y,i_rot.z)
            //resultText+=String(format:"+location:(%.5f,%.5f) \nalt:%.5f\n",s_loc.coordinate.latitude,s_loc.coordinate.longitude,s_loc.altitude)
            let orientation_f=Vector3(a: i_rot.x, b: i_rot.y, c: i_rot.z)
            let orientation_cur=Vector3(a: rotationRate.x, b: rotationRate.y, c: rotationRate.z)
            resultText+=PlacementNavigator.getNavigationInstruction(orientation_cur, cur: orientation_f)
        }
        textOverlay.text=resultText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    * Setting up device stuff like camera, accelerometer, location every time this app comes into view.
    * Also acts like a setup
    */
    override func viewWillAppear(animated: Bool) {
        self.view.sendSubviewToBack(overlayView)
        self.view.sendSubviewToBack(textOverlay)
        self.view.sendSubviewToBack(previewView)
        
        let kpImage:UIImage = CVWrapper.toKeypointsImage(OverlayData.image) as UIImage
        overlayImageView!.image = kpImage //use the singleton set by overlay settings screen
        
        locationManager!.startUpdatingLocation()
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = possibleAVPresets[presetCursor]
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input = try! AVCaptureDeviceInput(device: backCamera)
        
        if (captureSession!.canAddInput(input)) {
            captureSession!.addInput(input)
            print("Added Input to session")
        }else {
            print("could NOTT add Input to session")
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]

        //init the preview feed
        if captureSession!.canAddOutput(stillImageOutput) && false {
            captureSession!.addOutput(stillImageOutput)
            
        
            let bounds = UIScreen.mainScreen().bounds
            let previewViewBounds = previewView.bounds

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

            previewLayer?.bounds=previewView.bounds
            previewLayer?.frame=previewView.frame
            
            previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
            
            //Frames are w.r.t. their immediate parent frames (not absolute) ie.
            previewLayer!.frame = CGRect(x:0,y:0,
                width:UIScreen.mainScreen().bounds.width,
                height:UIScreen.mainScreen().bounds.width)
            
            previewView.layer.addSublayer(previewLayer!)
            

            
            captureSession!.startRunning()
        } else {
            print("[FAILURE] stillImageOutput[AVCaptureStillImageOutput] not added to capture Session")
        }

        
        processedVideoOutput = AVCaptureVideoDataOutput()
        processedVideoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey: NSNumber(unsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        processedVideoOutput!.alwaysDiscardsLateVideoFrames = true;
        
        if (captureSession!.canAddOutput(processedVideoOutput) && true) {
            captureSession!.addOutput(processedVideoOutput)
            print("Added processedVideoOutput[AVCaptureVideoDataOutput] to captureSession")
            
            let bounds = UIScreen.mainScreen().bounds
            let previewViewBounds = previewView.bounds
            
            customPreviewLayer = CALayer.init()

            customPreviewLayer?.frame = CGRect(x:0,y:0,
                width:UIScreen.mainScreen().bounds.width,
                height:UIScreen.mainScreen().bounds.width)
            customPreviewLayer!.contentsGravity = kCAGravityResizeAspectFill

            //customPreviewLayer!.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI/2.0)))
            print("customPreviewLayer.frame: ",customPreviewLayer!.frame)
            previewView.layer.addSublayer(customPreviewLayer!)
        
            
            captureSession!.startRunning()
            queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL)
            processedVideoOutput!.setSampleBufferDelegate(self,queue: queue)

        } else {
            print("[FAILURE] processedVideoOutput[AVCaptureVideoDataOutput] not added to capture Session")
        }
    
        //********** accelerometer inits *********

        //motionManager!.startaccelerometerUpdates()
        if motionManager?.accelerometerActive != nil && motionManager?.accelerometerActive==true  {
            print("accelerometer active")
        } else {
            print("accelerometer NOT active")
        }
        
        if motionManager?.accelerometerActive != nil && motionManager?.accelerometerAvailable==true {
            print("accelerometer available")
        } else {
            print("accelerometer NOT available")
        }
        print("accelerometerData[start]: ",motionManager?.accelerometerData)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

        overlayImageView!.frame=CGRect(x:0,y:0,
            width:UIScreen.mainScreen().bounds.width,
            height:UIScreen.mainScreen().bounds.width)
        
        print("overlayImageView frame: ", overlayImageView!.frame)
        

    }
    
    /********
     * Clean up of on device hardware
     ********/
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession?.stopRunning()
        
        print("accelerometerData[end]: ",motionManager?.accelerometerData)
        stopSensors()
    }
    
    
    /***********************************************
    * Outlets
    *
    ************************************************/
    @IBOutlet weak var textOverlay: UITextView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var overlayButton: UIButton!
    @IBOutlet weak var previewView: UIView!

    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var overlayOpacitySlider: UISlider!

    @IBOutlet weak var switchSavePhoto: UISwitch!
    @IBOutlet weak var switchSavePhotoLabel: UILabel!
    
    @IBOutlet weak var AVPresetSlider: UISlider!
    
    /* *************************************************************
     * Capturing Photo sequence (get buffer, saving it)
     * *************************************************************
     */
    @IBAction func didPressTakePhoto(sender: UIButton) {

        //////////////////////////// Using customPreviewLayer /////////////////////
            //Note we had to change the orientation of image here! TODO figure out why!
        var image = UIImage(CGImage: self.customPreviewLayer?.contents as! CGImage, scale: 1.0, orientation: UIImageOrientation.Up)
        print("imageSize:",image.size)

        if(self.switchSavePhoto.on) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }

        //////////////////////////// END: Using customPreviewLayer /////////////////////

        
        
        //THe closest thing to manipulating Z-index of views
        //self.view.bringSubviewToFront(textOverlay)
    }

    /***************************************
    * Action for when user toggles Overlay/Photo Assist button
    * This controls whether to turn on timers for continuous feed of accelerometer and location
    * ***************************************
    */
    @IBAction func toggleShowOverlay(sender: UIButton) {
        if let isOverlayText = overlayButton.titleLabel?.text {
            if isOverlayText=="Overlay" {
                showOverlay(true)
            }else {
                showOverlay(false)
            }
        }
    }
    
    func showOverlay(doOverlay:Bool) {
        if doOverlay {
            //Show overlay
            self.view.sendSubviewToBack(previewView)
            
            overlayButton.setTitle("No Overlay", forState: UIControlState.Normal)
            overlayOpacitySlider.hidden=false
            
            startSensors()
        } else {
            //No overlay showing
            self.view.bringSubviewToFront(previewView)
            
            overlayButton.setTitle("Overlay", forState: UIControlState.Normal)
            overlayOpacitySlider.hidden=true
            
            stopSensors()

        }
    }
    
    /**
    * This changes the opacity of the overlay, so you can see the preview feed or more of the overlay image and helper text.
    */
    @IBAction func changeOverlayOpacity(sender: UISlider) {
        textOverlay.alpha = CGFloat(sender.value)
        overlayImageView!.alpha = CGFloat(sender.value)
    }

    /**
    * This slider will adjust the sampling rate of the video resolution based on the eligible AVCaptureSessionPresets
    *
    */
    @IBAction func changeAVPreset(sender: UISlider) {

        //flip from High to low res
        if( CGFloat(sender.value) > 0.50 && presetCursor != 3){
            print("change Preset to Low Res")
            presetCursor=3
            captureSession!.sessionPreset = possibleAVPresets[presetCursor]
        }else if (CGFloat(sender.value) <= 0.50 && presetCursor != 0) { //
            print("change Preset to High Res")
            presetCursor=0;
            captureSession!.sessionPreset = possibleAVPresets[presetCursor]
        }

    }
    /*********************************************
     * Toggle for saving photo
     **********************************************
     */
    @IBAction func switchChanged(sender: UISwitch) {
        switchUpdated()
    }
    
    func switchUpdated() {
        if (switchSavePhoto.on) {
            switchSavePhotoLabel.text="Save Photo:[ON]"
        } else {
            switchSavePhotoLabel.text="Save Photo:[OFF]"
        }
    }
    
    /*********************************************
    * Leads user to Photo Library/camera roll
    **********************************************
    */
    @IBAction func viewPhotoLibrary(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }

    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //self.libraryButton.setImage(pickedImage, forState: UIControlState.Normal) // TODO? setting the button to be latest photo?

            overlayImageView!.image=pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)

        showOverlay(false)
    }

    // CLLocationManagerDelegate methods
    func locationManager(manager: CLLocationManager!,
        didUpdateLocations locations: [CLLocation]!)
        {
        var latestLocation: CLLocation = locations[locations.count - 1]
    
/*
            self.textOverlay.text = String(format: "Latitude: %.4f\n Longitude: %.4f\n horiz acc: %.4f\n altitude: %.4f\n vertical acc: %.4f\n",
        latestLocation.coordinate.latitude,
        latestLocation.coordinate.longitude,
        latestLocation.horizontalAccuracy,
        latestLocation.altitude,
        latestLocation.verticalAccuracy)
    
    
*/
          
        //latestLocation.distanceFromLocation(startLocation)
    

    }
    
    /*
     * Get current times for FPS
     */
    func currentTimeMillis() -> Double{
        let nowDouble = NSDate().timeIntervalSince1970
        return Double(nowDouble*1000)
    }
    
    // AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {

        var imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer) //CVImageBufferRef
        CVPixelBufferLockBaseAddress(imageBuffer!, 0);
        
        var width = CVPixelBufferGetWidthOfPlane(imageBuffer!, 0);
        var height = CVPixelBufferGetHeightOfPlane(imageBuffer!, 0);
        var bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer!, 0);
        
        var lumaBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer!, 0); //Pixel_8 *
        
        var grayColorSpace = CGColorSpaceCreateDeviceGray(); //CGColorSpaceRef
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
        var context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, bitmapInfo.rawValue) //CGContextRef TODO try this!!
        var dstImage = CGBitmapContextCreateImage(context) //CGImageRef
        

        

        //waits, blocking thread
        dispatch_sync(dispatch_get_main_queue(), {
            var image = UIImage(CGImage: dstImage!, scale: 1.0, orientation: UIImageOrientation.Right)
      
            var minDimension = image.size.height;
            var diffWidthHeight = image.size.width-image.size.height
            
            if (image.size.height > image.size.width){
                minDimension = image.size.width;
                diffWidthHeight = image.size.height-image.size.width;
            }
            
            print("image: Width",image.size.width,"\tHeight:",image.size.height,"\t diff=",diffWidthHeight);

            //   ___________0,0
            //   |         |
            //   |         | Width
            //   |         |
            //   |_________|
            //     Height
            
            //Resizing photo and cropping. Square for now
            let pictureCanvasSize:CGSize=CGSize(width: minDimension, height: minDimension)
            
            UIGraphicsBeginImageContextWithOptions(pictureCanvasSize, false, image.scale)

            if(image.size.height > image.size.width) {
                image.drawInRect(CGRectMake(0, CGFloat(-diffWidthHeight/2), image.size.width, image.size.height)) //width/height scales to fit(so use all image)
            } else {
                image.drawInRect(CGRectMake(CGFloat(-diffWidthHeight/2),0, image.size.width, image.size.height))
            }
            image = UIGraphicsGetImageFromCurrentImageContext() //this returns a normalized image
            
            UIGraphicsEndImageContext()
    

            //TODO: Remove for DEBUGGing tab for OpenCV visual comparisons
            OverlayData.cameraImage=image
            CVWrapper.setFrameAsSceneImage(image);

            if(CVWrapper.isTrackableScene()) {
                print("isTrackableScene:[true]");
                //
                self.customPreviewLayer?.contents=CVWrapper.trackObjInSceneFrame( DrawBitmasks.ROIBOX.rawValue | DrawBitmasks.TRACKED.rawValue).CGImage! as CGImageRef
            } else {
                print("isTrackableScene:[FALSE]");
                self.customPreviewLayer?.contents=image.CGImage
            }

            
            //FPS
            var timepassed = self.currentTimeMillis();

            if (self.first)
            {
                self.frames = 0;
                self.starttime = timepassed;
                self.first = false;
                return;
            } else {
                if (timepassed - self.starttime > 1000.0 && self.frames > 3)
                {
                    self.fps = Double( Double(self.frames) / (timepassed - self.starttime)) * 1000.0;
                    self.starttime = timepassed;
                    self.frames = 0;

                    print("FPS: ",self.fps, "\tTimep: ",timepassed)
                }
            
            }
            self.frames++;
        });

    }
    
    
}


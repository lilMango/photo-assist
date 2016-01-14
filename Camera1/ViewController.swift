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
    CLLocationManagerDelegate{

    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var overlayImg:UIImage?=UIImage(named:"halfdome.jpg")
    var overlayImageView:UIImageView?
    
    var motionManager:CMMotionManager?
    var locationManager:CLLocationManager?
    
    //Attributes of current overlay
    var startLocation:CLLocation?
    var startOrientation:CMAcceleration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialize overlay with some stock 
        let bounds = UIScreen.mainScreen().bounds
        overlayImageView=UIImageView(image: overlayImg)
        print("main screen bounds: ",bounds)
        overlayView.addSubview(overlayImageView!)
        //overlayView.backgroundColor=UIColor.redColor()
        //libraryButton.backgroundColor=UIColor.blueColor()
        libraryButton.imageView!.contentMode=UIViewContentMode.ScaleAspectFit
        
        motionManager=CMMotionManager()
        motionManager!.accelerometerUpdateInterval=0.1 //half-second
        
        locationManager=CLLocationManager()
        locationManager!.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        startSensors()
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
        
        
        locationManager!.startUpdatingLocation()
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
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
        if captureSession!.canAddOutput(stillImageOutput) {
            captureSession!.addOutput(stillImageOutput)
            
        
            let bounds = UIScreen.mainScreen().bounds
            let previewViewBounds = previewView.bounds
            print("bounds2: ",bounds)

            print("previewView frame: ", previewView.frame)
            previewView.bounds=CGRect(x:0, y:0,
                width:UIScreen.mainScreen().bounds.width,height:previewView.bounds.height)
                        print("previewView bounds0:", previewViewBounds)
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

            previewLayer?.bounds=previewView.bounds
            //previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds)) //TODO what does position do??

            previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
            previewView.layer.addSublayer(previewLayer!)
            
            captureSession!.startRunning()
        } else {
            print("Failed at add Output to capture Session")
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
        previewLayer!.frame = CGRect(x:previewView.frame.minX,
            y:0,
            width:UIScreen.mainScreen().bounds.width,height:previewView.bounds.height)
        overlayImageView!.frame=CGRect(x:previewView.frame.minX, y:0,
            width:UIScreen.mainScreen().bounds.width,height:previewView.bounds.height)
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

    
    /* *************************************************************
     * Capturing Photo sequence (get buffer, saving it)
     * *************************************************************
     */
    @IBAction func didPressTakePhoto(sender: UIButton) {
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {

            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)

                    //self.libraryButton.setImage(image, forState: UIControlState.Normal)
                    print("accelerometerData: ", self.motionManager?.accelerometerData)
                    
                    self.startLocation = self.locationManager?.location
                    self.startOrientation = self.motionManager?.accelerometerData?.acceleration
                    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                }
            })
        }

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
            self.view.bringSubviewToFront(overlayView)
            self.view.bringSubviewToFront(textOverlay)
            overlayButton.setTitle("No Overlay", forState: UIControlState.Normal)
            startSensors()
        } else {
            //No overlay showing
            self.view.sendSubviewToBack(overlayView)
            self.view.sendSubviewToBack(textOverlay)
            stopSensors()
            overlayButton.setTitle("Overlay", forState: UIControlState.Normal)
        }
    }
    

    /*
    * Leads user to Photo Library/camera roll
    */
    @IBAction func viewPhotoLibrary(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            var imagePicker = UIImagePickerController()
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
}


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

class ViewController: UIViewController,UIImagePickerControllerDelegate,
    UINavigationControllerDelegate{

    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var overlayImg:UIImage?=UIImage(named:"halfdome.jpg")
    var overlayImageView:UIImageView?
    
    var motionManager:CMMotionManager?
    var motX:Int=0
    var motY:Int=0
    var motZ:Int=0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialize overlay with some stock 
        let bounds = UIScreen.mainScreen().bounds
        overlayImageView=UIImageView(image: overlayImg)
        print("main screen bounds: ",bounds)
        overlayView.addSubview(overlayImageView!)
        
        captureImageBtn.backgroundColor=UIColor.blueColor()
        captureImageBtn.imageView!.contentMode=UIViewContentMode.ScaleAspectFit
        
        motionManager=CMMotionManager()
        motionManager!.gyroUpdateInterval=0.5 //half-second
        motionManager!.startGyroUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    * Setting up device stuff like camera, gyroscope,gps every time this app comes into view.
    * Also acts like a setup
    */
    override func viewWillAppear(animated: Bool) {
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
        
    
        self.view.sendSubviewToBack(overlayView)
    
        //********** Gryoscrope inits *********

        motionManager!.startGyroUpdates()
        if motionManager?.gyroActive != nil && motionManager?.gyroActive==true  {
            print("gyro active")
        } else {
            print("gyro NOT active")
        }
        
        if motionManager?.gyroActive != nil && motionManager?.gyroAvailable==true {
            print("gyro available")
        } else {
            print("gyro NOT available")
        }
        print("gyroData[start]: ",motionManager?.gyroData)
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
        
        print("gyroData[end]: ",motionManager?.gyroData)
        motionManager?.stopGyroUpdates()
    }
    
    /***********************************************
    * Outlets
    *
    ************************************************/
    @IBOutlet weak var textOverlay: UITextView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var overlayButton: UIButton!
    @IBOutlet weak var previewView: UIView!

    @IBOutlet weak var captureImageBtn: UIButton!

    
    /**
     * Take a picture.
     * TODO send to camera roll
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
                    //self.capturedImage.image = image
                    self.captureImageBtn.setImage(image, forState: UIControlState.Normal)
                    print("gyroData: ", self.motionManager?.gyroData)
                    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                }
            })
        }

        //THe closest thing to manipulating Z-index of views
        //self.view.bringSubviewToFront(textOverlay)
    }

    /*
    *   Toggle showing of overlay
    */
    @IBAction func toggleShowOverlay(sender: UIButton) {
        if let isOverlayText = overlayButton.titleLabel?.text {
            if isOverlayText=="Overlay" {
                //Show overlay
                self.view.bringSubviewToFront(overlayView)

                overlayButton.setTitle("No Overlay", forState: UIControlState.Normal)
                
            }else {
                //No overlay showing
                overlayButton.setTitle("Overlay", forState: UIControlState.Normal)
                self.view.sendSubviewToBack(overlayView)
            }
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
            self.captureImageBtn.setImage(pickedImage, forState: UIControlState.Normal)
            overlayImageView!.image=pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }

}


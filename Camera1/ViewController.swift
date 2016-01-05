//
//  ViewController.swift
//  Camera1
//
//  Created by Miguel Paysan on 12/28/15.
//  Copyright © 2015 Miguel Paysan. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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

        if captureSession!.canAddOutput(stillImageOutput) {
            captureSession!.addOutput(stillImageOutput)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
            previewView.layer.addSublayer(previewLayer!)
            
            captureSession!.startRunning()
        } else {
            print("Failed at add Output to capture Session")
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
        
    }
    
    @IBOutlet weak var previewView: UIView!
    

    @IBOutlet weak var capturedImage: UIImageView!

    @IBAction func didPressTakePhoto(sender: UIButton) {
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.capturedImage.image = image
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                }
            })
        }

    }

}


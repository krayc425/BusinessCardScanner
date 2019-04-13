//
//  CameraViewController.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2019/4/9.
//  Copyright © 2019 宋 奎熹. All rights reserved.
//

import UIKit
import Vision
import AVFoundation
import ImageIO

protocol CapturePictureDelegate: class {
    func capture(with image: UIImage)
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var cameraButton: UIButton? = nil
    
    private let visualizeRectanglesView = VisualizeRectanlgesView(frame: .zero)
    private var session: AVCaptureSession?
    
    weak var delegate: CapturePictureDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(visualizeRectanglesView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAndStartAVCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopAVCaptureSession()
        self.navigationController?.navigationBar.isHidden = false
        super.viewWillDisappear(animated)
    }
    
    private func setButtons(frame: CGRect) {
        self.cameraButton = UIButton(frame: CGRect(origin: CGPoint(x: kScreenWidth / 2.0 - 30.0, y: (kScreenHeight + frame.origin.y + frame.height) / 2.0 - 30.0), size: CGSize(width: 60.0, height: 60.0)))
        self.cameraButton!.backgroundColor = .blue
        self.cameraButton!.layer.cornerRadius = 30.0
        self.cameraButton!.layer.masksToBounds = true
        self.cameraButton!.addTarget(self, action:
            #selector(self.captureAction(_:)), for: .touchUpInside)
        self.view.addSubview(self.cameraButton!)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func captureAction(_ sender: UIButton) {
        if let firstRect = visualizeRectanglesView.rectangles.first,
            let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            let rectCrop: CGRect = CGRect(x: firstRect.minX * (imageWidth),
                                          y: (1.0 - firstRect.maxY) * (imageHeight),
                                          width: firstRect.width * (imageWidth),
                                          height: firstRect.height * (imageHeight))
            let newImage = image.cropping(to: rectCrop)!
            self.dismiss(animated: true) {
                self.delegate?.capture(with: newImage)
            }
        }
    }
    
    private func setupAndStartAVCaptureSession() {
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSession.Preset.photo
        
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        let input = try! AVCaptureDeviceInput(device: device!)
        session?.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session?.addOutput(output)
        
        session?.startRunning()
    }
    
    private func stopAVCaptureSession() {
        session?.stopRunning()
    }
    
    private func imageFrameOnViewController(uiImage: UIImage) -> CGRect {
        let imageAspectRatio = uiImage.size.width / uiImage.size.height
        let viewAspectRatio = imageView.bounds.width / imageView.bounds.height
        if imageAspectRatio > viewAspectRatio {
            let ratio = imageView.bounds.width / uiImage.size.width
            return CGRect(
                x: imageView.frame.minX + 0,
                y: imageView.frame.minY + (imageView.bounds.height - ratio * uiImage.size.height) * 0.5,
                width: imageView.bounds.width,
                height: ratio * uiImage.size.height)
        } else {
            let ratio = view.bounds.height / uiImage.size.height
            return CGRect(
                x: imageView.frame.minX + (imageView.bounds.width - ratio * uiImage.size.width) * 0.5,
                y: imageView.frame.minY + 0,
                width: ratio * uiImage.size.width,
                height: imageView.bounds.height)
        }
    }
    
    func sampleBufferToUIImage(sampleBuffer: CMSampleBuffer, with orientation: UIInterfaceOrientation) -> UIImage {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        let quartzImage = context?.makeImage()
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly)
        
        if orientation == .landscapeLeft {
            return UIImage(cgImage: quartzImage!, scale: 1.0, orientation: .down)
        } else if orientation == .landscapeRight {
            return UIImage(cgImage: quartzImage!, scale: 1.0, orientation: .up)
        } else {
            return UIImage(cgImage: quartzImage!, scale: 1.0, orientation: .right)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async { [weak self] in
            let uiImage = self!.sampleBufferToUIImage(sampleBuffer: sampleBuffer, with: UIApplication.shared.statusBarOrientation)
            let orientation = CGImagePropertyOrientation(uiImage.imageOrientation)
            let ciImage = CIImage(image: uiImage)!
            
            if let frame = self?.imageFrameOnViewController(uiImage: uiImage) {
                self?.imageView.image = uiImage
                self?.visualizeRectanglesView.frame = frame
                
                if self?.cameraButton == nil {
                    self?.setButtons(frame: frame)
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: CGImagePropertyOrientation.RawValue(Int32(orientation.rawValue)))!)
            let request = VNDetectRectanglesRequest() { request, error in
                let rects = request.results?.flatMap { result -> [CGRect] in
                    guard let observation = result as? VNRectangleObservation, observation.confidence >= 0.9 else {
                        return []
                    }
                    
                    return [observation.boundingBox]
                    } ?? []
                
                self?.visualizeRectanglesView.rectangles = rects
            }
            
            request.maximumObservations = 1
            request.minimumAspectRatio  = 0.1
            
            try! handler.perform([request])
        }
    }
}

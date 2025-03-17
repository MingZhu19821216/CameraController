//
//  CameraController.swift
//  Camera
//
//  Created by Ming Zhu on 2025/3/17.
//

import Foundation
import AVFoundation
import Photos


public protocol CameraControllerDelegate: NSObjectProtocol {
    func didFinishRecording()
    func setupError(message: String)
}

open class CameraController: NSObject {
    
    public let captureSession = AVCaptureSession()
    private var videoOutput = AVCaptureMovieFileOutput()
    private var videoDevice: AVCaptureDevice!
    
    public weak var delegate: CameraControllerDelegate?
    
    public func setupCamera() {
        captureSession.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            delegate?.setupError(message: "No camera available")
            return
        }
        videoDevice = device
        
        do {
            let input = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            configureCameraSettings()
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        } catch {
            delegate?.setupError(message: "Error setting up camera: \(error)")
            print("Error setting up camera: \(error)")
        }
    }
    
    // 检测设备是否支持 120fps 拍摄
    private func is120FPSSupported(device: AVCaptureDevice) -> Bool {
        // 遍历所有设备格式
        for format in device.formats {
            let frameRateRanges = format.videoSupportedFrameRateRanges
            for range in frameRateRanges {
                // 检查是否支持 120fps 或更高
                if range.maxFrameRate >= 120.0 {
                    return true
                }
            }
        }
        return false
    }
    
    private func configureCameraSettings() {
        do {
            try videoDevice.lockForConfiguration()
            // **检查设备支持的最大帧率**
            if is120FPSSupported(device: videoDevice) {
                for format in videoDevice.formats {
                    let description = format.formatDescription
                    let dimensions = CMVideoFormatDescriptionGetDimensions(description)
                    let maxFrameRate = format.videoSupportedFrameRateRanges.first?.maxFrameRate ?? 0
                    
                    if maxFrameRate >= 120 && dimensions.width >= 1920 {
                        videoDevice.activeFormat = format
                        break
                    }
                }
                videoDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 120)
                videoDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 120)
            } else{
                delegate?.setupError(message:"您的设备不支持 120fps 录制")
                print("您的设备不支持 120fps 录制")
            }

            // 确保快门速度 1/1000s，ISO 2000
            if videoDevice.isExposureModeSupported(.custom) {
                let minISO = videoDevice.activeFormat.minISO
                let maxISO = videoDevice.activeFormat.maxISO
                let clampedISO = max(minISO, min(2000, maxISO)) // 确保 ISO 在设备支持的范围内
                videoDevice.setExposureModeCustom(duration: CMTime(value: 1, timescale: 1000), iso: clampedISO, completionHandler: nil)
            }
            
            videoDevice.unlockForConfiguration()
        } catch {
            delegate?.setupError(message:"Error configuring camera settings: \(error)")
            print("Error configuring camera settings: \(error)")
        }
    }
    
    public func startRecording() {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.mov")
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    public func stopRecording() {
        videoOutput.stopRecording()
    }
}

// MARK: - 录制代理
extension CameraController: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                }) { saved, error in
                    if saved {
                        self.delegate?.didFinishRecording()
                        print("视频已保存到相册")
                    }
                }
            }
        }
    }
}


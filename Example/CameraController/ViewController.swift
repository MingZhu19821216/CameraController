//
//  ViewController.swift
//  Camera
//
//  Created by Ming Zhu on 2025/3/17.
//

import UIKit
import AVFoundation
import Photos
import CameraController

class ViewController: UIViewController {
    private let cameraController = CameraController()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    let cameraBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setBackgroundImage(UIImage(systemName: "record.circle"), for: .normal)
        btn.setBackgroundImage(UIImage(systemName: "stop.circle"), for: .selected)
        
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        cameraBtn.addTarget(self, action: #selector(cameraClick), for: .touchUpInside)
        view.addSubview(cameraBtn)
        NSLayoutConstraint.activate([
            cameraBtn.widthAnchor.constraint(equalToConstant: 44),
            cameraBtn.heightAnchor.constraint(equalToConstant: 44),
            cameraBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            cameraBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func cameraClick() {
        cameraBtn.isSelected = !cameraBtn.isSelected
        if cameraBtn.isSelected {
            cameraController.startRecording()
        } else {
            cameraController.stopRecording()
        }
    }
    
    private func setupCamera() {
        previewLayer = AVCaptureVideoPreviewLayer(session: cameraController.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        cameraController.setupCamera()
        cameraController.delegate = self
    }
    
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Camera", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - 录制代理
extension ViewController: CameraControllerDelegate {
    func didFinishRecording() {
        showAlert(message: "拍摄完毕保存相册成功")
    }
    
    func setupError(message: String) {
        showAlert(message: message)
    }
}

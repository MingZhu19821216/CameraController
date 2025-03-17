# CameraController

[![CI Status](https://img.shields.io/travis/朱明/CameraController.svg?style=flat)](https://travis-ci.org/朱明/CameraController)
[![Version](https://img.shields.io/cocoapods/v/CameraController.svg?style=flat)](https://cocoapods.org/pods/CameraController)
[![License](https://img.shields.io/cocoapods/l/CameraController.svg?style=flat)](https://cocoapods.org/pods/CameraController)
[![Platform](https://img.shields.io/cocoapods/p/CameraController.svg?style=flat)](https://cocoapods.org/pods/CameraController)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CameraController is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CameraController'
```

## Author

MingZhu, 115688061@qq.com

## License

CameraController is available under the MIT license. See the LICENSE file for more info.

## 要求
- iOS 14.0+
- Xcode 12+
- 支持120fps录制的物理设备（如 iPhone 13 Pro 或更新机型）

## 安装步骤
1. 克隆仓库或复制代码到Xcode项目
2. 在 `Info.plist` 中添加以下权限描述：
   - `NSCameraUsageDescription`
   - `NSMicrophoneUsageDescription`（如需录制音频）
   - `NSPhotoLibraryAddUsageDescription`
   - `NSPhotoLibraryUsageDescription`
3. 在ViewController中添加相机预览层（示例代码见下文）
4. 连接物理设备运行（模拟器不支持摄像头）

## 使用示例代码
```swift
class ViewController: UIViewController {
    let cameraController = CameraController()

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
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraController.captureSession)
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

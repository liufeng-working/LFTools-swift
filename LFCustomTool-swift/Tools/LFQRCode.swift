//
//  LFQRCode.swift
//  QRCode
//
//  Created by 刘丰 on 2017/10/17.
//  Copyright © 2017年 liufeng. All rights reserved.
//

import UIKit
import AVFoundation

//MARK: -
//MARK: - 生成二维码
/// 生成二维码
public class LFQRCodeGenerate: NSObject {
    
    /// 单例
    public static let shareGenerate = LFQRCodeGenerate()
    
    /// 中心图片
    public var centerImage: UIImage?
    
    /// 生成的二维码尺寸(默认200*200)
    public var targetSize: CGSize = CGSize(width: 200, height: 200)
    
    /// 生成的二维码的颜色(默认黑色)
    public var targetColor: UIColor?
    
    /// 二维码的纠错水平（默认.L，此值越高，则可污损范围越大，二维码也越复杂）
    public var correctionLevel = LFQRCodeGenerate.LFCorrectionLevel.L
    
    /// 纠错水平
    public enum LFCorrectionLevel: String {
        case L /// 70%有效范围
        case H /// 50%有效范围
        case Q /// 25%有效范围
        case M /// 15%有效范围
    }
}

/// 公开方法
extension LFQRCodeGenerate {
    /// 生成一个二维码
    ///
    /// - Parameters:
    ///   - content: 内容
    ///   - centerimage: 中心图片（可选）
    ///   - completion: 回调
    public func generate(form content: String) -> UIImage? {
        
        //创建二维码滤镜
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        //重置滤镜
        filter.setDefaults()
        
        //设置滤镜输入数据
        guard let data = content.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        
        //设置二维码的纠错率
        filter.setValue(self.correctionLevel.rawValue, forKey: "inputCorrectionLevel")
        
        //从二维码滤镜中获取结果图片
        guard let ciImage = filter.outputImage else {
            return nil
        }
        
        //设置目标尺寸
        let uiImage = UIImage(ciImage: ciImage)
        let bigCIImg = ciImage.transformed(by: CGAffineTransform(scaleX: self.targetSize.width/uiImage.size.width, y: self.targetSize.height/uiImage.size.height))
        
        //图片
        var image = UIImage(ciImage: bigCIImg)
        image = self.changeImageColor(sourceImage: image)
        image = self.scaleImage(sourceImage: image)
        return image
    }
}

/// 私有方法
extension LFQRCodeGenerate {
    
    /// 缩放图片
    private func scaleImage(sourceImage: UIImage) -> UIImage {
        
        guard let centerImage = self.centerImage else {
            return sourceImage
        }
        
        let size = sourceImage.size
        UIGraphicsBeginImageContext(size)
        
        sourceImage.draw(at: CGPoint.zero)
        let centerW = centerImage.size.width
        let centerH = centerImage.size.height
        centerImage.draw(in: CGRect(x: (size.width - centerW)*0.5, y: (size.height - centerH)*0.5, width: centerW, height: centerH))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? sourceImage
    }
    
    /// 改变图片颜色
    private func changeImageColor(sourceImage: UIImage) -> UIImage {
        
        guard let targetColor = self.targetColor else {
            return sourceImage
        }
        
        let size = sourceImage.size
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return sourceImage
        }
        
        context.setFillColor(targetColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        sourceImage.draw(at: CGPoint.zero, blendMode: CGBlendMode.plusLighter, alpha: 1.0)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? sourceImage
    }
}

//MARK: -
//MARK: - 识别图片中的二维码
/// 识别图片中的二维码
public class LFQRCodeDetector: NSObject {

}

/// 公开方法
extension LFQRCodeDetector {
    /// 识别图片中的二维码
    ///
    /// - Parameter image: 图片
    /// - Returns: 结果包括（[String]?, [CIQRCodeFeature]?）
    public static func detector(image: UIImage) -> (strings: [String]?, qrFeatures: [CIQRCodeFeature]?) {
        
        //转成CIImage
        guard let img = CIImage(image: image) else {
            return (nil, nil)
        }
        
        //创建探测器
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
            return (nil, nil)
        }
        
        //探测图片
        let features = detector.features(in: img)
        
        var strings = [String]()
        var qrFeatures = [CIQRCodeFeature]()
        
        for feature in features {
            let qrF = feature as! CIQRCodeFeature
            strings.append(qrF.messageString ?? "")
            qrFeatures.append(qrF)
        }
        
        return (strings, qrFeatures)
    }
    
    /// 画出图片中被识别的所有二维码
    ///
    /// - Parameters:
    ///   - image: 原图
    ///   - qrFeatures: 此参数由方法`func detector(image: UIImage) -> (strings: [String]?, qrFeatures: [CIQRCodeFeature]?)`获取
    ///   - lineColor: 线颜色
    ///   - lineWidth: 线宽
    /// - Returns: 画好的图片
    public static func drawFrames(image: UIImage, qrFeatures: [CIQRCodeFeature], lineColor: UIColor = UIColor.red, lineWidth: CGFloat = 2.0) -> UIImage {
        
        var resultImg = image
        for qrF in qrFeatures {
            resultImg = self.drawFrame(image: resultImg, qrFeature: qrF, lineColor: lineColor, lineWidth: lineWidth)
        }
        return resultImg
    }
    
    /// 画出图片中被识别的一个二维码
    ///
    /// - Parameters:
    ///   - image: 原图
    ///   - qrFeatures: 此参数由方法`func detector(image: UIImage) -> (strings: [String]?, qrFeatures: [CIQRCodeFeature]?)`获取
    ///   - lineColor: 线颜色
    ///   - lineWidth: 线宽
    /// - Returns: 画好的图片
    public static func drawFrame(image: UIImage, qrFeature: CIQRCodeFeature, lineColor: UIColor = UIColor.red, lineWidth: CGFloat = 2.0) -> UIImage {
        
        let scale = image.scale
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        image.draw(at: CGPoint.zero)
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -size.height)
        
        let bounds = qrFeature.bounds
        let path = UIBezierPath(rect: CGRect(x: bounds.minX/scale, y: bounds.minY/scale, width: bounds.width/scale, height: bounds.height/scale))
        lineColor.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? image
    }
}

//MARK: -
//MARK: - 扫描二维码
/// 扫描二维码
public class LFQRCodeScanner: NSObject {
    
    /// 单例
    public static let shareScanner = LFQRCodeScanner()
    
    /// 有效扫描区域（默认和showInView的尺寸一致）
    public var rectOfInterest: CGRect?
    
    /// 成功回调(注意解决循环引用)
    public var success: ((_ strings: [String], _ qrObjects:  [AVMetadataMachineReadableCodeObject]) -> ())?
    
    /// 失败回调(注意解决循环引用)
    public var failure: ((_ errorMessage: String) -> ())?
    
    /// 是否画出扫描到的二维码（画在预览图层中）
    public var isDraw = false
    public var lineColor = UIColor.red
    public var lineWidth: CGFloat = 2.0
    
    /// 展示预览图层的view
    public var previewView: UIView? {
        return self.view
    }

    private lazy var session = AVCaptureSession()
    private var input: AVCaptureDeviceInput?
    private let output = AVCaptureMetadataOutput()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
    
    private var view: UIView?
    
    public override init() {
        super.init()
    }
    
    convenience init(showIn view: UIView) {
        self.init()
        
        self.view = view
    }
}

/// 公开方法
extension LFQRCodeScanner {
    /// 开始扫描
    public func startScan() {
        if self.session.isRunning {
            return
        }
        
        //防止多次添加
        self.previewLayer.removeFromSuperlayer()
        
        //设置输入
        //获取摄像头设备
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            self.failure?("摄像头不可用")
            return
        }
        
        do {
            self.input = try AVCaptureDeviceInput(device: device)
        }catch {
            self.failure?("摄像头不可用")
            return
        }
        
        //设置输出
        self.output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //连接输入和输出
        if self.session.canAddInput(self.input!) && self.session.canAddOutput(self.output) {
            self.session.addInput(self.input!)
            self.session.addOutput(self.output)
        }else {
            self.failure?("摄像头不可用")
            return
        }
        
        //设置输出解析类型必须要在添加到回话以后
        self.output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        if let view = self.view {
            
            //预览图层（不是必须的）
            self.previewLayer.frame = view.bounds
            view.layer.insertSublayer(self.previewLayer, at: 0)
            
            //设置扫描的兴趣区域
            if let frame = self.rectOfInterest {
                let x = frame.origin.y/view.frame.height
                let y = frame.origin.x/view.frame.width
                let w = frame.height/view.frame.height
                let h = frame.width/view.frame.width
                self.output.rectOfInterest = CGRect(x: x, y: y, width: w, height: h)
            }else {
                
                self.output.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
            }
        }
        
        //启动回话，让输入设备开始采集数据，输出设备处理数据
        self.session.startRunning()
    }
    
    /// 停止扫描
    public func stopScan() {
        if self.session.isRunning {
            self.session.removeInput(self.input!)
            self.session.removeOutput(self.output)
            self.session.stopRunning()
        }
    }
}

/// 私有方法
extension LFQRCodeScanner {
    
    private func drawFrame(qrObj: AVMetadataMachineReadableCodeObject) {
        let path = UIBezierPath()
    
        var index = 0
        for corner in qrObj.corners {
            if index == 0 {
                path.move(to: corner)
            }else {
                path.addLine(to: corner)
            }
            
            index += 1
        }
        path.close()
        
        let shapeLayer = LFShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = self.lineColor.cgColor
        shapeLayer.lineWidth = self.lineWidth
        self.previewLayer.addSublayer(shapeLayer)
    }
    
    private func removeFrame() {
        guard let subLayers = self.previewLayer.sublayers else {
            return
        }
        
        for case let subLayer in subLayers where subLayer.isKind(of: LFShapeLayer.self) {
            subLayer.removeFromSuperlayer()
        }
    }
    
    private class LFShapeLayer: CAShapeLayer {
        
    }
}

//MARK: - AVCaptureMetadataOutputObjectsDelegate代理
extension LFQRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        //先移除先前画好的frame
        self.removeFrame()
        
        var strings = [String]()
        var qrObjs = [AVMetadataMachineReadableCodeObject]()
        for case let obj in metadataObjects where obj.isKind(of: AVMetadataMachineReadableCodeObject.self) {
            //corners代表扫描到的二维码的几个角，需要借助视频预览图层转成需要的尺寸
            let resultObj = self.previewLayer.transformedMetadataObject(for: obj)
            let qrObj = resultObj as! AVMetadataMachineReadableCodeObject
            strings.append(qrObj.stringValue ?? "")
            qrObjs.append(qrObj)
            
            if self.isDraw {
                self.drawFrame(qrObj: qrObj)
            }
        }
        
        self.success?(strings, qrObjs)
    }
}

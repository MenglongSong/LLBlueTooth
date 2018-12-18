//
//  BLENativeVC.swift
//  LLBlueToothDemo
//
//  Created by SongMenglong on 2018/12/18.
//  Copyright © 2018 SongMengLong. All rights reserved.
//

import UIKit
import CoreBluetooth
import CommonCrypto

class BLENativeVC: UIViewController {
    
    // 中心设备
    private var centralManager: CBCentralManager?

    // 蓝牙设备
    private var bestPeripheral: ZBMyPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "蓝牙测试"
        
     
        // 初始化中心管理
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        
    }

}

// MARK:  实现代理协议的方法
extension BLENativeVC: CBCentralManagerDelegate {
    
    // 管理中心改变状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 扫描蓝牙设备
        central.scanForPeripherals(withServices: nil, options: nil)
        
        debugPrint("延时操作 准备")
        // 开始扫描
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            
            debugPrint("延时三秒结束")
            // 停止扫描
            central.stopScan()
            
            // 连接蓝牙设备
            central.connect(self.bestPeripheral!.peripheral!, options: nil)
        }
        debugPrint("操作111")
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //debugPrint("扫描到的蓝牙设备", peripheral)
        // 过滤蓝牙设备
        // ((peripheral.name?.contains("Gemvary")) == true || (peripheral.name?.contains("GEM-")) == true)
        if (peripheral.name?.contains("Gemvary")) == true && peripheral.state == CBPeripheralState.disconnected {
            if bestPeripheral == nil {
                bestPeripheral = ZBMyPeripheral()
                bestPeripheral?.peripheral = peripheral.copy() as? CBPeripheral
                bestPeripheral?.rssi = RSSI
            } else {
                if let rssi = bestPeripheral!.rssi, RSSI.intValue > rssi.intValue {
                    bestPeripheral?.peripheral = peripheral.copy() as? CBPeripheral
                    bestPeripheral?.rssi = RSSI
                }
            }
            
            debugPrint("最好的蓝牙设备", bestPeripheral?.peripheral as Any)
            debugPrint("最好的设备 信号",  bestPeripheral?.rssi as Any)
            debugPrint("最好的设备 广播数据", advertisementData)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugPrint("连接蓝牙设备 准备扫描旧蓝牙的服务")
        peripheral.discoverServices(nil)
        // 设置代理
        peripheral.delegate = self
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugPrint("蓝牙断开连接")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        debugPrint("蓝牙连接失败")
    }
    
}

extension BLENativeVC: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // 发现特征
        for service in peripheral.services! {
            debugPrint("遍历服务 发现特征")
            if service.uuid == CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455") {
                debugPrint("有旧蓝牙的服务", service)
                peripheral.discoverCharacteristics(nil, for: service)
            } else {
                debugPrint("没有旧蓝牙的服务", service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        debugPrint("扫描到的特征")
        for characteristic in service.characteristics! {
            if characteristic.uuid == CBUUID(string: "49535343-1E4D-4BD9-BA61-23C647249616") {
                debugPrint("有旧蓝牙的特征", characteristic)
                // 设置订阅
                peripheral.setNotifyValue(true, for: characteristic)
                // 准备写入值
                let inputStr: String = "15817998727".md5().uppercased()
                peripheral.writeValue(inputStr.data(using: String.Encoding.utf8)!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
            } else{
                debugPrint("没有旧蓝牙的特征", characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint("订阅的值 更新了没？？？", characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint("写入的值 更新了没？？？", characteristic)
    }
    
    
    
}

extension String {
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
}


public class ZBMyPeripheral: NSObject, NSCopying {
    var peripheral: CBPeripheral?
    var rssi: NSNumber?
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let temp = ZBMyPeripheral()
        temp.peripheral = self.peripheral
        temp.rssi = self.rssi
        return temp as Any
    }
}



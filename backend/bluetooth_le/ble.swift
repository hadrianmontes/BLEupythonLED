//
//  ble.swift
//  bluetooth_le
//
//  Created by Hadrián Montes Campos on 04/02/2020.
//  Copyright © 2020 Hadrián Montes Campos. All rights reserved.
//

import Foundation
import CoreBluetooth

public class UPythonCommunicator: NSObject{
    var central_manager: CBCentralManager!
    var queue: DispatchQueue!
    let TargetServiceCBUUID = CBUUID(string: "0001")
    public var uled = ULed()

    public override init() {
        super.init();
        queue = DispatchQueue(label: "test")
        central_manager = CBCentralManager(delegate: self, queue:queue);
     }

    public var state: String{
        get{
            switch central_manager.state {
            case .unknown:
                return "Unknown"
            case .resetting:
               return "Resseting"
            case .unsupported:
                return "Unsuported"
            case .unauthorized:
                return "Unnouthorized"
            case .poweredOff:
                return "Powered Off"
            case .poweredOn:
                return "Powered On"
                print(queue.label)
            @unknown default:
                fatalError()
            }
        }
    }



    public func scan()
    {
        switch central_manager.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resseting")
        case .unsupported:
            print("central.state is .unsuported")
        case .unauthorized:
            print("central.state is .unnouthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            print(queue.label)
        @unknown default:
            fatalError()
        }
        if central_manager.state == CBManagerState.poweredOn{
            print("PoweredOn")
            central_manager.scanForPeripherals(withServices: nil)
        }

    }

    public func connect() {
        if uled.peripheral == nil{
             return
         }
        let peripheral = uled.peripheral!
        if central_manager.state == CBManagerState.poweredOn{

                central_manager.connect(peripheral)
        }
        while peripheral.state != CBPeripheralState.connected{
        }
        peripheral.discoverServices(Array(uled.services.keys))



    }

    public func connect_and_wait(){
        print("Start_scanning")
        scan()
        while uled.peripheral == nil{
        }
        connect()
        while !uled.discovered{

        }
        sleep(1)

    }



}

extension UPythonCommunicator: CBCentralManagerDelegate{

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resseting")
        case .unsupported:
            print("central.state is .unsuported")
        case .unauthorized:
            print("central.state is .unnouthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            print(queue.label)
        @unknown default:
            fatalError()
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "uweather"{
            self.uled.peripheral = peripheral
            self.uled.peripheral.delegate = self
            central.stopScan()
        }
//        self.peripheral = peripheral
//        central.stopScan()
    }
}

extension UPythonCommunicator: CBPeripheralDelegate{
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            print(service)
            peripheral.discoverCharacteristics(Array(uled.services[service.uuid]!.keys), for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
          guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            uled.services[service.uuid]![characteristic.uuid] = characteristic
            uled.read_characteristics += 1
        }

    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        uled.read_values += 1
    }
}


public class ULed{
    public var peripheral: CBPeripheral!
    var read_values: Int = 0
    var read_characteristics = 0
    public var services: [CBUUID : [CBUUID : CBCharacteristic?]] = [
        CBUUID(string: "0001"):
            [CBUUID(string: "0001"): nil,
             CBUUID(string: "0002"): nil,
             CBUUID(string: "0003"): nil],

        CBUUID(string: "0002"):
            [CBUUID(string: "0001"): nil,
             CBUUID(string: "0002"): nil],

        CBUUID(string: "0003"):
            [CBUUID(string: "0001"): nil,
             CBUUID(string: "0002"): nil,
             CBUUID(string: "0003"): nil,
             CBUUID(string: "0004"): nil]
    ]

    init() {
    }

    public func read(service: String, characteristic: String) -> Data{
        read_values = 0
        let characteristic = services[CBUUID(string: service)]![CBUUID(string: characteristic)]!
        peripheral.readValue(for: characteristic!)
        while read_values == 0{

        }
        return characteristic!.value!
    }

    public func write(service: String, characteristic: String, value: String){
        let data = value.data(using: .ascii)
        let w_characteristic = services[CBUUID(string: service)]![CBUUID(string: characteristic)]!
        peripheral.writeValue(data!, for: w_characteristic!, type: .withResponse)

    }

    public func read_all(){
        for service in services.keys{
            for characteristic in services[service]!.keys{
                _ = read(service: service.uuidString, characteristic: characteristic.uuidString)
            }
        }
    }

    public var discovered: Bool{
        get {
            for service in services.values{
                for characteristic in service.values{
                    if characteristic == nil{
                        return false
                    }
                }
            }
            return true
        }
    }


}

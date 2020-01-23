//
//  main.swift
//  bluetooth_le
//
//  Created by Hadrián Montes Campos on 19/01/2020.
//  Copyright © 2020 Hadrián Montes Campos. All rights reserved.
//

import Foundation
import CoreBluetooth

class UPythonCommunicator: NSObject{
    var central_manager: CBCentralManager!
    var queue: DispatchQueue!
    let TargetServiceCBUUID = CBUUID(string: "0001")
    var uled = ULed()

    override init() {
        super.init();
        queue = DispatchQueue(label: "test")
        central_manager = CBCentralManager(delegate: self, queue:queue);
     }



    func scan()
    {
        if central_manager.state == CBManagerState.poweredOn{
            central_manager.scanForPeripherals(withServices: nil)
        }
    }

    func connect() {
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

        while !uled.discovered{

        }
        sleep(1)

    }



}

extension UPythonCommunicator: CBCentralManagerDelegate{

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
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
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            print(service)
            peripheral.discoverCharacteristics(Array(uled.services[service.uuid]!.keys), for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
          guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            uled.services[service.uuid]![characteristic.uuid] = characteristic
            uled.read_characteristics += 1
        }

    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        uled.read_values += 1
    }
}


class ULed{
    var peripheral: CBPeripheral!
    var read_values: Int = 0
    var read_characteristics = 0
    var services: [CBUUID : [CBUUID : CBCharacteristic?]] = [
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

    func read(service: String, characteristic: String) -> Data{
        read_values = 0
        let characteristic = services[CBUUID(string: service)]![CBUUID(string: characteristic)]!
        peripheral.readValue(for: characteristic!)
        while read_values == 0{

        }
        return characteristic!.value!
    }

    func read_all(){
        for service in services.keys{
            for characteristic in services[service]!.keys{
                _ = read(service: service.uuidString, characteristic: characteristic.uuidString)
            }
        }
    }

    var discovered: Bool{
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

print("Hello, World!")
var delegate = UPythonCommunicator()
delegate.scan()
while delegate.uled.peripheral == nil{
}
//print(delegate.uled.peripheral ?? "nil")
delegate.connect()
//print(delegate.uled.services)

var data1 = delegate.uled.read(service: "0001", characteristic: "0001")
var data2 = delegate.uled.read(service: "0001", characteristic: "0002")

print(String(decoding: data1, as: UTF8.self))
print(String(decoding: data2, as: UTF8.self))
delegate.uled.read_all()
print(delegate.uled.services)







//
//  main.swift
//  bluetooth_le
//
//  Created by Hadrián Montes Campos on 19/01/2020.
//  Copyright © 2020 Hadrián Montes Campos. All rights reserved.
//

import Foundation
import ble_backend

print("Hello, World!")
var delegate = ble_backend.UPythonCommunicator()

//print(delegate.uled.peripheral ?? "nil")
delegate.connect_and_wait()
//print(delegate.uled.services)

var data1 = delegate.uled.read(service: "0001", characteristic: "0001")
var data2 = delegate.uled.read(service: "0001", characteristic: "0002")

print(String(decoding: data1, as: UTF8.self))
print(String(decoding: data2, as: UTF8.self))
delegate.uled.read_all()
print(delegate.uled.services)
delegate.uled.write(service: "0001", characteristic: "0001", value: "2")
sleep(2)
print(delegate.state)







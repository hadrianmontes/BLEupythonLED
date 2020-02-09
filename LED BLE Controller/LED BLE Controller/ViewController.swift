//
//  ViewController.swift
//  LED BLE Controller
//
//  Created by Hadrián Montes Campos on 05/02/2020.
//  Copyright © 2020 Hadrián Montes Campos. All rights reserved.
//

import Cocoa
import ble_backend

extension  NSColor {

    var hexString: String {
        let red = Int(round(self.redComponent * 0xFF))
        let green = Int(round(self.greenComponent * 0xFF))
        let blue = Int(round(self.blueComponent * 0xFF))
        let hexString = NSString(format: "%02X%02X%02X", red, green, blue)
        return hexString as String
    }

}


class ViewController: NSViewController {
    @IBOutlet weak var b_stop: NSButton!
    @IBOutlet weak var b_still: NSButton!
    @IBOutlet weak var b_follow: NSButton!
    @IBOutlet weak var b_custom: NSButtonCell!

    @IBOutlet weak var clabel1: NSTextField!
    @IBOutlet weak var cbutton1: NSButton!
    @IBOutlet weak var color1: NSColorWell!
    @IBOutlet weak var clabel2: NSTextField!
    @IBOutlet weak var color2: NSColorWell!
    @IBOutlet weak var cbutton2: NSButton!

    @IBOutlet weak var bluetooth_state: NSTextField!

    @IBOutlet weak var connect_button: NSButton!
    @IBOutlet weak var time_slider: NSSlider!

    let bluetooth = UPythonCommunicator()

    var current_service: String = "0000"



    override func viewDidLoad() {
        super.viewDidLoad()
        update_state()
        set_initial_mode()

        

        // Do any additional setup after loading the view.
    }

    func update_state(){
        bluetooth_state.stringValue = bluetooth.state
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func update_color1(_ sender: Any) {
        clabel1.stringValue = color1.color.hexString
    }

    @IBAction func update_color2(_ sender: Any) {
        clabel2.stringValue = color2.color.hexString
    }

    @IBAction func connect(_ sender: Any) {
        bluetooth.connect_and_wait()
        connect_button.title = "Connected!"
    }



    @IBAction func send_color(_ sender: NSButton) {
        var characteristic = ""
        var color = color1

        switch sender {
        case cbutton1:
            characteristic = "0002"
            color = color1
        case cbutton2:
            characteristic = "0003"
            color = color2
        default:
            characteristic = "0002"
        }
        bluetooth.uled.write(service: current_service,
                             characteristic: characteristic,
                             value: color!.color.hexString)
    }

    @IBAction func send_timer(_ sender: Any) {
        let value = String(pow(10, time_slider.floatValue))
        bluetooth.uled.write(service: current_service,
                                 characteristic: "0004",
                                 value: value)
        }



    @IBAction func set_stop_mode(_ sender: Any) {
        set_initial_mode()
        current_service = "0001"
    }

    @IBAction func set_still_mode(_ sender: Any) {
        if !bluetooth.uled.discovered{
            return
        }
        current_service = "0002"


        b_stop.isEnabled = true
        b_still.isEnabled = false
        b_follow.isEnabled = true
        b_custom.isEnabled = false
        color1.isEnabled = true
        color2.isEnabled = false
        cbutton1.isEnabled = true
        cbutton2.isEnabled = false
        time_slider.isEnabled = false
        bluetooth.uled.write(service: "0001", characteristic: "0002", value: "2")
    }


    @IBAction func set_follow_mode(_ sender: Any) {
        if !bluetooth.uled.discovered{
            return
        }
        current_service = "0003"
        b_stop.isEnabled = true
        b_still.isEnabled = true
        b_follow.isEnabled = false
        b_custom.isEnabled = false
        color1.isEnabled = true
        color2.isEnabled = true
        cbutton1.isEnabled = true
        cbutton2.isEnabled = true
        time_slider.isEnabled = true
        bluetooth.uled.write(service: "0001", characteristic: "0002", value: "3")
    }



    func set_initial_mode(){
        b_stop.isEnabled = false
        b_still.isEnabled = true
        b_follow.isEnabled = true
        b_custom.isEnabled = false

        color1.isEnabled = false
        color2.isEnabled = false
        cbutton1.isEnabled = false
        cbutton2.isEnabled = false
        time_slider.isEnabled = false

        if bluetooth.uled.discovered{
            bluetooth.uled.write(service: "0001", characteristic: "0002", value: "0")
        }
        else{
            b_stop.isEnabled = true
            color1.isEnabled = true
        }
    }
}


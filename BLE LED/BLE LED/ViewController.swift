//
//  ViewController.swift
//  BLE LED
//
//  Created by Hadrián Montes Campos on 07/02/2020.
//  Copyright © 2020 Hadrián Montes Campos. All rights reserved.
//

import UIKit
import ble_ios_backend

class ViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var connect_button: UIButton!

    let bluetooth = UPythonCommunicator()

    var current_service: String = "0000"
    @IBOutlet weak var color1: UITextField!
    @IBOutlet weak var color1_red: UISlider!
    @IBOutlet weak var color1_green: UISlider!
    @IBOutlet weak var color1_blue: UISlider!
    @IBOutlet weak var color1_label: UILabel!

    @IBOutlet weak var color2: UITextField!
    @IBOutlet weak var color2_red: UISlider!
    @IBOutlet weak var color2_green: UISlider!
    @IBOutlet weak var color2_blue: UISlider!
    @IBOutlet weak var color2_label: UILabel!


    @IBOutlet weak var button_stop: UIButton!
    @IBOutlet weak var button_still: UIButton!
    @IBOutlet weak var button_follow: UIButton!
    @IBOutlet weak var button_custom: UIButton!

    @IBOutlet weak var send_color1: UIButton!
    @IBOutlet weak var send_color2: UIButton!


    @IBOutlet weak var slider_time: UISlider!


    override func viewDidLoad() {
        super.viewDidLoad()
        update_color1(self)
        update_color2(self)
        set_stop_mode(self)

        // Do any additional setup after loading the view.
    }
    @IBAction func connect(_ sender: Any) {
        bluetooth.scan()
        while bluetooth.uled.peripheral == nil{
            usleep(100)
        }
        bluetooth.connect()
        while !bluetooth.uled.discovered{
            usleep(100)
        }
        if bluetooth.uled.discovered{
            print("Connected")
            connect_button.setTitle("Connected", for: .normal)

        }

    }

    @IBAction func update_color1(_ sender: Any) {
        let red = CGFloat(color1_red.value / 255)
        let green = CGFloat(color1_green.value / 255)
        let blue = CGFloat(color1_blue.value / 255)

        let hexString = String(format: "%02X%02X%02X",
                                 Int(color1_red.value),
                                 Int(color1_green.value),
                                 Int(color1_blue.value))
        color1_label.text = hexString

        color1.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

    }

    @IBAction func update_color2(_ sender: Any) {
        let red = CGFloat(color2_red.value / 255)
        let green = CGFloat(color2_green.value / 255)
        let blue = CGFloat(color2_blue.value / 255)

        let hexString = String(format: "%02X%02X%02X",
                                 Int(color2_red.value),
                                 Int(color2_green.value),
                                 Int(color2_blue.value))
        color2_label.text = hexString

        color2.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    @IBAction func set_still_mode(_ sender: Any) {
        if !bluetooth.uled.discovered{
            return
        }

        button_stop.isEnabled = true
        button_still.isEnabled = false
        button_follow.isEnabled = true
        button_custom.isEnabled = false

        send_color1.isEnabled = true
        color1_red.isEnabled = true
        color1_blue.isEnabled = true
        color1_green.isEnabled = true

        send_color2.isEnabled = false
        color2_red.isEnabled = false
        color2_blue.isEnabled = false
        color2_green.isEnabled = false

        slider_time.isEnabled = false

        current_service = "0002"

        bluetooth.uled.write(service: "0001", characteristic: "0002",
                             value: "2")
    }

    @IBAction func set_follow_mode(_ sender: Any) {
        if !bluetooth.uled.discovered{
            return
        }

        button_stop.isEnabled = true
        button_still.isEnabled = true
        button_follow.isEnabled = false
        button_custom.isEnabled = false

        send_color1.isEnabled = true
        color1_red.isEnabled = true
        color1_blue.isEnabled = true
        color1_green.isEnabled = true

        send_color2.isEnabled = true
        color2_red.isEnabled = true
        color2_blue.isEnabled = true
        color2_green.isEnabled = true

        slider_time.isEnabled = true

        current_service = "0003"

        bluetooth.uled.write(service: "0001", characteristic: "0002",value: "3")
    }

    
    @IBAction func set_stop_mode(_ sender: Any) {


        button_stop.isEnabled = false
        button_still.isEnabled = true
        button_follow.isEnabled = true
        button_custom.isEnabled = false

        send_color1.isEnabled = false
        color1_red.isEnabled = false
        color1_blue.isEnabled = false
        color1_green.isEnabled = false

        send_color2.isEnabled = false
        color2_red.isEnabled = false
        color2_blue.isEnabled = false
        color2_green.isEnabled = false

        slider_time.isEnabled = false

        current_service = "0000"
        if bluetooth.uled.discovered{
            bluetooth.uled.write(service: "0001", characteristic: "0002",value: "0")
        }

    }

    @IBAction func send_color(_ sender: UIButton) {

        var characteristic = ""
        var color = color1_label

        switch sender {
        case send_color1:
            characteristic = "0002"
            color = color1_label
        case send_color2:
            characteristic = "0003"
            color = color2_label
        default:
            characteristic = "0002"
        }
        bluetooth.uled.write(service: current_service,
                             characteristic: characteristic,
                             value: color!.text!)
    }


    @IBAction func send_time(_ sender: UISlider) {
        let value = String(pow(10, slider_time.value))
         bluetooth.uled.write(service: current_service,
                                  characteristic: "0004",
                                  value: value)
    }


}


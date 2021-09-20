import bluetooth
import neopixel
import machine
import utime

class LedServices():
    SLEEP = 0.5
    SERVICE_MAP = {
    1: {1: None,
        2: None,
        3: None},
    2: {1: "Still",
        2: "ff0000"},
    3: {1: "Follow",
        2: "ff0000",
        3: "00ff00",
        4: "0.1",},
    4 : {
        1: "Custom",
        2: "0"},
    }

    def __init__(self, bluetooth_controller, nleds, pin):
        
        self.modes = {
            0: self.main_loop,
            1: self.finish,
            2: self.still,
            3: self.follow,
            4: self.custom,
        }
        
        self.bluetooth_controller = bluetooth_controller
        self.characteristics = {}

        self.lights = neopixel.NeoPixel(machine.Pin(pin), nleds)
        
        for i in range(nleds):
            self.SERVICE_MAP[4][i+3] = "000000"
    
        self._create_services()
        self._write_services()
        
        self._options = ()

    def _create_services(self):
        for service_uuid in self.SERVICE_MAP:
            self.characteristics[service_uuid] = {}
            for characteristic_uuid in self.SERVICE_MAP[service_uuid]:
                characteristic = bluetooth.Characteristic(uuid=characteristic_uuid,
                                                          flags=bluetooth.FLAG_WRITE | bluetooth.FLAG_READ)
                self.characteristics[service_uuid][characteristic_uuid] = characteristic
            self.bluetooth_controller.add_service(uuid=service_uuid,
                                                  characteristics=list(self.characteristics[service_uuid].values()))

    def _write_services(self):
        characteristics = 2
        for service_uuid in self.SERVICE_MAP:
            if service_uuid == 1:
                continue
            for characteristic_uuid in self.SERVICE_MAP[service_uuid]:
                characteristic = self.characteristics[service_uuid][characteristic_uuid]
                characteristic.write(self.SERVICE_MAP[service_uuid][characteristic_uuid])
                characteristics += 1
        self.characteristics[1][1].write(str(characteristics))
        self.characteristics[1][2].write("0")
        self.characteristics[1][3].write(str(self.lights.n))
        
    def changemode(self):
        mode = int(self.characteristics[1][2].read())
        self.modes[mode]()
        
    def main_loop(self):
        print("starting main")
        self.fill_color((255, 0, 0))
        while self.characteristics[1][2].read() == b"0":
            utime.sleep(self.SLEEP)
        self.changemode()
        
    def still(self):
        print("Starting Still")
        color = (0, 0 ,0)
        while self.characteristics[1][2].read() == b"2":
            colors = self.characteristics[2][2].read()
            newcolor = parse_colors(colors)
            
            if newcolor != color:
                color = newcolor
                print("Changing to color")
                print(color)
                self.fill_color(color)
 

            utime.sleep(self.SLEEP)
            
        self.changemode()
        
    def follow(self):
        print("Starting follow")
        def reread():
            color1 = parse_colors(self.characteristics[3][2].read())
            color2 = parse_colors(self.characteristics[3][3].read())
            time = float(self.characteristics[3][4].read())
            return color1, color2, time
        
        color1, color2, time = reread()
        
        self.fill_color(color2)
        while self.characteristics[1][2].read() == b"3":
            for i in range(self.lights.n):
                color1, color2, time = reread()
                self.lights[i] = color1
                self.lights.write()
                utime.sleep(time)
            for i in range(self.lights.n):
                color1, color2, time = reread()
                self.lights[self.lights.n - i - 1] = color2
                self.lights.write()
                utime.sleep(time)
        self.changemode()
            
            
            
        
    def custom(self):
        print("Starting custom")
        while self.characteristics[1][2].read() == b"4":
            if self.characteristics[4][2].read() != b"0":
                print("Showing")
                for index in range(self.lights.n):
                    color = parse_colors(self.characteristics[4][index+3].read())
                    self.lights[index] = color
                self.lights.write()
                self.characteristics[4][2].write("0")
            utime.sleep(self.SLEEP)
        self.changemode()
                
                    
    
    def finish(self):
        return
    
    def fill_color(self, color):
        for index in range(self.lights.n):
            self.lights[index] = color
        self.lights.write()
        
def parse_colors(colors):
    return (int(colors[:2], 16), int(colors[2:4], 16), int(colors[4:6], 16))
        
        
        

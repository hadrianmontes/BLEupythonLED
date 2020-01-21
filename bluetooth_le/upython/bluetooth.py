import bluetooth
import utime

from led_services import LedServices

INTERVAL = 10
SDA = 15
SCL = 4
blue = bluetooth.Bluetooth()
blue.active(True)
blue.advertise(100, "uweather")
print("HOLA")
led = LedServices(blue, 30, 4)
print("hola")

led.main_loop()


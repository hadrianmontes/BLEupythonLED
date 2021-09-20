import bluetooth
import utime

from led_services import LedServices

blue = bluetooth.Bluetooth()
blue.active(True)
blue.advertise(100, "uled")
print("UHOLA")
led = LedServices(blue, 30, 27)
print("hola")

led.main_loop()

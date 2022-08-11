import board
import digitalio
import time
from bbq10keyboard import BBQ10Keyboard, STATE_PRESS, STATE_RELEASE, STATE_LONG_PRESS

i2c = board.I2C()
kbd = BBQ10Keyboard(i2c)

kbd.backlight = 0.5
led_r = kbd.get_pin(0)
led_r.switch_to_output(value=True)
led_g = kbd.get_pin(1)
led_g.switch_to_output(value=True)
led_b = kbd.get_pin(2)
led_b.switch_to_output(value=True)

time.sleep(1)

led_r.value = False
time.sleep(1)
led_r.value = True
led_g.value = False
time.sleep(1)
led_g.value = True
led_b.value = False
time.sleep(1)
led_b.value = True

while True:
    key_count = kbd.key_count
    if key_count > 0:
        key = kbd.key
        state = 'pressed'
        if key[0] == STATE_LONG_PRESS:
            state = 'held down'
        elif key[0] == STATE_RELEASE:
            state = 'released'

        print("key: '%s' (dec %d, hex %02x) %s" % (key[1], ord(key[1]), ord(key[1]), state))

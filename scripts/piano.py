from pynput.keyboard import Key, Listener
import os
import serial


if os.name == 'nt':
    print('Windows machine!')
    ser = serial.Serial()
    ser.baudrate = 115200
    ser.port = 'COM3' # CHANGE THIS COM PORT
    ser.open()
else:
    print('Not windows machine!')
    ser = serial.Serial('/dev/ttyUSB0')
    ser.baudrate = 115200

#keys_pressed = set()
active_key = None

def start_playing(key):
    ser.write(bytearray([0x80]))
    ser.write(bytearray([ord(key.char)]))

def stop_playing(key):
    ser.write(bytearray([0x81]))
    ser.write(bytearray([ord(key.char)]))

def on_press(key):
    global active_key
    if key == Key.esc:
        if active_key is not None:
            stop_playing(active_key)
        # Stop listener
        return False

    # Stop playing already active key
    if active_key is not None and key.char is not active_key.char:
        stop_playing(active_key)

    if active_key is None or active_key.char is not key.char:
        active_key = key
        start_playing(key)
        print('{0} pressed'.format(key))
    """
    if key not in keys_pressed:
        ser.write(bytearray([0x80]))
        ser.write(bytearray([ord(key.char)]))
    keys_pressed.add(key)
    """

def on_release(key):
    global active_key
    if active_key is not None and key.char == active_key.char:
        stop_playing(active_key)
        active_key = None

    print('{0} release'.format(key))
    """
    if key in keys_pressed:
        keys_pressed.remove(key)
        ser.write(bytearray([0x81]))
        ser.write(bytearray([ord(key.char)]))
    if key == Key.esc:
        # Stop listener
        return False
    """

# Collect events until released
with Listener(
        on_press=on_press,
        on_release=on_release,
        suppress=True) as listener:
    listener.join()
import time

def smooth_scroll(text, speed):
    text_len = len(text)
    while True:
        for i in range(text_len):
            print(text[i:] + text[:i], end="\r")
            time.sleep(speed)

text = "Hello, world!"
speed = 0.1
smooth_scroll(text, speed)
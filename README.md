# arduspeedo

![arduspeedo](https://raw.githubusercontent.com/joshscurtis/arduspeedo/master/arduspeedo.png)

A simple POC to make a Speedometer using an Arduino, a GPS module, and a 4-digit segmented display.

The GPS and Display are connected via serial links.

The GPS sends data periodically that is caught within the Arduino and parsed for speed. The speed is then formatted and displayed on the Display.
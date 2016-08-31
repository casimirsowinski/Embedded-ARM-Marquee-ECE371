# Embedded-ARM-Marquee-ECE371
Embedded ARM assembly code to make lights blink using interrupts and a button.

This program hooks the interrupt vector on the BBB and chains an interrupt procedure. 

Pressing the onboard button starts an interrupt through the INT_DIRECTOR function which begins the LED marquee animation using delays.

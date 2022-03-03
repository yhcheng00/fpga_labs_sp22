`timescale 1ns / 1ps

module z1top(
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS
);
  wire a,b,c,d,e,f;
  assign a = BUTTONS[0] & BUTTONS[1];
  assign b = BUTTONS[2] & BUTTONS[3];
  assign c = BUTTONS[0] & BUTTONS[2];
  assign d = BUTTONS[1] & BUTTONS[3];
  assign e = BUTTONS[0] & BUTTONS[3];
  assign f = BUTTONS[1] & BUTTONS[2];
  or(LEDS[0], a,b,c,d,e,f);
  assign LEDS[5:1] = 0'b11111;
endmodule

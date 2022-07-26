`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH UST
// Engineers: Hubert Kwaśniewski, Marcin Mistela
// 
// Create Date: 04.08.2022 09:45:43
// Design Name: 
// Module Name: vga_example
// Project Name: Tic-tac-toe game
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: moduły VGA_example, VGA_timing, Mouse_Display, Mouse_ctl, font_rom, char_rom udostępnione na zajęciach UEC2
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_example(
      input wire clk,
      input wire rst,
      input wire rx,
      inout ps2_clk,
      inout ps2_data,
      output reg vs,
      output reg hs,
      output reg [3:0] r,
      output reg [3:0] g,
      output reg [3:0] b,
      output wire tx
    );
    
    
  wire pclk_75MHz;
  wire pclk_100MHz;
  
  wire hsync_out_rect;
  wire vsync_out_rect;
  wire [11:0] rgb_out_rect;
  wire [10:0] hcount_out_rect;
  wire [10:0] vcount_out_rect;
  wire hblnk_out_rect;
  wire vblnk_out_rect;
  wire [11:0] xpos_in_rect;
  wire [11:0] ypos_in_rect;
  wire mouse_left, mouse_left1, mouse_left2;
  
  wire [11:0] xpos_in_rect1;
  wire [11:0] xpos_in_rect2;
  wire [11:0] ypos_in_rect1;
  wire [11:0] ypos_in_rect2;
  wire start_en, choice_en, uart_en, uart_mode, write_uart_en, game_over, new_game;
  wire playerID, rx_tx_done;
  wire [7:0] w_data, r_data, r_data1, r_data2;
  wire [8:0] square1to9, square1to9_color;
  wire [1:0] display_winner;
  
    
  wire locked;
  wire rst_d;
  
  clk_wiz_0 my_clk_wiz_0(
    .clk_100MHz(pclk_100MHz),
    .clk_75MHz(pclk_75MHz),
    .clk(clk),
    .reset(rst),
    .locked(locked)
  );  
  
  reset_delay my_reset_delay(
    .pclk(pclk_75MHz),
    .locked(locked),
    .rst_d(rst_d)
  );
  
  wire rst_d1;
  wire rst_d2;
  
  ff_synchronizer first_stage(
    .pclk(pclk_100MHz),
    .rst(rst),
    .din(rst_d),
    .dout(rst_d1)
  );
  
  ff_synchronizer second_stage(
    .pclk(pclk_100MHz),
    .rst(rst),
    .din(rst_d1),
    .dout(rst_d2)
  );
  
   control_unit control_unit(
    .pclk(pclk_75MHz),
    .rst(rst_d),
    .mouse_xpos(xpos_in_rect2),
    .mouse_ypos(ypos_in_rect2),
    .mouse_left(mouse_left2),
    .rx_tx_done(rx_tx_done),
    .square1to9(square1to9),
    .game_over(game_over),
    .start_en(start_en),
    .choice_en(choice_en),
    .playerID(playerID),
    .uart_en(uart_en),
    .write_uart_en(write_uart_en),
    .uart_mode(uart_mode),
    .new_game(new_game)
  );
  
  
  wire [10:0] vcount_in;
  wire [10:0] hcount_in;
  wire vsync_in, hsync_in;
  wire vblnk_in, hblnk_in;

  vga_timing my_timing (
    .vcount(vcount_in),
    .vsync(vsync_in),
    .vblnk(vblnk_in),
    .hcount(hcount_in),
    .hsync(hsync_in),
    .hblnk(hblnk_in),
    .pclk(pclk_75MHz),
	.rst(rst_d)
  );

  wire [10:0] vcount_out_char, hcount_out_char;
  wire [11:0] rgb_in_background;
  wire [7:0] char_xy, char_pixels;
  wire [3:0] char_line;
  wire [6:0] char_code;
  wire vsync_out_char, hsync_out_char, vblnk_out_char, hblnk_out_char;
  
  draw_rect_char draw_start_screen(
    .pclk(pclk_75MHz),
    .rst(rst_d),
    .hcount_in(hcount_in),
    .hsync_in(hsync_in),
    .hblnk_in(hblnk_in),
    .vcount_in(vcount_in),
    .vsync_in(vsync_in),
    .vblnk_in(vblnk_in),
    .char_pixels(char_pixels),
    .hcount_out(hcount_out_char),
    .hsync_out(hsync_out_char),
    .hblnk_out(hblnk_out_char),
    .vcount_out(vcount_out_char),
    .vsync_out(vsync_out_char),
    .vblnk_out(vblnk_out_char),
    .rgb_out(rgb_in_background),
    .char_xy(char_xy),
    .char_line(char_line),
    .start_en(start_en),
    .choice_en(choice_en),
    .game_over(game_over)
  );
  
  font_rom font_rom(
    .clk(pclk_75MHz),
    .addr({char_code, char_line}),
    .char_line_pixels(char_pixels)
  );
 
 
  char_rom char_rom(
    .char_xy(char_xy),
    .choice_en(choice_en),
    .display_winner(display_winner),
    .char_code(char_code)
  );

  wire [10:0] vcount_out;
  wire [10:0] hcount_out;
  wire hsync_out;
  wire hblnk_out;
  wire vsync_out;
  wire vblnk_out;
  wire [11:0] rgb_out;
  
  draw_background my_draw_background(
    .pclk(pclk_75MHz),
    .rgb_in(rgb_in_background),
    .vcount_in(vcount_out_char),
    .vsync_in(vsync_out_char),
    .vblnk_in(vblnk_out_char),
    .hcount_in(hcount_out_char),
    .hsync_in(hsync_out_char),
    .hblnk_in(hblnk_out_char),
    .vcount_out(vcount_out),
    .vsync_out(vsync_out),
    .vblnk_out(vblnk_out),
    .hcount_out(hcount_out),
    .hsync_out(hsync_out),
    .hblnk_out(hblnk_out),
    .rgb_out(rgb_out),
    .rst(rst_d),
    .start_en(start_en),
    .choice_en(choice_en),
    .game_over(game_over)
  );
  
  ff_synchronizer #(.WIDTH(12)) first_stage_xpos(
    .pclk(pclk_75MHz),
    .rst(rst),
    .din(xpos_in_rect),
    .dout(xpos_in_rect1)
  );
  
  ff_synchronizer #(.WIDTH(12)) second_stage_xpos(
    .pclk(pclk_75MHz),
    .rst(rst),
    .din(xpos_in_rect1),
    .dout(xpos_in_rect2)
  );
  
  ff_synchronizer #(.WIDTH(12)) first_stage_ypos(
    .pclk(pclk_75MHz),
    .rst(rst),
    .din(ypos_in_rect),
    .dout(ypos_in_rect1)
  );
  
  ff_synchronizer #(.WIDTH(12)) second_stage_ypos(
    .pclk(pclk_75MHz),
    .rst(rst),
    .din(ypos_in_rect1),
    .dout(ypos_in_rect2)
  );
  
  ff_synchronizer first_stage_mouse_left(
    .pclk(pclk_75MHz),
    .rst(rst),
    .din(mouse_left),
    .dout(mouse_left1)
  );
  
  ff_synchronizer second_stage_mouse_left(
    .pclk(pclk_75MHz),
    .rst(rst),
    .din(mouse_left1),
    .dout(mouse_left2)
  );
  
  ff_synchronizer #(.WIDTH(8))first_stage_r_data(
    .pclk(pclk_75MHz),
    .rst(rst),
    .din(r_data),
    .dout(r_data1)
  );
  
  ff_synchronizer #(.WIDTH(8))second_stage_r_data(
    .pclk(pclk_75MHz),
    .rst(rst),
    .din(r_data1),
    .dout(r_data2)
  );
  
    UART my_UART(
    .w_data(w_data),
    .clk(pclk_100MHz), .reset(rst_d2),
    .uart_mode(uart_mode), 
    .uart_en(uart_en),
    .new_game(new_game),
    .tx(tx),
    .rx(rx),
    .rx_tx_done(rx_tx_done),
    .rec_data(r_data)
  );
  
  winner_check my_winner_check(
    .pclk(pclk_75MHz), .rst(rst_d || new_game),
    .square1to9(square1to9), .square1to9_color(square1to9_color),
    .display_winner(display_winner), .game_over(game_over)
  );
  
  square_ctl my_square_ctl(
    .pclk(pclk_75MHz), .rst(rst_d),
    .mouse_left(mouse_left2),
    .xpos(xpos_in_rect2),
    .ypos(ypos_in_rect2),
    .start_en(start_en),
    .choice_en(choice_en),
    .playerID(playerID),
    .write_uart_en(write_uart_en),
    .rec_data(r_data2),
    .w_data(w_data),
    .square1to9(square1to9), .square1to9_color(square1to9_color), .new_game(new_game)
    );
  
  
  draw_rect my_draw_rect(
    .pclk(pclk_75MHz),
    .hcount_in(hcount_out),
    .hsync_in(hsync_out),
    .hblnk_in(hblnk_out),
    .vcount_in(vcount_out),
    .vsync_in(vsync_out),
    .vblnk_in(vblnk_out),
    .rgb_in(rgb_out),
    .hcount_out(hcount_out_rect),
    .hsync_out(hsync_out_rect),
    .hblnk_out(hblnk_out_rect),
    .vcount_out(vcount_out_rect),
    .vsync_out(vsync_out_rect),
    .vblnk_out(vblnk_out_rect),
    .rgb_out(rgb_out_rect),
    .rst(rst_d),
    .start_en(start_en),
    .choice_en(choice_en),
    .square1to9(square1to9), .square1to9_color(square1to9_color)
  );
  
  MouseCtl my_mouse_ctl(
    .clk(pclk_100MHz),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .xpos(xpos_in_rect),
    .ypos(ypos_in_rect),
    .rst(rst_d2),
    .zpos(),
    .left(mouse_left),
    .middle(),
    .right(),
    .new_event(),
    .value(12'b0),
    .setx(1'b0),
    .sety(1'b0),
    .setmax_x(1'b0),
    .setmax_y(1'b0)
  );
  
  
  wire hs_d;
  wire vs_d;
  
  ff_delay my_ff_delay(
    .pclk(pclk_75MHz),
    .hsync_in(hsync_out_rect),
    .vsync_in(vsync_out_rect),
    .hsync_out(hs_d),
    .vsync_out(vs_d),
    .rst(rst_d)
  );
  
  wire [3:0] red_out;
  wire [3:0] green_out;
  wire [3:0] blue_out;
  
  MouseDisplay my_mouse_display(
    .pixel_clk(pclk_75MHz),
    .xpos(xpos_in_rect2),
    .ypos(ypos_in_rect2),
    .hcount(hcount_out_rect),
    .vcount(vcount_out_rect),
    .blank(hblnk_out_rect || vblnk_out_rect),
    .red_in(rgb_out_rect [11:8]),
    .green_in(rgb_out_rect [7:4]),
    .blue_in(rgb_out_rect [3:0]),
    .red_out(red_out),
    .green_out(green_out),
    .blue_out(blue_out),
    .enable_mouse_display_out()
  );
  
  
  always@(posedge pclk_75MHz)
  begin
    hs <= hs_d;
    vs <= vs_d;
    r  <= red_out;
    g  <= green_out;
    b  <= blue_out;
    
  end

  
  
    
endmodule

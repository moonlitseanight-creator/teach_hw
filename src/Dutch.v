`default_nettype none

module tt_um_vga_example(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD pin mapping
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  // Flag drawing logic (640x480 visible area)
  always @(*) begin
    if (!video_active) begin
      R = 2'b00;
      G = 2'b00;
      B = 2'b00;
    end else if (pix_y < 10'd160) begin
      // Top stripe: Red
      R = 2'b11;
      G = 2'b00;
      B = 2'b00;
    end else if (pix_y < 10'd320) begin
      // Middle stripe: White
      R = 2'b11;
      G = 2'b11;
      B = 2'b11;
    end else begin
      // Bottom stripe: Blue
      R = 2'b00;
      G = 2'b00;
      B = 2'b11;
    end
  end

endmodule
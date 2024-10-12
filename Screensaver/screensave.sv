module screensaver (
   input  logic       clk_i,
   input  logic       rst_ni,

   input  logic [3:0] select_image_i,

   output logic [3:0] vga_red_o,
   output logic [3:0] vga_blue_o,
   output logic [3:0] vga_green_o,
   output logic       vga_hsync_o,
   output logic       vga_vsync_o

);

localparam int IMAGE_WIDTH = 160;
localparam int IMAGE_HEIGHT = 120;
localparam int IMAGE_ROM_SIZE = (IMAGE_WIDTH * IMAGE_HEIGHT);

logic [$clog2(IMAGE_ROM_SIZE)-1:0] rom_addr;

logic [11:0] image0_rdata;
logic [11:0] image1_rdata;
logic [11:0] image2_rdata;
logic [11:0] image3_rdata;

images #(
   .IMAGE_ROM_SIZE(IMAGE_ROM_SIZE)
) images (
   .clk_i,
   .rom_addr_i(rom_addr),
   .image0_rdata_o(image0_rdata),
   .image1_rdata_o(image1_rdata),
   .image2_rdata_o(image2_rdata),
   .image3_rdata_o(image3_rdata)
);

// TODO
assign rom_addr = (position_y_o[9:2] * IMAGE_WIDTH) + position_x_o[9:2];

logic [9:0] position_x_o, position_y_o;
logic hsync_q;
logic vsync_q, visible_o, visible_q;
vga_timer vga (
   .clk_i(clk_i),
   .rst_ni(rst_ni),
   .visible_o(visible_q),
   .position_x_o(position_x_o),
   .position_y_o(position_y_o),
   .hsync_o(hsync_q),
   .vsync_o(vsync_q)
);

//choose pixel
always_comb begin
   {vga_red_o, vga_green_o, vga_blue_o} = 0;
   if (visible_o) begin
       case (image_q)
           4'b0001: {vga_red_o, vga_green_o, vga_blue_o} = image0_rdata;
           4'b0010: {vga_red_o, vga_green_o, vga_blue_o} = image1_rdata;
           4'b0100: {vga_red_o, vga_green_o, vga_blue_o} = image2_rdata;
           4'b1000: {vga_red_o, vga_green_o, vga_blue_o} = image3_rdata;
           default: {vga_red_o, vga_green_o, vga_blue_o} = 0;
       endcase
   end else begin
        {vga_red_o, vga_green_o, vga_blue_o} = 0;
   end
end

// set color
always_comb begin
    image_d = image_q;
    case (select_image_i)
        4'b0001: image_d = 4'b0001;

        4'b0010: image_d = 4'b0010;

        4'b0100: image_d = 4'b0100;

        4'b1000: image_d = 4'b1000;

        default: image_d = image_q;
    endcase
end

logic [3:0] image_q, image_d;
always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        image_q <= '0;
    end else begin
        image_q <= image_d;
    end
end

// Delay
always_ff @(posedge clk_i) begin
    vga_hsync_o <= hsync_q;
    vga_vsync_o <= vsync_q;
    visible_o <= visible_q;
end

endmodule
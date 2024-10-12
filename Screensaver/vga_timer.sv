// https://vesa.org/vesa-standards/
// http://tinyvga.com/vga-timing
module vga_timer (
   // TODO
   // possible ports list:
   input  logic       clk_i,
   input  logic       rst_ni,
   output logic       hsync_o,
   output logic       vsync_o,
   output logic       visible_o,
   output logic [9:0] position_x_o,
   output logic [9:0] position_y_o
);

// TODO
assign position_x_o = count_q_x;
assign position_y_o = count_q_y;

always_comb begin
    count_d_x = count_q_x;
   if (count_q_x < 799) begin
       count_d_x = count_q_x + 1;
   end else begin
       count_d_x  = 0;
    end
end

always_comb begin
    count_d_y = count_q_y;
    if(count_q_x == 799) begin
        if(count_q_y < 524) begin
            count_d_y = count_d_y + 1;
        end else begin
            count_d_y = 0;
        end
    end
end

always_comb begin
    if((count_q_x < 640) && (count_q_y < 480)) begin
        visible_o = 1;
    end else begin
        visible_o = 0;
    end
end

// hsync
always_comb begin
    if((count_q_x >= 656) && (count_q_x <= 751)) begin
        hsync_o = 0;
    end else begin
        hsync_o = 1;
    end
end

// vsync
always_comb begin
    if((count_q_y >= 490) && (count_q_y <= 491)) begin
        vsync_o = 0;
    end else begin
        vsync_o = 1;
    end
end

logic [9:0] count_q_x, count_q_y, count_d_x, count_d_y;
always_ff @(posedge clk_i) begin
   if (!rst_ni) begin
       count_q_x <= 0;
       count_q_y <= 0;
   end else begin
       count_q_x <= count_d_x;
       count_q_y <= count_d_y;
   end
end

endmodule
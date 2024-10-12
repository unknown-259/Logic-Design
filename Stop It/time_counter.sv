module time_counter (
    input  logic       clk_4_i,
    input  logic       rst_ni,
    input  logic       en_i,
    output logic [4:0] count_o
);

// TODO
always_comb begin
    count_d = count_q + 1;
end

logic [4:0] count_q, count_d;
always_ff @(posedge clk_4_i) begin
   if (!rst_ni) begin
       count_q <= 5'b0;
   end else if (en_i) begin
       count_q <= count_d;
   end
end

assign count_o = count_q;

endmodule
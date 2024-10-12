module alu (
  input  logic [7:0] a_i,
  input  logic [7:0] b_i,
  input  logic [3:0] operation_i,
  output logic [7:0] y_o
);

logic [7:0] flog_o;

flog2 c_1(
  .b_i (a_i),
  .y_o (flog_o)
);

logic [7:0] sqrt_o;

sqrt c_0(
  .a_i (a_i),
  .y_o (sqrt_o)
);

// TODO
always_comb begin
  case(operation_i)
      4'b0001: y_o = a_i + b_i;
      4'b0010: y_o = a_i - b_i;
      4'b0100: y_o = flog_o;
      4'b1000: y_o = sqrt_o;
      default: y_o = 0;
  endcase
end

endmodule
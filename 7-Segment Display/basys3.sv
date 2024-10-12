
module basys3(
    input  logic [3:0] sw,
    output logic [6:0] seg,
    output logic       dp,
    output logic [3:0] an
);

logic [6:0] seg_n;
assign seg = ~seg_n;

// TODO
assign dp = 1;
assign an = 4'b1110;

hex7seg hex7seg (
    .d3(sw[3]),
    .d2(sw[2]),
    .d1(sw[1]),
    .d0(sw[0]),

    .A(seg_n[0]),
    .B(seg_n[1]),
    .C(seg_n[2]),
    .D(seg_n[3]),
    .E(seg_n[4]),
    .F(seg_n[5]),
    .G(seg_n[6])
);

endmodule
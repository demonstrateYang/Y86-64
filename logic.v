// Split instruction byte into icode and ifun fields

module split(ibyte, icode, ifun);
    input [7:0] ibyte;
    output [3:0] icode;
    output [3:0] ifun;
    assign icode = ibyte[7:4];
    assign ifun = ibyte[3:0];
endmodule


// Extract immediate word from 9 bytes of instruction
module align(ibytes, need_regids, rA, rB, valC);
    //9字节，高4位ra/ra+4=rb,remain is valC
    input [71:0] ibytes;
    input need_regids;
    output [ 3:0] rA;
    output [ 3:0] rB;
    output [63:0] valC;
    assign rA = ibytes[7:4];
    assign rB = ibytes[3:0];
    assign valC = need_regids ? ibytes[71:8] : ibytes[63:0];
endmodule

// PC incrementer
module pc_increment(pc, need_regids, need_valC, valP);
    input [63:0] pc;
    input need_regids;
    input need_valC;
    output [63:0] valP;
    assign valP = pc + 1 + 8*need_valC + need_regids;
endmodule


module alu(aluA, aluB, alufun, valE, new_cc);
    input [63:0] aluA, aluB; // Data inputs
    input [ 3:0] alufun; // ALU function
    output [63:0] valE; // Data Output
    output [ 2:0] new_cc; // New values for ZF, SF, OF
    parameter ALUADD = 4'h0;
    parameter ALUSUB = 4'h1;
    parameter ALUAND = 4'h2;
    parameter ALUXOR = 4'h3;
    assign valE =
    alufun == ALUSUB ? aluB - aluA :
    alufun == ALUAND ? aluB & aluA :
    alufun == ALUXOR ? aluB ^ aluA :
    aluB + aluA;
    assign new_cc[2] = (valE == 0); // ZF
    assign new_cc[1] = valE[63]; // SF
    assign new_cc[0] = // OF
    alufun == ALUADD ?
    (aluA[63] == aluB[63]) & (aluA[63] != valE[63]) :
    alufun == ALUSUB ?
    (~aluA[63] == aluB[63]) & (aluB[63] != valE[63]) :
    0;
endmodule

// Clocked register with enable signal and synchronous reset
// Default width is 8, but can be overriden
module cenrreg(out, in, enable, reset, resetval, clock);
parameter width = 8;
output [width-1:0] out;
reg [width-1:0] out;
input [width-1:0] in;
input enable;
input reset;
input [width-1:0] resetval;
input clock;
always
@(posedge clock)
begin
if (reset)
out <= resetval;
else if (enable)
out <= in;
end
endmodule

// Pipeline register. Uses reset signal to inject bubble
// When bubbling, must specify value that will be loaded
module preg(out, in, stall, bubble, bubbleval, clock);
parameter width = 8;
output [width-1:0] out;
input [width-1:0] in;
input stall, bubble;
input [width-1:0] bubbleval;
input clock;
cenrreg #(width) r(out, in, ~stall, bubble, bubbleval, clock);
endmodule



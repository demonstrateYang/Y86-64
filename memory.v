module bmemory(maddr, wenable, wdata, renable, rdata, m_ok,iaddr, instr, i_ok, clock);
parameter memsize = 8192; // Number of bytes in memory
input [63:0] maddr; // Read/Write address
input wenable; // Write enable
input [63:0] wdata; // Write data
input renable; // Read enable
output [63:0] rdata; // Read data
output m_ok; // Read & write addresses within range
input [63:0] iaddr; // Instruction address
output [79:0] instr; // 10 bytes of instruction
output i_ok; // Instruction address within range
input clock;
endmodule


// This module implements a dual-ported RAM.
// with clocked write and combinational read operations.
// This version matches the conceptual model presented in the CS:APP book,

module ram(clock, addrA, wEnA, wDatA, rEnA, rDatA,
addrB, wEnB, wDatB, rEnB, rDatB);

parameter wordsize = 8; // Number of bits per word
parameter wordcount = 512; // Number of words in memory
 // Number of address bits. Must be >= log wordcount
 parameter addrsize = 9;

 input clock; // Clock
 // Port A
 input [addrsize-1:0] addrA; // Read/write address
 input wEnA; // Write enable
 input [wordsize-1:0] wDatA; // Write data
 input rEnA; // Read enable
 output [wordsize-1:0] rDatA; // Read data
 // Port B
 input [addrsize-1:0] addrB; // Read/write address
 input wEnB; // Write enable
 input [wordsize-1:0] wDatB; // Write data
 input rEnB; // Read enable
 output [wordsize-1:0] rDatB; // Read data

 // Actual storage
 reg [wordsize-1:0] mem[wordcount-1:0];

 always @(posedge clock)
 begin
 if (wEnA)
 begin
 mem[addrA] <= wDatA;
 end
 end
 // Combinational reads
 assign rDatA = mem[addrA];

 always @(posedge clock)
  begin
 if (wEnB)
 begin
 mem[addrB] <= wDatB;
 end
 end
 // Combinational reads
 assign rDatB = mem[addrB];

 endmodule
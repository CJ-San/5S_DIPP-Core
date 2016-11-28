///////////////////////////////////////////////////////////////////
// I-type Opcode Parameters
///////////////////////////////////////////////////////////////////

//;my $addi = parameter(Name=>"addi", Val=>8);
//;my $andi = parameter(Name=>"andi", Val=>12);
//;my $beq  = parameter(Name=>"beq",  Val=>4);
//;my $bgtz = parameter(Name=>"bgtz", Val=>7);
//;my $bne  = parameter(Name=>"bne",  Val=>5);
//;my $lw   = parameter(Name=>"lw",   Val=>35);
//;my $ori  = parameter(Name=>"ori",  Val=>13);
//;my $slti = parameter(Name=>"slti", Val=>10);
//;my $sw   = parameter(Name=>"sw",   Val=>43);
//;my $xori = parameter(Name=>"xori", Val=>14);

/////////////////////////////////////////////////////////////////////
// R-type Parameters
/////////////////////////////////////////////////////////////////////
  
//my $R_type   = parameter(Name=>"R_type", Val=>0);

//;my $add   = parameter(Name=>"add", Val=>32);
//;my $and   = parameter(Name=>"and", Val=>36);
//;my $jr    = parameter(Name=>"jr",  Val=>8);
//;my $sub   = parameter(Name=>"sub", Val=>34); 
//;my $sra   = parameter(Name=>"sra", Val=>3);
//;my $or    = parameter(Name=>"or",  Val=>37);
//;my $nor   = parameter(Name=>"nor", Val=>39);
//;my $slt   = parameter(Name=>"slt", Val=>42);
//;my $xor   = parameter(Name=>"xor", Val=>38);

/////////////////////////////////////////////////////////////////////
// J-type Opcode Parameter
/////////////////////////////////////////////////////////////////////

//;my $j = parameter(Name=>"j", Val=>2);

///////////////////////////////////////////////////////////////////
//  ctl.vp
//; 
//; use strict ;
//; use warnings FATAL=>qw(all);
//; use diagnostics ;
//; 
//
//

module `mname` (
        input logic [31:0] instr,

        output logic [1:0] jump_sel,
        output logic branch,
        output logic memRead,
        output logic mem_to_reg,
        output logic [5:0] ALUop,
        output logic memWrite,
        output logic ALUSrc,
        output logic RegWrite,
	output logic RegDST
		);

/////////////////////////////////////////
// Wire Definitions
/////////////////////////////////////////

logic [5:0]  opcode;
logic [5:0]  func;

assign opcode = instr[31:26];
assign func = instr[5:0];


always_comb begin
    unique casex ({opcode,func})
        {6'h0,6'd`$add`} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001000000011; //R-Type
        {6'h0,6'd`$and`} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001001000011;
        {6'h0,6'd`$jr` } : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b100000010000011;
        {6'h0,6'd`$sub`} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001000100011;
        {6'h0,6'd`$sra`} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000000000110011;
        {6'h0,6'd`$or` } : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001001010011;
        {6'h0,6'd`$nor`} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001001110011;
        {6'h0,6'd`$slt`} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001010100011;
        {6'h0,6'd`$xor`} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001001100011;

        {6'd`$addi`,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001000000110; //I-Type
        {6'd`$andi`,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001001000110;
        {6'd`$beq` ,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b001000000000000;
        {6'd`$bgtz`,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b001000000000100;
        {6'd`$bne` ,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b001000000000000;
        {6'd`$lw`  ,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000110000000110;
        {6'd`$ori` ,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001001010110;
        {6'd`$slti`,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001010100110;
        {6'd`$sw`  ,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001000001100;
        {6'd`$xori`,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b000001001100110;

        {6'd`$j`   ,6'b??????} : {jump_sel, branch, memRead, mem_to_reg, ALUop, memWrite, ALUSrc, RegWrite, RegDST} = 15'b010000000000000; //J-Type
    endcase
end
endmodule: `mname`

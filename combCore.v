// combCore.vp
//; my $bW = parameter( name=>"bitWidth", val=>32, doc=>"Width of input");
module `mname` (
	input  logic [`$bW-1`:0] instr,
	input  logic [`$bW-1`:0] pc,
	input  logic [`$bW-1`:0] src0,
	input  logic [`$bW-1`:0] src1,
	input  logic [`$bW-1`:0] memRdData,
	output logic [`$bW-1`:0] memRdAddr,
	output logic             memRdEn,
	output logic [`$bW-1`:0] memWrData ,
	output logic [`$bW-1`:0] memWrAddr,
	output logic             memWrEn ,
	output logic [`$bW-1`:0] dst0,
	output logic [`$bW-1`:0] pcNxt
);

 	logic [`$bW-1`:0]     instr_se;
 	logic [`$bW-5`:0]     instr_jump;
 	logic [`$bW-1`:0]     instr_se_sl2;
 	logic [`$bW-1`:0]     pc_4;
 	logic [`$bW-1`:0]     pc_jr;
 	logic [`$bW-1`:0]     pc_jump, pc_branch;
 	logic [`$bW-1`:0]     pc_nxt0;
 	logic [`$bW-1`:0]     alusrc1;
 	logic [`$bW-1`:0]     ALUout;
 	logic                 ALUSrc;
 	logic [1:0]           jump_sel;
 	logic                 branch_en;
 	logic                 branch;
 	logic                 RegDST;
 	logic [4:0]           RegDST_out;
 	logic                 memRead;
 	logic                 mem_to_reg;
 	logic                 memWrite;
 	logic                 RegWrite;
 	logic [5:0]           ALUop;
	logic [5:0]           opcode;


////////////////////////////////////
// D Instatiations 
////////////////////////////////////

//; my $ALU    = generate( 'ALU', 'my_ALU');
//; my $ctl    = generate( 'ctl', 'my_ctl');

//; my $iFlop    = generate( "dff", "d_I",    Width=>[($bW)]);
//; my $pFlop    = generate( "dff", "d_P",    Width=>[($bW)]);
//; my $s0Flop   = generate( "dff", "d_S0",   Width=>[($bW)]);
//; my $s1Flop   = generate( "dff", "d_S1",   Width=>[($bW)]);
//; my $mFlop    = generate( "dff", "d_M",    Width=>[($bW)]);
//; my $mraFlop  = generate( "dff", "d_MRA",  Width=>[($bW)]);
//; my $mreFlop  = generate( "dff", "d_MRE",  Width=>[($bW)]);
//; my $mwdFlop  = generate( "dff", "d_MWD",  Width=>[($bW)]);
//; my $mwaFlop  = generate( "dff", "d_MWA",  Width=>[($bW)]);
//; my $mweFlop  = generate( "dff", "d_MWE",  Width=>[($bW)]);
//; my $dFlop    = generate( "dff", "d_D",    Width=>[($bW)]);
//; my $pnlop    = generate( "dff", "d_PN",   Width=>[($bW)]);

`$ALU->instantiate()`  ( .a(src0), .b(alusrc1), .branchop(opcode),.ALUctrl(ALUop),.branch_en(branch_en),.z(ALUout) );
`$ctl->instantiate()`  ( .instr(instr), .jump_sel(jump_sel), .branch(branch), .memRead(memRead), .mem_to_reg(mem_to_reg), .ALUop(ALUop), .memWrite(memWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .RegDST(RegDST) );
//`$iFlop->instantiate()`  ( .din(instr),    .clk, .rst, .q(instr_tmp));
//`$pFlop->instantiate()`  ( .din(pc),       .clk, .rst, .q(pc_tmp)   );
//`$s0Flop->instantiate()` ( .din(src0),     .clk, .rst, .q(src0_tmp) );
//`$s1Flop->instantiate()` ( .din(src1),     .clk, .rst, .q(src1_tmp) );
//`$mFlop->instantiate()`  ( .din(memRdData),.clk, .rst, .q(MRD_tmp)  );
//`$mraFlop->instantiate()`( .din(ALUout),   .clk, .rst, .q(memRdAddr));  
//`$mreFlop->instantiate()`( .din(memRead),  .clk, .rst, .q(memRdEn)  ); 
//`$mwdFlop->instantiate()`( .din(src1_tmp), .clk, .rst, .q(memWrData)); 
//`$mwaFlop->instantiate()`( .din(ALUout),   .clk, .rst, .q(memWrAddr)); 
//`$mweFlop->instantiate()`( .din(memWrite), .clk, .rst, .q(memWrEn)  ); 
//`$dFlop  ->instantiate()`( .din(dst0_nxt), .clk, .rst, .q(dst0)     ); 
//`$pFlop  ->instantiate()`( .din(pc_nxt1),  .clk, .rst, .q(pcNxt)    ); 

////////////////////////////////////
// Signal Assignments 
////////////////////////////////////
assign instr_se = {`$bW/2`'d0, instr[`$bW/2-1`:0]};
assign instr_jump = instr[25:0] << 2;//logic needed
assign opcode = instr[31:26];

////////////////////////////////////
// Muxes 
////////////////////////////////////
assign RegDST_out = RegDST ? instr[15:11] : instr[20:16];
assign alusrc1 = ALUSrc ? instr_se : src1;
assign branch_sel = branch && branch_en;
assign pc_nxt0 = branch_sel ? pc_branch : pc_4;
assign dst0 = mem_to_reg ? memRdData : ALUout;
assign pc_jr = src0;

////////////////////////////////////
// PC NXT
////////////////////////////////////
always_comb begin
	unique case (jump_sel)
	2'b00 : pcNxt = pc_nxt0;
	2'b01 : pcNxt = pc_jump;
        2'b10 : pcNxt = pc_jr;
	endcase
end

////////////////////////////////////
// Combinatorial logic 
////////////////////////////////////

assign pc_4 = pc + 4;
assign instr_se_sl2 = instr_se << 2;
assign pc_branch = instr_se_sl2 + pc_4;
assign pc_jump = {pc_4[31:28],instr_jump};
assign memRdAddr = ALUout;
assign memWrAddr = ALUout;
assign memRdEn = memRead;
assign memWrData = src1;
assign memWrEn = memWrite;


endmodule: `mname`

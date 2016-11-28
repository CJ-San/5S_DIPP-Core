// mipsCore.vp

//; my $wl = parameter( name=>"wordLength", val=>32, doc=>"Width of input" );
//; my $iW = parameter( name=>"issueWidth", val=>1, doc=>"Number of fetched instructions" );
//; my $rP = parameter( name=>"rfReadPorts", val=>2, doc=>"Number of RF read ports" );
//; my $wP = parameter( name=>"rfWritePorts", val=>1, doc=>"Number of RF write ports" );
//; my $rC = parameter( name=>"rfEntryCount", val=>32, max=>128, doc=>"Number of RF addresses");
//; my $rA = parameter( name=>"rfAddressWidth", val=>5, max=>7 , doc=>"Bits for RF address" );
//; my $btb = parameter( name=>"enableBTB", val=>0, list=>[0,1], doc=>"Enable BTB");
//; my $btbW = parameter( name=>"entrySizeBTB", val=>34, max=>36, doc=>"BTB entry size");
//; my $btbC = parameter( name=>"entryCountBTB", val=>0, max=>256, doc=>"BTB entries");
//; my $mD = parameter( name=>"MipsMode", val=>"Cyc1",list=>["Cyc1","Cyc5","Smpl5","Fwd5","Dual"],doc=>"Iterative design state, testbench will ignore" );

module `mname` (

	//ICache Ifc
	input logic [`$iW*$wl-1`:0] iCacheReadData,
	output logic [`$wl-1`:0] iCacheReadAddr,

	//DCache Ifc
	input logic [`$wl-1`:0] dCacheReadData,
	output logic [`$wl-1`:0] dCacheWriteData,
	output logic [`$wl-1`:0] dCacheAddr,
	output logic dCacheWriteEn,
	output logic dCacheReadEn,

	//Register File Ifc
	//; for( my $i = 0 ; $i < $rP ; $i++ ){
	input logic [`$wl-1`:0] rfReadData_p`$i`,
	output logic [`$rA-1`:0] rfReadAddr_p`$i`,
	output logic rfReadEn_p`$i`,
	//; }
	//; for( my $i = 0 ; $i < $wP ; $i++ ){
	output logic [`$wl-1`:0] rfWriteData_p`$i`,
	output logic [`$rA-1`:0] rfWriteAddr_p`$i`,
	output logic rfWriteEn_p`$i`,
	//; }

	//BTB Ifc
	//; if( $btb ){
	input logic [`$btbW-1`:0] btbReadData,
	output logic [`$btbW-1`:0] btbWriteData,
	output logic [`$wl-1`:0] btbWriteAddr,
	output logic [`$wl-1`:0] btbReadAddr,
	output logic btbWriteEn,
	output logic btbReadEn,
	//; }

	// Globals
	input logic clk,
	input logic rst
	);

/////////////////////////////////////////////////////////////////
//WIRE DEFINITIONS
/////////////////////////////////////////////////////////////////

//IF
logic [`$wl-1`:0]     pc_IF;
logic [`$wl-1`:0]     pc_4_IF;
logic [`$wl-1`:0]     pc_nxt0;
logic [`$wl-1`:0]     pcNxt;
logic [`$wl-1`:0]     pc_jr; //TOP
logic [`$wl-1`:0]     pc_jump; //TOP
logic [`$iW*$wl-1`:0] instr_IF;
//ID
logic [1:0]           jump_sel_ID;
logic [`$wl-1`:0]     pc_4_ID; 
logic [`$wl-5`:0]     instr_jump; //$iw*$wl? 
logic [`$wl-1`:0]     instr_se_ID;//$iw*$wl? 
logic [`$wl-1`:0]     src0_ID; 
logic [`$wl-1`:0]     src1_ID; 
logic [`$iW*$wl-1`:0] instr_ID;
logic                 branch_ID; 
logic                 memRead_ID; 
logic                 mem_to_reg_ID; 
logic [5:0]           ALUop_ID; 
logic                 memWrite_ID; 
logic                 ALUSrc_ID; 
logic                 RegWrite_ID; 
logic                 RegDST_ID; 
//EX
logic [`$wl-1`:0]     pc_4_EX; 
logic [`$wl-1`:0]     pc_branch_EX; 
logic [`$wl-1`:0]     instr_se_EX;//$iw*$wl? 
logic [`$wl-1`:0]     ALUsrc1_EX;//$iw*$wl? 
logic [`$wl-1`:0]     src0_EX; 
logic [`$wl-1`:0]     src1_EX; 
logic [`$iW*$wl-1`:0] instr_EX;
logic                 branch_EX; 
logic                 memRead_EX; 
logic                 mem_to_reg_EX; 
logic [5:0]           ALUop_EX; 
logic                 memWrite_EX; 
logic                 ALUSrc_EX; 
logic                 RegWrite_EX; 
logic                 RegDST_EX; 
logic                 branch_en_EX; 
logic [`$wl-1`:0]     ALUout_EX; 
logic [`$wl-1`:0]     instr_se_sl2_EX; 
logic [`$rA-1`:0]     WriteAddr_EX; 
//MEM
logic [`$wl-1`:0]     pc_branch_MEM; 
logic [`$wl-1`:0]     src1_MEM; 
logic                 branch_MEM; 
logic                 memRead_MEM; 
logic                 mem_to_reg_MEM; 
logic                 memWrite_MEM; 
logic                 RegWrite_MEM; 
logic                 branch_en_MEM; 
logic                 branch_sel_MEM; 
logic [`$wl-1`:0]     ALUout_MEM; 
logic [`$wl-1`:0]     dCacheReadData_MEM; 
logic [`$rA-1`:0]     WriteAddr_MEM;
//WB
logic                 mem_to_reg_WB; 
logic                 RegWrite_WB; 
logic [`$wl-1`:0]     ALUout_WB; 
logic [`$rA-1`:0]     WriteAddr_WB;
logic [`$wl-1`:0]     dCacheReadData_WB; 
logic [`$wl-1`:0]     WriteData_WB; 

/////////////////////////////////////////////////////////////////
//IF 
/////////////////////////////////////////////////////////////////

//Instances

//; my $pcFlop    = generate( "dff", "d_PC",    Width=>[($wl)]);
`$pcFlop  ->instantiate()`( .din(pcNxt),  .clk, .rst, .q(pc_IF));

//Logic
assign pc_4_IF        = pc_IF + 4;

//Branch Mux
assign pc_nxt0        = branch_sel_MEM ? pc_branch_MEM : pc_4_IF; 

//I$ I/O
assign instr_IF       = iCacheReadData;
assign iCacheReadAddr = pc_IF;

//Jump Mux 
always_comb begin                   
	unique case (jump_sel_ID)
	2'b00 : pcNxt = pc_nxt0;
	2'b01 : pcNxt = pc_jump;
        2'b10 : pcNxt = pc_jr;
	endcase
end

/////////////////////////////////////////////////////////////////
//IF / ID Flops 
/////////////////////////////////////////////////////////////////

//; my $if_id_0Flop    = generate( "dff", "d_IF_ID_0",    Width=>[($iW*$wl)]);
//; my $if_id_1Flop    = generate( "dff", "d_IF_ID_1",    Width=>[($wl)]    );
`$if_id_0Flop->instantiate()`  ( .din(instr_IF), .clk, .rst, .q(instr_ID));
`$if_id_1Flop->instantiate()`  ( .din(pc_4_IF) , .clk, .rst, .q(pc_4_ID) );

/////////////////////////////////////////////////////////////////
//ID 
/////////////////////////////////////////////////////////////////

//Instances

//; my $ctl    = generate( 'ctl', 'my_ctl');
`$ctl->instantiate()`  ( .instr(instr_ID), .jump_sel(jump_sel_ID), .branch(branch_ID), .memRead(memRead_ID), .mem_to_reg(mem_to_reg_ID), .ALUop(ALUop_ID), .memWrite(memWrite_ID), .ALUSrc(ALUSrc_ID), .RegWrite(RegWrite_ID), .RegDST(RegDST_ID) );

//logic 
assign instr_jump = instr_ID[25:0] << 2;
assign pc_jump = {pc_4_ID[31:28],instr_jump};
assign instr_se_ID = {`$wl/2`'d0, instr_ID[`$wl/2-1`:0]};
assign pc_jr = src0_ID;

//RF I/O
assign src0_ID = rfReadData_p0;
assign src1_ID = rfReadData_p1;
assign rfReadAddr_p0 = instr_ID[25:21];
assign rfReadAddr_p1 = instr_ID[20:16];
assign rfReadEn_p0   =  1'b1;//FOR NOW ......
assign rfReadEn_p1   =  1'b1;//FOR NOW ......
assign rfWriteData_p0 = WriteData_WB;
assign rfWriteAddr_p0 = WriteAddr_WB;
assign rfWriteEn_p0   = RegWrite_WB;

/////////////////////////////////////////////////////////////////
//ID / EX Flops 
/////////////////////////////////////////////////////////////////
//; my $id_ex_0Flop    = generate( "dff", "d_ID_EX_0",   Width=>[($wl)]    );
//; my $id_ex_1Flop    = generate( "dff", "d_ID_EX_1",   Width=>[($iW)]    );
//; my $id_ex_2Flop    = generate( "dff", "d_ID_EX_2",   Width=>[($iW)]    );
//; my $id_ex_3Flop    = generate( "dff", "d_ID_EX_3",   Width=>[($iW)]    );
//; my $id_ex_4Flop    = generate( "dff", "d_ID_EX_4",   Width=>[(6  )]    );
//; my $id_ex_5Flop    = generate( "dff", "d_ID_EX_5",   Width=>[($iW)]    );
//; my $id_ex_6Flop    = generate( "dff", "d_ID_EX_6",   Width=>[($iW)]    );
//; my $id_ex_7Flop    = generate( "dff", "d_ID_EX_7",   Width=>[($iW)]    );
//; my $id_ex_8Flop    = generate( "dff", "d_ID_EX_8",   Width=>[($iW)]    );
//; my $id_ex_9Flop    = generate( "dff", "d_ID_EX_9",   Width=>[($wl)]    );
//; my $id_ex_10Flop   = generate( "dff", "d_ID_EX_10",  Width=>[($wl)]    );
//; my $id_ex_11Flop   = generate( "dff", "d_ID_EX_11",  Width=>[($iW*$wl)]);
//; my $id_ex_12Flop   = generate( "dff", "d_ID_EX_12",  Width=>[($wl)]    );
`$id_ex_0Flop->instantiate()`  ( .din(instr_se_ID)   , .clk, .rst, .q(instr_se_EX)  );
`$id_ex_1Flop->instantiate()`  ( .din(branch_ID)     , .clk, .rst, .q(branch_EX)    );
`$id_ex_2Flop->instantiate()`  ( .din(memRead_ID)    , .clk, .rst, .q(memRead_EX)   );
`$id_ex_3Flop->instantiate()`  ( .din(mem_to_reg_ID) , .clk, .rst, .q(mem_to_reg_EX));
`$id_ex_4Flop->instantiate()`  ( .din(ALUop_ID)      , .clk, .rst, .q(ALUop_EX)     );
`$id_ex_5Flop->instantiate()`  ( .din(memWrite_ID)   , .clk, .rst, .q(memWrite_EX)  );
`$id_ex_6Flop->instantiate()`  ( .din(ALUSrc_ID)     , .clk, .rst, .q(ALUSrc_EX)    );
`$id_ex_7Flop->instantiate()`  ( .din(RegWrite_ID)   , .clk, .rst, .q(RegWrite_EX)  );
`$id_ex_8Flop->instantiate()`  ( .din(RegDST_ID)     , .clk, .rst, .q(RegDST_EX)    );
`$id_ex_9Flop->instantiate()`  ( .din(src0_ID)       , .clk, .rst, .q(src0_EX)      );
`$id_ex_10Flop->instantiate()` ( .din(src1_ID)       , .clk, .rst, .q(src1_EX)      );
`$id_ex_11Flop->instantiate()` ( .din(instr_ID)      , .clk, .rst, .q(instr_EX)     );
`$id_ex_12Flop->instantiate()` ( .din(pc_4_ID)       , .clk, .rst, .q(pc_4_EX)      );

///////////////////////////////////////////////////////////////////
// EX
///////////////////////////////////////////////////////////////////

//instances
//; my $ALU    = generate( 'ALU', 'my_ALU');
`$ALU->instantiate()`  ( .a(src0_EX), .b(ALUsrc1_EX), .branchop(instr_EX[31:26]),.ALUctrl(ALUop_EX),.branch_en(branch_en_EX),.z(ALUout_EX) );

//Logic 
assign instr_se_sl2_EX = instr_se_EX << 2;
assign pc_branch_EX = instr_se_sl2_EX + pc_4_EX;

//Muxes
assign ALUsrc1_EX    = ALUSrc_EX ? instr_se_EX : src1_EX;
assign WriteAddr_EX  = RegDST_EX ? instr_EX[15:11] : instr_EX[20:16];

/////////////////////////////////////////////////////////////////
//EX / MEM Flops 
/////////////////////////////////////////////////////////////////
//; my $ex_mem_0Flop    = generate( "dff", "d_EX_MEM_0",    Width=>[($wl)]);
//; my $ex_mem_1Flop    = generate( "dff", "d_EX_MEM_1",    Width=>[($iW)]);
//; my $ex_mem_2Flop    = generate( "dff", "d_EX_MEM_2",    Width=>[($iW)]);
//; my $ex_mem_3Flop    = generate( "dff", "d_EX_MEM_3",    Width=>[($iW)]);
//; my $ex_mem_4Flop    = generate( "dff", "d_EX_MEM_4",    Width=>[($iW)]);
//; my $ex_mem_5Flop    = generate( "dff", "d_EX_MEM_5",    Width=>[($iW)]);
//; my $ex_mem_6Flop    = generate( "dff", "d_EX_MEM_6",    Width=>[($wl)]);
//; my $ex_mem_7Flop    = generate( "dff", "d_EX_MEM_7",    Width=>[($iW)]);
//; my $ex_mem_8Flop    = generate( "dff", "d_EX_MEM_8",    Width=>[($rA)]);
//; my $ex_mem_9Flop    = generate( "dff", "d_EX_MEM_9",    Width=>[($wl)]);
`$ex_mem_0Flop->instantiate()`  ( .din(pc_branch_EX)  , .clk, .rst, .q(pc_branch_MEM) );
`$ex_mem_1Flop->instantiate()`  ( .din(branch_EX)     , .clk, .rst, .q(branch_MEM)    );
`$ex_mem_2Flop->instantiate()`  ( .din(memRead_EX)    , .clk, .rst, .q(memRead_MEM)   );
`$ex_mem_3Flop->instantiate()`  ( .din(mem_to_reg_EX) , .clk, .rst, .q(mem_to_reg_MEM));
`$ex_mem_4Flop->instantiate()`  ( .din(branch_en_EX)  , .clk, .rst, .q(branch_en_MEM) );
`$ex_mem_5Flop->instantiate()`  ( .din(memWrite_EX)   , .clk, .rst, .q(memWrite_MEM)  );
`$ex_mem_6Flop->instantiate()`  ( .din(ALUout_EX)     , .clk, .rst, .q(ALUout_MEM)    );
`$ex_mem_7Flop->instantiate()`  ( .din(RegWrite_EX)   , .clk, .rst, .q(RegWrite_MEM)  );
`$ex_mem_8Flop->instantiate()`  ( .din(WriteAddr_EX)  , .clk, .rst, .q(WriteAddr_MEM) );
`$ex_mem_9Flop->instantiate()`  ( .din(src1_EX)       , .clk, .rst, .q(src1_MEM)      );

///////////////////////////////////////////////////////////////////
// MEM 
///////////////////////////////////////////////////////////////////

//Logic
assign branch_sel_MEM = branch_MEM && branch_en_MEM;

//D$ I/O
assign dCacheReadData_MEM  = dCacheReadData;
assign dCacheWriteData     = src1_MEM;
assign dCacheAddr          = ALUout_MEM;
assign dCacheReadEn        = memRead_MEM;
assign dCacheWriteEn       = memWrite_MEM;

/////////////////////////////////////////////////////////////////
//MEM / WB Flops 
/////////////////////////////////////////////////////////////////
//; my $mem_wb_0Flop    = generate( "dff", "d_MEM_WB_0",    Width=>[($wl)]);
//; my $mem_wb_1Flop    = generate( "dff", "d_MEM_WB_1",    Width=>[($iW)]);
//; my $mem_wb_2Flop    = generate( "dff", "d_MEM_WB_2",    Width=>[($wl)]);
//; my $mem_wb_3Flop    = generate( "dff", "d_MEM_WB_3",    Width=>[($iW)]);
//; my $mem_wb_4Flop    = generate( "dff", "d_MEM_WB_4",    Width=>[($rA)]);
`$mem_wb_0Flop->instantiate()`  ( .din(dCacheReadData_MEM)  , .clk, .rst, .q(dCacheReadData_WB) );
`$mem_wb_1Flop->instantiate()`  ( .din(mem_to_reg_MEM)      , .clk, .rst, .q(mem_to_reg_WB)     );
`$mem_wb_2Flop->instantiate()`  ( .din(ALUout_MEM)          , .clk, .rst, .q(ALUout_WB)         );
`$mem_wb_3Flop->instantiate()`  ( .din(RegWrite_MEM)        , .clk, .rst, .q(RegWrite_WB)       );
`$mem_wb_4Flop->instantiate()`  ( .din(WriteAddr_MEM)       , .clk, .rst, .q(WriteAddr_WB)      );

///////////////////////////////////////////////////////////////////
// MEM 
///////////////////////////////////////////////////////////////////

//Mux
assign WriteData_WB = mem_to_reg_WB ? dCacheReadData_WB : ALUout_WB;


endmodule: `mname`


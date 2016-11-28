//////////////////////////////////////////////////////////
// top_mipsCore.vp
//; use strict ;
//; use warnings FATAL=>qw(all);
//; use diagnostics ;
// A top module has no inputs or outputs

module `mname` ();

//; #Instantiating a module in gen2 requires an extra
//; # step where we generate the module, then instance it

//; my $hw = generate_base('mipsCore', 'my_mipsCore');

//; # We can querry the value of parameters

//; my $wl = parameter( name=>"wordLength", val=>32, doc=>"Width of input" );
//; my $bW = parameter( name=>"bitWidth", val=>32, doc=>"Width of inputs" );
//; my $iW = parameter( name=>"issueWidth", val=>1, doc=>"Number of fetched instructions" );
//; my $rP = parameter( name=>"rfReadPorts", val=>2, doc=>"Number of RF read ports" );
//; my $wP = parameter( name=>"rfWritePorts", val=>1, doc=>"Number of RF write ports" );
//; my $rC = parameter( name=>"rfEntryCount", val=>32, max=>128, doc=>"Number of RF addresses");
//; my $rA = parameter( name=>"rfAddressWidth", val=>5, max=>7 , doc=>"Bits for RF address" );
//; my $btb = parameter( name=>"enableBTB", val=>0, list=>[0,1], doc=>"Enable BTB");
//; my $btbW = parameter( name=>"entrySizeBTB", val=>34, max=>36, doc=>"BTB entry size");
//; my $btbC = parameter( name=>"entryCountBTB", val=>0, max=>256, doc=>"BTB entries");
//; my $mD = parameter( name=>"MipsMode", val=>"Cyc1",list=>["Cyc1","Cyc5","Smpl5","Fwd5","Dual"],doc=>"Iterative design state, testbench will ignore" );

	//ICache Ifc
	logic [`$iW*$wl-1`:0] iCacheReadData;
	logic [`$wl-1`:0] iCacheReadAddr;

	//DCache Ifc
	logic [`$wl-1`:0] dCacheReadData;
	logic [`$wl-1`:0] dCacheWriteData;
	logic [`$wl-1`:0] dCacheAddr;
	logic dCacheWriteEn;
	logic dCacheReadEn;

	//Register File Ifc
	//; for( my $i = 0 ; $i < $rP ; $i++ ){
	logic [`$wl-1`:0] rfReadData_p`$i`;
	logic [`$rA-1`:0] rfReadAddr_p`$i`;
	logic rfReadEn_p`$i`;
	//; }
	//; for( my $i = 0 ; $i < $wP ; $i++ ){
	 logic [`$wl-1`:0] rfWriteData_p`$i`;
	 logic [`$rA-1`:0] rfWriteAddr_p`$i`;
	 logic rfWriteEn_p`$i`;
	//; }

	//BTB Ifc
	//; if( $btb ){
	logic [`$btbW-1`:0] btbReadData;
	logic [`$btbW-1`:0] btbWriteData;
	logic [`$wl-1`:0] btbWriteAddr;
	logic [`$wl-1`:0] btbReadAddr;
	logic btbWriteEn;
	logic btbReadEn;
	//; }

	// Globals
	logic clk;
	logic rst;

// # Then we can instantiate our DUT

`$hw->instantiate` (.iCacheReadData(iCacheReadData),.iCacheReadAddr(iCacheReadAddr),.dCacheReadData(dCacheReadData),.dCacheWriteData(dCacheWriteData),.dCacheAddr(dCacheAddr),.dCacheWriteEn(dCacheWriteEn),.dCacheReadEn(dCacheReadEn),.rfReadData_p0(rfReadData_p0),.rfReadData_p1(rfReadData_p1),.rfReadAddr_p0(rfReadAddr_p0),.rfReadAddr_p1(rfReadAddr_p1),.rfReadEn_p0(rfReadEn_p0),.rfReadEn_p1(rfReadEn_p1),.clk(clk),.rst(rst),.rfWriteData_p0(rfWriteData_p0),.rfWriteAddr_p0(rfWriteAddr_p0),.rfWriteEn_p0(rfWriteEn_p0));

//; my $icache    = generate( 'icache', 'my_icache');
`$icache->instantiate()`  ( .iCacheReadAddr(iCacheReadAddr), .iCacheReadData(iCacheReadData));

//; my $dcache    = generate( 'dcache', 'my_dcache');
`$dcache->instantiate()`  ( .clk(clk), .dCacheWriteData(dCacheWriteData), .dCacheAddr(dCacheAddr), .dCacheReadData(dCacheReadData), .dCacheWriteEn(dCacheWriteEn), .dCacheReadEn(dCacheReadEn));

//; my $rf    = generate( 'rf', 'my_rf');
`$rf->instantiate()`  ( .rfReadData_p0(rfReadData_p0),.rfReadData_p1(rfReadData_p1),.rfReadAddr_p0(rfReadAddr_p0),.rfReadAddr_p1(rfReadAddr_p1),.rfReadEn_p0(rfReadEn_p0),.rfReadEn_p1(rfReadEn_p1),.clk(clk),.rfWriteData_p0(rfWriteData_p0),.rfWriteAddr_p0(rfWriteAddr_p0),.rfWriteEn_p0(rfWriteEn_p0));

//stimulus

initial begin
	clk = 0;
        rst = 1;

//RT type instruction 
//-------------------------OPCODE---RS------RT-----RD------shamt---funct-
//my_icache.Icache[0]= 32'b000000   00000   00000  00000   00000   000000

//I type instruction 
//-------------------------OPCODE---RS------RT-----immediate-------
//my_icache.Icache[0]= 32'b000000   00000   00000  0000000000000000

//J type instruction 
//------------------------OPCODE---address-------------------
//myicache.Icache[0]= 32'b000000   00000000000000000000000000

//SW instruction
        my_icache.Icache[0]  = 32'b00100000000010000000000000000101;
        my_icache.Icache[20] = 32'b00100001000000110000000000001100;
        my_icache.Icache[40] = 32'b00000001000000110010100000100000;
        my_icache.Icache[60] = 32'b10101101000001010000000000001111;
//end SW 
        #1 
	rst = 0;
        #1
        rst = 1;
end

always 
	#5 clk = !clk;
initial
#200 $finish;


   
////Operation ADD = A + B
//   instr = `$bW`'b00000010001100100100000000100000;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d9;
//   src1 = `$bW`'d17;
//   memRdData = `$bW`'d20;
//   #2  
////Operation ADDi = A + immidiate
//   instr = `$bW`'b00100001001010000000000000000101;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d9;
//   src1 = `$bW`'d8;
//   memRdData = `$bW`'d20;
//   #2  
////Operation AND = A & B
//   instr = `$bW`'b00000010001100100100000000100100;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d99;
//   src1 = `$bW`'d107;
//   memRdData = `$bW`'d20;
//   #2  
////Operation jump 
//   instr = `$bW`'b00001000000000000000000000011110;
//   pc = `$bW`'h20000000;
//   src0 = `$bW`'d9;
//   src1 = `$bW`'d8;
//   memRdData = `$bW`'d20;
//#2
////Operation beq true
//   instr = `$bW`'h1040000A;
//   pc = `$bW`'h9D000088;
//   src0 = `$bW`'d0;
//   src1 = `$bW`'d0;
//   memRdData = `$bW`'d20;
//   triggerStop = 1'b1;
//   #10
//#2
////Operation beq false 
//   instr = `$bW`'h1040000A;
//   pc = `$bW`'h9D000088;
//   src0 = `$bW`'d0;
//   src1 = `$bW`'d1;
//   memRdData = `$bW`'d20;
//   triggerStop = 1'b1;
//   #10
////Operation bne true
//   instr = `$bW`'h1440000A;
//   pc = `$bW`'h9D000088;
//   src0 = `$bW`'d0;
//   src1 = `$bW`'d1;
//   memRdData = `$bW`'d20;
//   triggerStop = 1'b1;
//   #10
////Operation bne false
//   instr = `$bW`'h1440000A;
//   pc = `$bW`'h9D000088;
//   src0 = `$bW`'d0;
//   src1 = `$bW`'d0;
//   memRdData = `$bW`'d20;
//   triggerStop = 1'b1;
//   #10
//
////Operation SUB = A - B
//   instr = `$bW`'h014b6822;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d8;
//   src1 = `$bW`'d6;
//   memRdData = `$bW`'d20;
//   #2  
////Operation OR = A | B
//   instr = `$bW`'h14b6825;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d8;
//   src1 = `$bW`'d6;
//   memRdData = `$bW`'d20;
//   #2  
////Operation sra = 4 >> 2;
//   instr = `$bW`'h000a5883;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d16;
//   src1 = `$bW`'d2;
//   memRdData = `$bW`'d20;
//   #2  
////Operation sra = 7 >> 3;
//   instr = `$bW`'h000a5883;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d7;
//   src1 = `$bW`'d2;
//   memRdData = `$bW`'d20;
//   #2  
////Operation NOR = 10 NOR ZERO;
//   instr = `$bW`'h01405827;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d10;
//   src1 = `$bW`'d0;
//   memRdData = `$bW`'d20;
//   #2  
////Operation SLT = 10 < 5;
//   instr = `$bW`'h014B482A;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d10;
//   src1 = `$bW`'d5;
//   memRdData = `$bW`'d20;
//   #2  
////Operation SLT = 5 <10;
//   instr = `$bW`'h014B482A;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d5;
//   src1 = `$bW`'d10;
//   memRdData = `$bW`'d20;
//   #2  
////Operation XOR = 7 XOR 8;
//   instr = `$bW`'h01495826;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d6;
//   src1 = `$bW`'d10;
//   memRdData = `$bW`'d20;
//   #2  
////Operation Andi = 11 AND 6;
//   instr = `$bW`'h314B000B;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d6;
//   src1 = `$bW`'d0;
//   memRdData = `$bW`'d20;
//   #2 
////Operation BTGZ = TRUE;
//   instr = `$bW`'h1D400010;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d0;
//   src1 = `$bW`'d10;
//   memRdData = `$bW`'d20;
//   #2  
////Operation BGTZ = FALSE;
//   instr = `$bW`'h1D400010;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'ha0000000;
//   src1 = `$bW`'hfff11111;
//   memRdData = `$bW`'d20;
//   #2 
////Operation BGTZ = TRUE;
//   instr = `$bW`'h1D400010;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'h00000ae1;
//   src1 = `$bW`'hfff11111;
//   memRdData = `$bW`'d20;
//   #2
//   #2 
//
////Operation JR ----  
//   instr = `$bW`'h01200008;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d32;
//   src1 = `$bW`'hfff11111;
//   memRdData = `$bW`'d20;
//   #2
//
////Operation LW ----  
//   instr = `$bW`'h8C890004;
//   pc = `$bW`'h00000000;
//   src0 = `$bW`'d32;
//   src1 = `$bW`'hfff11111;
//   memRdData = `$bW`'d20;
//   #2

//; my $region2 = "my_mipsCore";
//Capture the waves 
initial begin
// if this is a "+wave" run, it must record all signals

   if ( $test$plusargs("wave") ) begin
       $display("%t: Starting Wave Capture",$time);
              // levels, instance
       $vcdpluson(0, `$region2` );
       $vcdplusmemon(0, `$region2` );
   end
end // initial begin

endmodule: `mname`

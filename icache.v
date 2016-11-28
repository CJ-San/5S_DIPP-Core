////////////////////////////////////////////////
//icache.vp
//my $wl = $var->get_param("wordLength");
//; my $wl = parameter( name=>"wordLength", val=>32, doc=>"Width of input" );
//; my $iW = parameter( name=>"issueWidth", val=>1, doc=>"Number of fetched instructions" );
module `mname` (
	input  logic [`$wl-1`:0]     iCacheReadAddr,
	output logic [`$iW*$wl-1`:0] iCacheReadData
		);

/////////////////////////////  
//I Cache
/////////////////////////////
//logic [3:0][7:0] Dcache [1023:0];
logic [31:0] Icache [1023:0];

assign iCacheReadData = Icache [iCacheReadAddr];

//RT type instruction 
//-----------------OPCODE---RS------RT-----RD------shamt---funct-
//Icache [0] = 32'b000000   00000   00000  00000   00000   000000

//I type instruction 
//-----------------OPCODE---RS------RT-----immediate-------
//Icache [0] = 32'b000000   00000   00000  0000000000000000

//J type instruction 
//-----------------OPCODE---address-------------------
//Icache [0] = 32'b000000   00000000000000000000000000

//SW instruction
//assign Icache [0] = 32'b00100000000010000000000000000101;
//assign Icache [20]= 32'b00100001000000110000000000001100;
//assign Icache [40]= 32'b00000001000000110010100000100000;
//assign Icache [60]= 32'b10101101000001010000000000001111;
//end SW

endmodule: `mname`

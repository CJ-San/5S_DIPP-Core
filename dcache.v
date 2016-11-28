///////////////////////////////////////////
//dcache.vp
//my $wl = $var->get_param("wordLength");
//; my $wl = parameter( name=>"wordLength", val=>32, doc=>"Width of input" );

module `mname` (
	input                    clk,
	input  logic [`$wl-1`:0] dCacheWriteData,
	input  logic [`$wl-1`:0] dCacheAddr,
	input  logic             dCacheWriteEn,
	input  logic             dCacheReadEn,
	output logic [`$wl-1`:0] dCacheReadData
	);

//Word Addressable Data array
/////////////////////////////  
//D Cache
/////////////////////////////
//logic [3:0][7:0] Dcache [1023:0];
logic [31:0] Dcache [1023:0];

always_ff @ (posedge clk) begin
   if(dCacheWriteEn)
      Dcache [dCacheAddr] = dCacheWriteData;
end

assign dCacheReadData = dCacheReadEn ? Dcache[dCacheAddr] : `$wl`'d0;
	
endmodule: `mname`

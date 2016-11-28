/////////////////////////////////
//rf.vp
//
//my $rP = $var->get_param("rfReadPorts");
//my $wl = $var1->get_param("wordLength");
//my $rA = $var2->get_param("rfAddressWidth");
//; my $rP = parameter( name=>"rfReadPorts", val=>2, doc=>"Number of RF read ports" );
//; my $wl = parameter( name=>"wordLength", val=>32, doc=>"Width of input" );
//; my $rA = parameter( name=>"rfAddressWidth", val=>5, max=>7 , doc=>"Bits for RF address" );

module `mname`(
	input                    clk,
	input  logic             rfReadEn_p0,
	input  logic             rfReadEn_p1,
	output logic [`$wl-1`:0] rfReadData_p0,
	output logic [`$wl-1`:0] rfReadData_p1,
	
	input  logic [`$rA-1`:0] rfReadAddr_p0,
	input  logic [`$rA-1`:0] rfReadAddr_p1,
	
	input  logic             rfWriteEn_p0,
	input  logic [`$wl-1`:0] rfWriteData_p0,
	input  logic [`$rA-1`:0] rfWriteAddr_p0
		);

/////////////////////////////////
//Register File
/////////////////////////////////
logic [31:0] RF [31:0];
 
always_ff @ (posedge clk) begin
   if((rfWriteEn_p0)&&(rfWriteAddr_p0!=`$rA`'d0))
      RF [rfWriteAddr_p0] = rfWriteData_p0;
   else 
	RF [0] = 32'd0;
end


assign rfReadData_p0 = rfReadEn_p0 ? RF[rfReadAddr_p0] : `$wl`'d0;
assign rfReadData_p1 = rfReadEn_p1 ? RF[rfReadAddr_p1] : `$wl`'d0;

//Test
//assign RF [17] = 32'd9;
//assign RF [18] = 32'd10;
endmodule: `mname`

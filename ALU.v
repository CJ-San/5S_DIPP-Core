// ALU.vp

//; # Good Habits
//; use strict ;                   # Use a strict interpretation
//; use warnings FATAL=>qw(all);   # Turn warnings into errors
//; use diagnostics ;              # Print helpful info, for errors

//; # Parameters
//; my $bW = parameter( name=>"bitWidth", val=>32 , doc=>"width of the input");
//; my $ctrl = parameter( name=>"ALUControl", val=>6, doc=>"Width of Control");

module `mname` (
	input logic [`$bW-1`:0] a,
	input logic [`$bW-1`:0] b,
	input logic [`$ctrl-1`:0] branchop,
	input logic [`$ctrl-1`:0] ALUctrl,
	output logic branch_en,
	output logic [`$bW-1`:0] z
		);

always_comb begin

	unique casex (ALUctrl)
	
        	`$ctrl`'h20 : z = a + b ;            //ADD  Function
		`$ctrl`'h22 : z = a - b ;            //SUB  Function
		`$ctrl`'h24 : z = a & b ;            //AND  Function
		`$ctrl`'h25 : z = a | b ;            //OR   Function
		`$ctrl`'h27 : z = ~(a | b) ;         //NOR  Function
		`$ctrl`'h26 : z = a ^ b ;            //XOR  Function
		`$ctrl`'h2A : z = (a<b) ? 1 : 0 ;    //SLT  Function
		`$ctrl`'h03 : z = a>>b;  	     //SRA  Function
		
	endcase
end

always_comb begin

	unique casex (branchop)
		6'h4 : branch_en = (a==b) ? 1 :0;
	//	6'h7 : branch_en = ($signed(a)>32'b0)  ? 1 :0; //b = 0
		6'h7 : branch_en = (a[`$bW-1`]||(a==`$bW-1`'d0)) ? 0 : 1; //b = 0
		6'h5 : branch_en = (a!=b) ? 1 :0;
endcase
end
endmodule: `mname`

/* BRAM module
   Input: clk, rw(read/write), indexReady
		  indexReady: this comes from the memory control unit when it's writing the indices in the memory slot
		  writePtr: from bram control unit
		  indices: from the memory unit output
		  
	Output: indexOut: each individual 16-bit index
*/
	
module bram(input logic clk, rw, indexReady,
	    input logic [1:0] writePtr,
	    input logic [63:0] indices,
	    output logic [15:0] indexOut
				//output logic [63:0] indices
);
integer size;
logic [63:0] data;
logic [15:0] ram;

always_ff @(posedge clk) begin
	if(indexReady) data <= indices;
end


always_ff @(posedge clk) begin
	if(rw) begin
		ram <= data[(writePtr*16)+:16];
	end
	else begin
		indexOut <= ram;	
	end
end

endmodule

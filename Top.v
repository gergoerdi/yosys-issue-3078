module Top(
           output [3:0] LED,
           inout [10:1] JA
           );

   wire [3:0]           ROWS = JA[10:7];  
   wire [3:0]           COLS = 4'b1101;
   
   assign LED = ROWS;
   assign JA[4:1] = COLS;   
   
endmodule

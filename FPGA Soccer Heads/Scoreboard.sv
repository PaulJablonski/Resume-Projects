module Scoreboard( // Functions as timekeeping / counter (actual scorekeeping done in colormapper and sent to fontrom)
    input logic clk25, reset,
    output logic [7:0] seconds,
    output logic [3:0] ones, tens, hundreds,
    output logic TimeOver
    );
    
    logic clk1;
    logic [24:0] counter = 0;
    parameter DIVISION_FACTOR = 25000000 / 2; // 25000000 before

    always_ff @(posedge clk25 or posedge reset) begin
        if (reset) begin
            // Reset the counter
            counter <= 0;
            // Reset time over
            TimeOver <= 1'b0;
        end else if (counter == DIVISION_FACTOR - 1) begin
            // Toggle the 1 Hz clock
            counter <= 0;
            clk1 <= ~clk1;
        end else begin
            // Increment the counter
            counter <= counter + 1;
        end
    end
    
    always_ff @(posedge clk1 or posedge reset) begin
        if (reset) begin
            seconds <= 8'd180; 
            ones <= 4'd0;
            tens <= 4'd8;
            hundreds <= 4'd1;
        end
        else if (seconds > 0) begin
            seconds <= seconds - 8'd1; 
            
            // Use for display of timer
            if (ones == 4'd0) begin 
                ones <= 4'd9;
                if (tens == 4'd0) begin
                    tens <= 4'd9;
                    hundreds <= 4'd0;
                end
                else begin
                    tens <= tens - 4'd1;
                end
            end
            else begin
            ones <= ones - 4'd1;
            end
        end
        else begin
            TimeOver <= 1'b1;
        end
    end
    
    
    
endmodule

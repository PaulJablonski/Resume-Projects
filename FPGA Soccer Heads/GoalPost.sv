module GoalPost(input logic Reset, frame_clk, LR,
                output logic [9:0] GoalX, GoalY, GoalSX, GoalSY
    );
    // For LR (1 / High = Right goal)
    parameter [9:0] X_Center=320;  // Center position on the X axis
    parameter [9:0] Y_Center=240;  // Center position on the Y axis
    parameter [9:0] X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Y_Max=460;     // Bottommost point on the Y axis
    
    
    always_ff @ (posedge frame_clk or posedge Reset) //make sure the frame clock is instantiated correctly
    begin: Post_Setup
        if (Reset)  // asynchronous Reset
        begin
            GoalSX <= 72; // Non radius based width and height
            GoalSY <= 128;
            if (LR == 0) begin
                GoalX <= X_Min;
                GoalY <= Y_Max;
            end
            else begin
                GoalX <= X_Max - GoalSX;
                GoalY <= Y_Max;
            end
        end
        
    end
endmodule

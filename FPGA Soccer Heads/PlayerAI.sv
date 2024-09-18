//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Zuofu Cheng   08-19-2023                               --
//    Fall 2023 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI Lab                                --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module playerAI ( input logic Reset, frame_clk, AllowInput,
			      input logic [9:0] BallX, BallY,
                  output logic [9:0]  PlayerX, PlayerY, PlayerSY, PlayerSX, XMotion,
                  output logic frame);
    
    logic [9:0] Player_X_Motion, Player_Y_Motion, count, gravity, count2;
	 
    parameter [9:0] Player_X_Center=320;  // Center position on the X axis
    parameter [9:0] Player_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Player_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Player_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Player_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Player_Y_Max=460;     // Bottommost point on the Y axis (previously 479)
    parameter [9:0] Player_X_Step=1;      // Step size on the X axis
    parameter [9:0] Player_Y_Step=1;      // Step size on the Y axis

    // Assign player sizing (height radius, then width radius)
    assign PlayerSY = 32;  
    assign PlayerSX = 24;
   
    always_ff @ (posedge frame_clk or posedge Reset) //make sure the frame clock is instantiated correctly
    begin: Move_Ball
        if (Reset)  // asynchronous Reset
        begin 
            Player_Y_Motion <= 10'd0; //Ball_Y_Step;
			Player_X_Motion <= 10'd1; //Ball_X_Step;
			PlayerY <= Player_Y_Max - PlayerSY;
			PlayerX <= Player_X_Max - PlayerSX;
			count <= 10'd0;
			count2 <= 10'd0;
			gravity <= 10'd0;
			frame <= 1'b0;
        end
           
        else 
        begin 
                 count2 <= count2 + 10'd1;
                 if (count2 > 15) begin
                    count2 <= 10'd0;
                 end
                 
                 if (Player_X_Motion == 10'd0) begin
                    frame = 1'b0;
                 end
                 else if (count2 % 15 == 1) begin
                    frame = ~frame;
                 end
                 
                 
                 // Ground
				 if ( (PlayerY + PlayerSY) >= Player_Y_Max ) begin  // Ball is at the bottom edge, BOUNCE!
					 Player_Y_Motion <= 10'd0;  // 2's complement.
					 // *** Add jumping here later
                     count <= 10'd0;
			     end
			     
			     // Off ground
			     else begin
			         Player_Y_Motion <= Player_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
					 count <= count + 10'd1;
                     if (count % 10 == 1) begin // Gravity if off ground
                        Player_Y_Motion <= Player_Y_Motion + 1'd1;
                     end
			     end
				 
				 // Right Edge 
				 if ( (PlayerX + PlayerSX) >= Player_X_Max - 10'd5) begin  // Ball is at the Right edge, BOUNCE!
					  Player_X_Motion <= 10'd0;  // 2's complement.
					  // Move left towards ball when on right edge
                      if (PlayerX > BallX)                        
                         Player_X_Motion <= -10'd1;
				 end
					  
				 // Left Edge	  
				 else if ( (PlayerX - PlayerSX) <= Player_X_Min + 10'd5) begin  // Ball is at the Left edge, BOUNCE!
					  Player_X_Motion <= 10'd0;
					  // Move right towards ball when on left edge
                      if (PlayerX < BallX)                        
                         Player_X_Motion <= 10'd1;
					  end
				 else begin
					 // Movement if not on borders (independent of ground touching) 
                     if (PlayerX > 300 && PlayerX < 570) begin // Keep moving only in a certain region
                         if (PlayerX > BallX)                        
                             Player_X_Motion <= -10'd2;
                         if (PlayerX < BallX)                        
                             Player_X_Motion <= 10'd2;
                     end
				 end
				 
				 // *** Don't move if ball is too far / If AI is getting too far from its goal
				 
				 
			     // Update movement
				 PlayerY <= (PlayerY + Player_Y_Motion);  // Update ball position
				 PlayerX <= (PlayerX + Player_X_Motion);
			     XMotion = Player_X_Motion;
		end  
    end
      
endmodule

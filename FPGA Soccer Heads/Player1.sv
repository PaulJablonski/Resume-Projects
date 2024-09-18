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


module player ( input logic Reset, frame_clk, AllowInput,
			   input logic [7:0] keycode, keycode2,
               output logic [9:0]  PlayerX, PlayerY, PlayerSY, PlayerSX, XMotion,
               output logic frame); // 1 = frame 2, 0 = frame 1
    
    logic [9:0] Player_X_Motion, Player_Y_Motion, count, gravity, count2;
	 
    parameter [9:0] Player_X_Center=320;  // Center position on the X axis
    parameter [9:0] Player_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Player_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Player_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Player_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Player_Y_Max=460;     // Bottommost point on the Y axis (479 previously)
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
			Player_X_Motion <= 10'd0; //Ball_X_Step;
			PlayerY <= Player_Y_Max - PlayerSY;
			PlayerX <= Player_X_Min + PlayerSX;
			count <= 10'd0;
			count2 <= 10'd0;
			gravity <= 10'd0;
			frame <= 1'b0;
        end
           
        else 
        begin 
                 // Count 2
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
					 if (keycode == 8'h1A || keycode2 == 8'h1A) begin // Jump only when on the ground (W)
                         Player_Y_Motion <= -10'd5;
                         //Player_X_Motion <= 10'd0;
                     end
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
					  if ((keycode == 8'h04 || keycode2 == 8'h04)) begin // Left (A) allowed when on right edge
//                         Player_Y_Motion <= 10'd0;
                           Player_X_Motion <= -10'd2;
                      end
			     end
				 // Left Edge	  
				 else if ( (PlayerX - PlayerSX) <= Player_X_Min + 10'd5) begin  // Ball is at the Left edge, BOUNCE!
					  Player_X_Motion <= 10'd0;
					  if ((keycode == 8'h07 || keycode2 == 8'h07)) begin // Right (D) allowed when on left edge
//                         Player_Y_Motion <= 10'd0;
                         Player_X_Motion <= 10'd2;
                         end
					  end
				 else begin
					 // Inputs if not on borders (independent of ground touching) 
                     if ((keycode == 8'h04 || keycode2 == 8'h04)) begin // Left (A)
//                         Player_Y_Motion <= 10'd0;
                         Player_X_Motion <= -10'd2;
                     end
                     else if ((keycode == 8'h07 || keycode2 == 8'h07)) begin // Right (D)
//                         Player_Y_Motion <= 10'd0;
                         Player_X_Motion <= 10'd2;
                     end
				 
				 end
				 
				 // Don't move if no key inputs (left and right)
				 if (keycode != 8'h04 && keycode != 8'h07 && keycode2 != 8'h04 && keycode2 != 8'h07) begin
				    // Deceleration
//				    if (Player_X_Motion > 0 && (count2 % 10 == 1)) begin
//				        Player_X_Motion = Player_X_Motion - 10'd1;
//				    end
//				    if (Player_X_Motion < 0 && (count2 % 10 == 1)) begin
//				        Player_X_Motion = Player_X_Motion + 10'd1;
//				    end
                    Player_X_Motion <= 10'd0;
				 end
				 
			     // Update movement
				 PlayerY <= (PlayerY + Player_Y_Motion);  // Update ball position
				 PlayerX <= (PlayerX + Player_X_Motion);
			     XMotion = Player_X_Motion;
			     
			     
		end  
    end
      
endmodule

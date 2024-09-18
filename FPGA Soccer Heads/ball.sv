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


module  ball ( input logic Reset, frame_clk, AllowInput,
			   input logic [7:0] keycode,
			   input logic [9:0] PlayerX, PlayerY, PlayerSX, PlayerSY, P1XMotion, // Velocity 
			   input logic [9:0] PlayerAIX, PlayerAIY, PlayerAISX, PlayerAISY, P2XMotion, // Velocity 
			   input  logic [9:0] LGoalX, LGoalY, LGoalSX, LGoalSY, RGoalX, RGoalY, RGoalSX, RGoalSY,
               output logic [9:0] BallX, BallY, BallS );
    
    logic [9:0] Ball_X_Motion, Ball_Y_Motion, count, bounce, gravity, playerspeed;
    logic Initiated;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=460;     // Bottommost point on the Y axis (previously 479)
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    assign BallS = 16;  // default ball size
   
    always_ff @ (posedge frame_clk or posedge Reset) //make sure the frame clock is instantiated correctly
    begin: Move_Ball
        if (Reset)  // asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
			Ball_X_Motion <= 10'd0; //Ball_X_Step;
			playerspeed <= 10'd0;
//			BallY <= Ball_Y_Center;
            BallY <= 10'd2 + BallS;
			BallX <= Ball_X_Center;
			count <= 10'd0;
			bounce <= 10'd0;
			gravity <= 10'd0;
        end
           
        else 
        begin 
             
             
             // Ball motion around display edges
             // NOTE: Look at edge cases and make sure that ball can't go through corner (basically add a condition for count increment and then make everything a separate if statement)
             if ( (BallY + BallS) >= Ball_Y_Max ) begin  // Ball is at the bottom edge, BOUNCE!
                  Ball_Y_Motion <= 10'd0; // (~ (Ball_Y_Step) + 1'b1); // 2's Complement (goes up)
                  
                  if (bounce <= -10'd3) begin // Kill ball to prevent infinite bouncing
                      gravity <= bounce;
                  end
                  else begin
                      gravity <= 10'd0;
                      bounce <= 10'd0;
                  end
                  
                  count <= 10'd0;
                  //bounce <= 10'd0;
             end   
             else if ( (BallY - BallS) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
                  Ball_Y_Motion <= Ball_Y_Step;
                  // Change gravity here?
             else begin
                 Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
                 count <= count + 10'd1;
             end
             
             
             if (count == 10'd1) begin // Ball is just above the bottom edge (reset bounce)
                  bounce <= 10'd0;
             end  
             
                  
                  
             if ( (BallX + BallS) >= RGoalX - 10'd5 && BallY < 640 - RGoalSY) begin // Ball is at the Right edge, BOUNCE!
                  Ball_X_Motion <= (~ (Ball_X_Step) + 1'b1);  // 2's complement.
                  playerspeed <= 10'd0;
             end
             else if ( (BallX - BallS) <= LGoalX + LGoalSX + 10'd5 && BallY < 640 - LGoalSY) begin // Ball is at the Left edge, BOUNCE!
                  Ball_X_Motion <= Ball_X_Step;
                  playerspeed <= 10'd0;
             end
             
            
				 
				 
              
             // Ball collision around player 1
             // Right edge of player collides
             if (BallX - (PlayerX + PlayerSX) <= BallS && BallX - (PlayerX + PlayerSX) >= 10'd0 && (BallY + BallS) >= (PlayerY - PlayerSY) && (BallY - BallS) <= (PlayerY + PlayerSY)) begin 
                 playerspeed <= P1XMotion + 10'd1;
                 bounce <= -10'd4;
                 //Ball_Y_Motion <= Ball_Y_Motion - 10'd3;
             end
             
             // Left edge of player collides
             if ((PlayerX - PlayerSX) - BallX <= BallS && (PlayerX - PlayerSX) - BallX >= 10'd0 && (BallY + BallS) >= (PlayerY - PlayerSY) && (BallY - BallS) <= (PlayerY + PlayerSY)) begin
                 playerspeed <= P1XMotion - 10'd1;
                 bounce <= -10'd4;
                 //Ball_Y_Motion <= Ball_Y_Motion - 10'd3;
             end
             
             // Top edge of player collides
             if ((BallX + BallS) >= (PlayerX - PlayerSX) && (BallX - BallS) <= (PlayerX + PlayerSX) && (BallY + BallS) >= (PlayerY - PlayerSY)) begin
                  Ball_Y_Motion <= 10'd0; // (~ (Ball_Y_Step) + 1'b1); // 2's Complement (goes up)
                  if (bounce <= -10'd3) begin // Kill ball to prevent infinite bouncing
                      gravity <= bounce;
                  end
                  count <= 10'd0;
                  //bounce <= 10'd0;
             end
             
             
             // Ball collision with left and right goalposts
             // Left
             if ((BallY + BallS) >= LGoalY - LGoalSY - 10'd5 && BallX <= LGoalSX  && (BallY + BallS) < LGoalY - LGoalSY + 10'd4) begin
                  Ball_Y_Motion <= 10'd0; // (~ (Ball_Y_Step) + 1'b1); // 2's Complement (goes up)
                  if (bounce <= -10'd3) begin // Kill ball to prevent infinite bouncing
                      gravity <= bounce;
                  end
                  count <= 10'd0;
                  //bounce <= 10'd0;
             end 
             // Right
             else if ((BallY + BallS) >= RGoalY - RGoalSY - 10'd5 && BallX >= RGoalX && (BallY + BallS) < RGoalY - RGoalSY + 10'd4) begin
                  Ball_Y_Motion <= 10'd0; // (~ (Ball_Y_Step) + 1'b1); // 2's Complement (goes up)
                  if (bounce <= -10'd3) begin // Kill ball to prevent infinite bouncing
                      gravity <= bounce;
                  end
                  count <= 10'd0;
                  //bounce <= 10'd0;
             end
             
             
             
             // Ball collision around player AI
             if (BallX - (PlayerAIX + PlayerAISX) <= BallS && BallX - (PlayerAIX + PlayerAISX) >= 10'd0 && (BallY + BallS) >= (PlayerAIY - PlayerAISY) && (BallY - BallS) <= (PlayerAIY + PlayerAISY)) begin 
                 playerspeed <= P2XMotion + 10'd1;
                 bounce <= -10'd4;
                 //Ball_Y_Motion <= Ball_Y_Motion - 10'd3;
             end
             
             // Left edge of player collides
             if ((PlayerAIX - PlayerAISX) - BallX <= BallS && (PlayerAIX - PlayerAISX) - BallX >= 10'd0 && (BallY + BallS) >= (PlayerAIY - PlayerAISY) && (BallY - BallS) <= (PlayerAIY + PlayerAISY)) begin
                 playerspeed <= P2XMotion - 10'd1;
                 bounce <= -10'd4;
                 //Ball_Y_Motion <= Ball_Y_Motion - 10'd3;
             end
             
             // Top edge of player collides
             if ((BallX + BallS) >= (PlayerAIX - PlayerAISX) && (BallX - BallS) <= (PlayerAIX + PlayerAISX) && (BallY + BallS) >= (PlayerAIY - PlayerAISY)) begin
                 Ball_Y_Motion <= 10'd0; // (~ (Ball_Y_Step) + 1'b1); // 2's Complement (goes up)
                      if (bounce <= -10'd3) begin // Kill ball to prevent infinite bouncing
                          gravity <= bounce;
                      end
                      count <= 10'd0;
                      //bounce <= 10'd0;
             end
             
             
             
             
             
             
             // Gravity and bouncing variables
             if (count % 10 == 0 && count != 0) begin // Handle gravity when not on edges
                    gravity <= gravity + 10'd1;
                 end
                 
             if (count % 25 == 0 && count != 0) begin // Handle bouncing when not on edges
                    bounce <= bounce - 10'd1;
                 end 
             
             
             
             BallY <= (BallY + Ball_Y_Motion + gravity);  // Update ball position
             BallX <= (BallX + Ball_X_Motion + playerspeed);
			
		end  
    end
      
endmodule

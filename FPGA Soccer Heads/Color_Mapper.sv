module  color_mapper ( input  logic vgaclk,
                       input  logic [3:0] ones, tens, hundreds,
                       input  logic [1:0] MainMenuOn,
                       input  logic [7:0] Seconds,
                       input  logic Mode,
                       input  logic GameStart, GameOver, WipeScore, p1frame, p2frame,
                       input  logic [9:0] BallX, BallY, DrawX, DrawY, Ball_size,
                       input  logic [9:0] PlayerX, PlayerY, Player_width, Player_height, PlayerXMotion,
                       input  logic [9:0] PlayerAIX, PlayerAIY, PlayerAI_width, PlayerAI_height, PlayerAIXMotion,
                       input  logic [9:0] LGoalX, LGoalY, LGoalSX, LGoalSY, RGoalX, RGoalY, RGoalSX, RGoalSY,
                       output logic [3:0] Red, Green, Blue,
                       output logic TimeOverByScore, GoalScored);

        // Game on variables
        logic ball_on;
        logic player_on;
        logic playerAI_on;
        logic lgoal_on;
        logic rgoal_on;
        
        // Scorekeeping variables
        logic [5:0] p1score, p2score;
   
        // FIELD BACKGROUND INSTANTIATION (General background)  
        logic [18:0] rom_address, rom_address2, rom_address3, rom_address4;
        logic [3:0] rom_q;
        logic [3:0] palette_red, palette_green, palette_blue;
        logic negedge_vga_clk;
    
        // read from ROM on negedge, set pixel on posedge
        assign negedge_vga_clk = ~vgaclk;
        
        // address into the rom = (x*xDim)/640 + ((y*yDim)/480) * xDim
        // this will stretch out the sprite across the entire screen
        assign rom_address = ((DrawX * 640) / 640) + (((DrawY * 480) / 480) * 640);
        
        // Instantiate ROM and Palettes for background
        field_rom GameBackground_rom (
            .clka (negedge_vga_clk),
            .addra (rom_address),
            .douta (rom_q)
        );  
        
        GameBackground_palette GameBackground_palette (
            .index (rom_q),
            .red   (palette_red),
            .green (palette_green),
            .blue  (palette_blue)
        );
        
        
        // Goal drawing / mapping
        // Left goal
        int lgDistX, lgDistY, lgWidth, lgHeight;
        assign lgDistX = DrawX - LGoalX;
        assign lgDistY = LGoalY - DrawY;
        assign lgWidth = LGoalSX;
        assign lgHeight = LGoalSY;
        
        always_comb
        begin:LGoal_on_proc
            if (DrawX > 0 && DrawX <= lgWidth && DrawY > 480 - lgHeight && DrawY <= 480)
                lgoal_on = 1'b1;
            else
                lgoal_on = 1'b0;
        end
        
        logic [13:0] rom_address_g;
        logic [1:0] rom_q_g;
        logic [3:0] palette_red_g, palette_green_g, palette_blue_g;
        
        assign rom_address_g = ((DrawX) + ((DrawY % (480 - lgHeight)) * 72));
        
        GoalPostNormal_rom GoalPostNormal_rom (
            .clka   (negedge_vga_clk),
            .addra (rom_address_g),
            .douta       (rom_q_g)
        );
        
        GoalPostNormal_palette GoalPostNormal_palette (
            .index (rom_q_g),
            .red   (palette_red_g),
            .green (palette_green_g),
            .blue  (palette_blue_g)
        );
        
        // Right goal
        int rgDistX, rgDistY, rgWidth, rgHeight;
        assign rgDistX = DrawX - RGoalX;
        assign rgDistY = RGoalY - DrawY;
        assign rgWidth = RGoalSX;
        assign rgHeight = RGoalSY;
        
        always_comb
        begin:RGoal_on_proc
            if (DrawX > 640 - rgWidth && DrawX <= 640 && DrawY > 480 - rgHeight && DrawY <= 480)
                rgoal_on = 1'b1;
            else
                rgoal_on = 1'b0;
        end
        
        logic [13:0] rom_address_g2;
        logic [1:0] rom_q_g2;
        logic [3:0] palette_red_g2, palette_green_g2, palette_blue_g2;
        
        assign rom_address_g2 = (rgWidth - (DrawX % (640 - rgWidth)) + ((DrawY % (480 - rgHeight)) * 72));
        
        GoalPostNormal_rom GoalPostNormal_rom2 (
            .clka   (negedge_vga_clk),
            .addra (rom_address_g2),
            .douta       (rom_q_g2)
        );
        
        GoalPostNormal_palette GoalPostNormal_palette2 (
            .index (rom_q_g2),
            .red   (palette_red_g2),
            .green (palette_green_g2),
            .blue  (palette_blue_g2)
        );
        
            
        // MAIN MENU INSTANTIATIONS
        // Main menu components
        // Play Button
        logic topbutton_on;
        logic [13:0] rom_address_b1;
        logic [1:0] rom_q_b1;
        logic [3:0] palette_red_b1, palette_green_b1, palette_blue_b1;
        assign rom_address_b1 = ((DrawX % 220) + ((DrawY % 200) * 200));
        
        PlayButton_rom PlayButton_rom (
            .clka   (negedge_vga_clk),
            .addra  (rom_address_b1),
            .douta       (rom_q_b1)
        );
        
        PlayButton_palette PlayButton_palette (
            .index (rom_q_b1),
            .red   (palette_red_b1),
            .green (palette_green_b1),
            .blue  (palette_blue_b1)
        );
        
        always_comb
        begin:TopButton
            if (DrawX > 220 && DrawX <= 420 && DrawY > 200 && DrawY <= 280) 
                topbutton_on = 1'b1;
            else 
                topbutton_on = 1'b0;
        end
        
        // Play power mode button
        logic botbutton_on;
        logic [13:0] rom_address_b2;
        logic [1:0] rom_q_b2;
        logic [3:0] palette_red_b2, palette_green_b2, palette_blue_b2;
        assign rom_address_b2 = ((DrawX % 220) + ((DrawY % 300) * 200)); // 200 x 80
        
        PowerButton_rom PowerButton_rom (
            .clka   (negedge_vga_clk),
            .addra  (rom_address_b2),
            .douta       (rom_q_b2)
        );
        
        PowerButton_palette PowerButton_palette (
            .index (rom_q_b2),
            .red   (palette_red_b2),
            .green (palette_green_b2),
            .blue  (palette_blue_b2)
        );
        
        always_comb
        begin:BotButton
            if (DrawX > 220 && DrawX <= 420 && DrawY > 300 && DrawY <= 380) 
                botbutton_on = 1'b1;
            else 
                botbutton_on = 1'b0;
        end
        
        // Title
        logic title_on;
        logic [14:0] rom_address_t;
        logic [1:0] rom_q_t;
        logic [3:0] palette_red_t, palette_green_t, palette_blue_t;
        assign rom_address_t = (((DrawX - 170) + ((DrawY % 100) * 300))); // 300 x 80
        
        Title_rom Title_rom (
            .clka   (negedge_vga_clk),
            .addra (rom_address_t),
            .douta       (rom_q_t)
        );
        
        Title_palette Title_palette (
            .index (rom_q_t),
            .red   (palette_red_t),
            .green (palette_green_t),
            .blue  (palette_blue_t)
        );
        
        always_comb
        begin:Title
            if (DrawX > 170 && DrawX <= 470 && DrawY > 100 && DrawY <= 180) 
                title_on = 1'b1;
            else 
                title_on = 1'b0;
        end
        
        
        
        
        // BALL DRAWING / MAPPING  
        int DistX, DistY, Size;
        assign DistX = DrawX - BallX;
        assign DistY = DrawY - BallY;
        assign Size = Ball_size;
      
        always_comb
        begin:Ball_on_proc
            if ( (DistX*DistX + DistY*DistY) <= (Size * Size) )
                ball_on = 1'b1;
            else 
                ball_on = 1'b0;
         end 
           
           
           
        
        // Player 1 drawing / mapping
        int pDistX, pDistY, pWidth, pHeight;
        assign pDistX = DrawX - PlayerX;
        assign pDistY = DrawY - PlayerY;
        assign pWidth = Player_width;
        assign pHeight = Player_height;
        
        always_comb
        begin:Player_on_proc   
            if (pDistX <= pWidth && pDistX >= -pWidth && pDistY <= pHeight && pDistY >= -pHeight)
                player_on = 1'b1;
            else 
                player_on = 1'b0;
        end
        
        // Frame 1
        logic [11:0] rom_address_p1;
        logic [1:0] rom_q_p1;
        logic [3:0] palette_red_p1, palette_green_p1, palette_blue_p1;
        
        assign rom_address_p1 = ((DrawX - (PlayerX - Player_width))) + (((DrawY - (PlayerY - Player_height))) * 48);
        
        P1Frame1_rom P1Frame1_rom (
            .clka   (negedge_vga_clk),
            .addra (rom_address_p1),
            .douta       (rom_q_p1)
        );
        
        P1Frame1_palette P1Frame1_palette (
            .index (rom_q_p1),
            .red   (palette_red_p1),
            .green (palette_green_p1),
            .blue  (palette_blue_p1)
        );
        
        // Frame 2
        logic [11:0] rom_address_p1_2;
        logic [1:0] rom_q_p1_2;
        logic [3:0] palette_red_p1_2, palette_green_p1_2, palette_blue_p1_2;
        
        assign rom_address_p1_2 = ((DrawX - (PlayerX - Player_width))) + (((DrawY - (PlayerY - Player_height))) * 48);
        
        P1Frame2_rom P1Frame2_rom (
            .clka   (negedge_vga_clk),
            .addra (rom_address_p1_2),
            .douta       (rom_q_p1_2)
        );
        
        P1Frame2_palette P1Frame2_palette (
            .index (rom_q_p1_2),
            .red   (palette_red_p1_2),
            .green (palette_green_p1_2),
            .blue  (palette_blue_p1_2)
        );
        
        
        // Player AI drawing / mapping
        int aDistX, aDistY, aWidth, aHeight;
        assign aDistX = DrawX - PlayerAIX;
        assign aDistY = DrawY - PlayerAIY;
        assign aWidth = PlayerAI_width;
        assign aHeight = PlayerAI_height;
        
        always_comb
        begin:PlayerAI_on_proc
            if (aDistX <= aWidth && aDistX >= -aWidth && aDistY <= aHeight && aDistY >= -aHeight)
                playerAI_on = 1'b1;
            else 
                playerAI_on = 1'b0;
        end
        
        // Frame 1
        logic [11:0] rom_address_p2;
        logic [1:0] rom_q_p2;
        logic [3:0] palette_red_p2, palette_green_p2, palette_blue_p2;
        
        assign rom_address_p2 = ((DrawX - (PlayerAIX - PlayerAI_width))) + (((DrawY - (PlayerAIY - PlayerAI_height))) * 48);
        
        P2Frame1_rom P2Frame1_rom (
            .clka   (negedge_vga_clk),
            .addra (rom_address_p2),
            .douta       (rom_q_p2)
        );
        
        P2Frame1_palette P2Frame1_palette (
            .index (rom_q_p2),
            .red   (palette_red_p2),
            .green (palette_green_p2),
            .blue  (palette_blue_p2)
        );
        
        // Frame 2
        logic [11:0] rom_address_p2_2;
        logic [1:0] rom_q_p2_2;
        logic [3:0] palette_red_p2_2, palette_green_p2_2, palette_blue_p2_2;
        
        assign rom_address_p2_2 = ((DrawX - (PlayerAIX - PlayerAI_width))) + (((DrawY - (PlayerAIY - PlayerAI_height))) * 48);
        
        P2Frame2_rom P2Frame2_rom (
            .clka   (negedge_vga_clk),
            .addra (rom_address_p2_2),
            .douta       (rom_q_p2_2)
        );
        
        P2Frame2_palette P2Frame2_palette (
            .index (rom_q_p2_2),
            .red   (palette_red_p2_2),
            .green (palette_green_p2_2),
            .blue  (palette_blue_p2_2)
        );
        
        
        
        // Powerup drawing
        // Goalpost
        logic [9:0] rom_address_pu;
        logic [1:0] rom_q_pu;
        logic [3:0] palette_red_pu, palette_green_pu, palette_blue_pu;
        
        assign rom_address_pu = ((DrawX - 304)) + (((DrawY - 400)) * 32);

        goalpowerup_rom goalpowerup_rom (
            .clka   (negedge_vga_clk),
            .addra (rom_address_pu),
            .douta       (rom_q_pu)
        );
        
        goalpowerup_palette goalpowerup_palette (
            .index (rom_q_pu),
            .red   (palette_red_pu),
            .green (palette_green_pu),
            .blue  (palette_blue_pu)
        );
        
        // Speed
        logic [9:0] rom_address_pu2;
        logic [1:0] rom_q_pu2;
        logic [3:0] palette_red_pu2, palette_green_pu2, palette_blue_pu2;
        
        assign rom_address_pu2 = ((DrawX - 304)) + (((DrawY - 400)) * 32);

        speedpowerup_rom speedpowerup_rom (
            .clka   (negedge_vga_clk),
            .addra (rom_address_pu2),
            .douta       (rom_q_pu2)
        );
        
        speedpowerup_palette speedpowerup_palette (
            .index (rom_q_pu2),
            .red   (palette_red_pu2),
            .green (palette_green_pu2),
            .blue  (palette_blue_pu2)
        );
        
        logic speedactivate;
        
        always_comb
        begin:Powerups
            if (hundreds == 4'd1 && tens == 4'd6 && ones == 4'd5) begin
                speedactivate = 1'b1;
            end
            else if (hundreds == 4'd1 && tens >= 4'd7 && ones == 4'd0) begin
                speedactivate = 1'b0;
            end
            
            //if (speedactivate == 1'b1 && 
        end
        
        
        
        
        // GOAL DETECTION AND SCORE UPDATING
        always_comb
        begin
            // Time over by time
            if (ones == 4'd0 && tens == 4'd0 && hundreds == 4'd0) begin
                TimeOverByScore = 1'b1;
            end
            
            // P2 scores
            if (BallX <= LGoalX + LGoalSX && (BallY + 10'd16) >= LGoalY - LGoalSY + 10'd4 && p2score < 6'd9) begin
                p2score = p2score + 6'd1;
                GoalScored = 1'b1;
            end
            // P1 scores
            else if (BallX >= 590 && (BallY + 10'd16) >= RGoalY - RGoalSY + 10'd4 && p1score < 6'd9) begin
                p1score = p1score + 6'd1;
                GoalScored = 1'b1;
            end
            else begin
                GoalScored = 1'b0;
            end
            
            if (p1score >= 6'd9 || p2score >= 6'd9) begin
                TimeOverByScore = 1'b1;
            end 
            else begin
                TimeOverByScore = 1'b0;
            end
            
            
            
            if (WipeScore) begin
                p1score = 6'd0;
                p2score = 6'd0;
            end
        end
        
        // FONT ROM
        logic [10:0] fontaddr;
        logic [7:0] fontout;
        logic timer_on;
        
        font_rom fontrom(
            .addr(fontaddr),
            .data(fontout)
        );
        
        // Tens place number printed at x = 312
        always_comb 
        begin:TimersScores
            timer_on = 1'b0;
            if (DrawX >= 312 && DrawX < 328 && DrawY > 20 && DrawY <= 52) begin
                fontaddr = 11'b01100000000 + (DrawY - 20)/2 + ((11'b00000000000 | tens)<<4); 
                if (fontout[7 - (DrawX - 312)/2] == 1'b1) begin // /2 before
                    timer_on = 1'b1;
                end
                else begin
                    timer_on = 1'b0;
                end
            end
            // Ones place
            else if (DrawX >= 330 && DrawX < 346 && DrawY > 20 && DrawY <= 52) begin
                fontaddr = 11'b01100000000 + (DrawY - 20)/2 + ((11'b00000000000 | ones)<<4); 
                if (fontout[7 - (DrawX - 330)/2] == 1'b1) begin // /2 before
                    timer_on = 1'b1;
                end
                else begin
                    timer_on = 1'b0;
                end
            end
            // Hundreds place
            else if (DrawX >= 294 && DrawX < 310 && DrawY > 20 && DrawY <= 52) begin
                fontaddr = 11'b01100000000 + (DrawY - 20)/2 + ((11'b00000000000 | hundreds)<<4); 
                if (fontout[7 - (DrawX - 294)/2] == 1'b1) begin // /2 before
                    timer_on = 1'b1;
                end
                else begin
                    timer_on = 1'b0;
                end
            end
            // P1 points
            else if (DrawX >= 80 && DrawX < 96 && DrawY > 20 && DrawY <= 52) begin
                fontaddr = 11'b01100000000 + (DrawY - 20)/2 + ((11'b00000000000 | p1score)<<4); 
                if (fontout[7 - (DrawX - 80)/2] == 1'b1) begin // /2 before
                    timer_on = 1'b1;
                end
                else begin
                    timer_on = 1'b0;
                end
            end
            // P2 points
            else if (DrawX >= 560 && DrawX < 576 && DrawY > 20 && DrawY <= 52) begin
                fontaddr = 11'b01100000000 + (DrawY - 20)/2 + ((11'b00000000000 | p2score)<<4); 
                if (fontout[7 - (DrawX - 560)/2] == 1'b1) begin // /2 before
                    timer_on = 1'b1;
                end
                else begin
                    timer_on = 1'b0;
                end
            end
        end
        
        
        
         // *** Overall drawing and mapping *** (using FSM) 
        always_comb
        begin:RGB_Display
            if (MainMenuOn != 2'b11) begin // Main menu
                // Title
                if (title_on == 1'b1) begin
                    Red = palette_red_t; 
                    Green = palette_green_t;
                    Blue = palette_blue_t;
                end
                // Top button
                else if (topbutton_on == 1'b1) begin
                    if (MainMenuOn == 2'b01 && palette_red_b1 == 4'hF) begin
                        Red = 4'hB; 
                        Green = 4'hD;
                        Blue = 4'hB;
                    end
                    else begin
                        Red = palette_red_b1; 
                        Green = palette_green_b1;
                        Blue = palette_blue_b1;
                    end
                end
                // Bottom button
                else if (botbutton_on == 1'b1) begin
                    if (MainMenuOn == 2'b10 && palette_red_b2 == 4'hF) begin
                        Red = 4'hB; 
                        Green = 4'hD;
                        Blue = 4'hB;
                    end
                    else begin
                        Red = palette_red_b2; 
                        Green = palette_green_b2;
                        Blue = palette_blue_b2;
                    end
                end
                // Background field
                else begin
                    Red = palette_red; 
                    Green = palette_green;
                    Blue = palette_blue;
                end
            end
            
            else if (GameStart == 1'b1) begin // Game is started
                if ((lgoal_on == 1'b1 && palette_red_g != 4'hF)) begin
                    Red = palette_red_g; 
                    Green = palette_green_g;
                    Blue = palette_blue_g;
                end   
                else if ((rgoal_on == 1'b1 && palette_red_g2 != 4'hF)) begin
                    Red = palette_red_g2; 
                    Green = palette_green_g2;
                    Blue = palette_blue_g2;
                end
                else if ((timer_on == 1'b1)) begin
                    Red = 4'hf;
                    Green= 4'hf;
                    Blue = 4'hf;
                end
                else if ((ball_on == 1'b1)) begin 
                    Red = 4'he;
                    Green = 4'he;
                    Blue = 4'he;
                end
                else if ((player_on == 1'b1 && palette_red_p1 != 4'h0)) begin
                    if (p1frame == 1'b0) begin
                        Red = palette_red_p1;
                        Green = palette_green_p1;
                        Blue = palette_blue_p1;
                    end
                    else begin
                        Red = palette_red_p1_2;
                        Green = palette_green_p1_2;
                        Blue = palette_blue_p1_2;
                    end
                end
                else if ((playerAI_on == 1'b1 && palette_red_p2 != 4'h0)) begin
                    if (p2frame == 1'b0) begin
                        Red = palette_red_p2;
                        Green = palette_green_p2;
                        Blue = palette_blue_p2;
                    end
                    else begin
                        Red = palette_red_p2_2;
                        Green = palette_green_p2_2;
                        Blue = palette_blue_p2_2;
                    end
                end
                else begin 
                    Red = palette_red; 
                    Green = palette_green;
                    Blue = palette_blue;
                end  
            end        
        end 
        
endmodule

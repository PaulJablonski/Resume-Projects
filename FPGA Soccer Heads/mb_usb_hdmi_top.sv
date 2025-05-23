`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Zuofu Cheng
// 
// Create Date: 12/11/2022 10:48:49 AM
// Design Name: 
// Module Name: mb_usb_hdmi_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Top level for mb_lwusb test project, copy mb wrapper here from Verilog and modify
// to SV
// Dependencies: microblaze block design
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0, 
    
    //USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,
    
    //UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,
    
    //HDMI
    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0]hdmi_tmds_data_n,
    output logic [2:0]hdmi_tmds_data_p,
        
    //HEX displays
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
    );
    
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic clk_25MHz, clk_125MHz, clk, clk_100MHz;
    logic locked;
    logic [9:0] drawX, drawY, ballxsig, ballysig, ballsizesig;
    logic [9:0] playerxsig, playerysig, playerwidthrad, playerheightrad, p1xmotion, p2xmotion;
    logic [9:0] playerAIxsig, playerAIysig, playerAIwidthrad, playerAIheightrad;
    
    logic [9:0] goalLX, goalLY, goalLSX, goalLSY;
    logic [9:0] goalRX, goalRY, goalRSX, goalRSY;

    logic hsync, vsync, vde;
    logic [3:0] red, green, blue;
    logic reset_ah;
    
    assign reset_ah = reset_rtl_0;
    
    // FSM signals
    
    logic gamestart, gameover, p1frame, p2frame;
    logic [1:0] mainmenuon;
    logic timeover, mode, wipescore, goalscored, timeoverscore;
    logic [7:0] seconds;
    logic [3:0] ones, tens, hundreds;
    
    
    //Keycode HEX drivers
    HexDriver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[31:28], keycode0_gpio[27:24], keycode0_gpio[23:20], keycode0_gpio[19:16]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    
    HexDriver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[15:12], keycode0_gpio[11:8], keycode0_gpio[7:4], keycode0_gpio[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );
    
    mblab6 mb_block_i(
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah), 
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );
        
    //clock wizard configured with a 1x and 5x clock for HDMI
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(Clk)
    );
    
    //VGA Sync signal generator
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );    

    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        //Reset is active LOW
        .rst(reset_ah),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );

    
    //Ball Module
    // Add signals with FSM to not allow input before game starts
    ball ball_instance(
        .Reset(reset_ah | ~gamestart | goalscored),
        .frame_clk(vsync),                    
        .keycode(keycode0_gpio[7:0]),
        .BallX(ballxsig),
        .BallY(ballysig),
        .BallS(ballsizesig),
        .PlayerX(playerxsig),
        .PlayerY(playerysig),
        .PlayerSX(playerwidthrad),
        .PlayerSY(playerheightrad),
        .PlayerAIX(playerAIxsig),
        .PlayerAIY(playerAIysig),
        .PlayerAISX(playerAIwidthrad),
        .PlayerAISY(playerAIheightrad),
        .P1XMotion(p1xmotion),
        .P2XMotion(p2xmotion),
        .LGoalX(goalLX),
        .LGoalY(goalLY),
        .LGoalSX(goalLSX),
        .LGoalSY(goalLSY),
        .RGoalX(goalRX),
        .RGoalY(goalRY),
        .RGoalSX(goalRSX),
        .RGoalSY(goalRSY)
    );
    
    // Player Module 
    // Add signals with FSM to not allow input before game starts
    player player_instance1(
        .Reset(reset_ah | ~gamestart | goalscored),
        .frame_clk(vsync),                    
        .keycode(keycode0_gpio[7:0]), // For one input 
        .keycode2(keycode1_gpio[7:0]), // For jumping or secondary inputs
        .PlayerX(playerxsig),
        .PlayerY(playerysig),
        .PlayerSX(playerwidthrad),
        .PlayerSY(playerheightrad),
        .XMotion(p1xmotion),
        .frame(p1frame)
    );
    
    // AI Module
    // Add signals with FSM to not allow input before game starts
    playerAI playerAI_instance(
        .Reset(reset_ah | ~gamestart | goalscored),
        .frame_clk(vsync),  
        .BallX(ballxsig),
        .BallY(ballysig),
        .PlayerX(playerAIxsig),
        .PlayerY(playerAIysig),
        .PlayerSX(playerAIwidthrad),
        .PlayerSY(playerAIheightrad),
        .XMotion(p2xmotion),
        .frame(p2frame)
    );
    
    // Color Mapper Module   
    // Add signals later for player movement animation from player modules
    color_mapper color_instance(
        .Mode(mode),
        .p1frame(p1frame),
        .p2frame(p2frame),
        .vgaclk(clk_25MHz),
        .Seconds(seconds),
        .ones(ones),
        .tens(tens),
        .hundreds(hundreds),
        .MainMenuOn(mainmenuon), // Next three inputs will alter what is being displayed menuwise or gamewise
        .GameStart(gamestart),
        .GameOver(gameover),
        .WipeScore(wipescore),
        .BallX(ballxsig),
        .BallY(ballysig),
        .PlayerX(playerxsig),
        .PlayerY(playerysig),
        .PlayerXMotion(p1xmotion),
        .PlayerAIXMotion(p2xmotion),
        .PlayerAIX(playerAIxsig), 
        .PlayerAIY(playerAIysig), 
        .LGoalX(goalLX),
        .LGoalY(goalLY),
        .LGoalSX(goalLSX),
        .LGoalSY(goalLSY),
        .RGoalX(goalRX),
        .RGoalY(goalRY),
        .RGoalSX(goalRSX),
        .RGoalSY(goalRSY),
        .DrawX(drawX),
        .DrawY(drawY),
        .Player_width(playerwidthrad),
        .Player_height(playerheightrad),
        .PlayerAI_width(playerAIwidthrad), 
        .PlayerAI_height(playerAIheightrad),
        .Ball_size(ballsizesig),
        .Red(red),
        .Green(green),
        .Blue(blue),
        // Use these
        .TimeOverByScore(timeoverscore),
        .GoalScored(goalscored)
    );
    
    // Goals
    GoalPost goal_left(
        .Reset(reset_ah | ~gamestart),
        .frame_clk(vsync),
        .LR(1'b0),
        .GoalX(goalLX),
        .GoalY(goalLY),
        .GoalSX(goalLSX),
        .GoalSY(goalLSY) 
    );
    
    GoalPost goal_right(
        .Reset(reset_ah | ~gamestart), 
        .frame_clk(vsync),
        .LR(1'b1),
        .GoalX(goalRX),
        .GoalY(goalRY),
        .GoalSX(goalRSX),
        .GoalSY(goalRSY)
    );
    
    // Scoreboard
    Scoreboard scoreboard(
        .reset(reset_ah | wipescore), // Separate signal from FSM during mainmenu to wipe scores and time over
        .clk25(clk_25MHz),
        .seconds(seconds), // Use this for powerups or something
        .ones(ones),
        .tens(tens),
        .hundreds(hundreds),
        .TimeOver(timeover)
    );
    
    // FSM
    FSM fsm( // Setup signals from this to color mapper and etc.
        .Clk(Clk),
        .Reset(reset_ah),
        .TimeOver(timeover | timeoverscore),
        .Inputs(keycode0_gpio[7:0]), // Route from a module for input during menus
        .MainMenuOn(mainmenuon),
        .GameStart(gamestart),
        .GameOver(gameover),
        .Mode(mode),
        .WipeScore(wipescore)
    );
    
endmodule

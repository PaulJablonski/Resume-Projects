module FSM(
    input logic Clk, Reset, 
    input logic TimeOver, // Sent from scoreboard when time = 0
    input logic [7:0] Inputs, // W A S D ENTER (sent from player? Can use any module really)
    output logic [1:0] MainMenuOn, 
    output logic GameStart, GameOver, // Used to tell where input can be allowed
    output logic WipeScore,
    output logic Mode // 0 if AI and 1 if Power
    );
    
    // States
    enum logic [2:0] {mainmenu1, mainmenu2, mainmenu3, gameon, scoreboard} state, nextstate; // Figure out states
    
    // Default values
    always_ff @ (posedge Clk)
    begin
        if (Reset) begin
            state <= mainmenu1;
        end
        else 
            state <= nextstate;
    end
    
    always_comb 
    begin
        // Always stay on current state
        // nextstate = state;
        
        // Default variable values
        MainMenuOn = 2'b00;
        GameStart = 1'b0;
        GameOver = 1'b0;
        Mode = 1'b0; // AI by default
        WipeScore = 1'b0;
        
        // Take inputs and use them based on state to change states
        unique case (state)
            
            mainmenu1 : // No buttons selected on menu
                case (Inputs)
                    8'h1A : // W
                        nextstate = mainmenu2; // Top button
                    8'h04 : // A
                        nextstate = mainmenu2; // Top button
                    8'h16 : // S
                        nextstate = mainmenu2; // Top button
                    8'h07 : // D
                        nextstate = mainmenu2; // Top button
                    8'h28 : // ENTER
                        nextstate = mainmenu2; // Top button
                    default :
                        begin
                            nextstate = mainmenu1; // Stay
                            MainMenuOn = 2'b00;
                            GameStart = 1'b0;
                            GameOver = 1'b0;
                            WipeScore = 1'b1;
                        end
                endcase
            
            
            mainmenu2 : // Top button (Play AI) selected
                case (Inputs)
                    8'h1A : // W
                        nextstate = mainmenu2; // Top button (stay)
                    8'h04 : // A
                        nextstate = mainmenu2;  // Top button (stay)
                    8'h16 : // S
                        nextstate = mainmenu3; // Other button
                    8'h07 : // D
                        nextstate = mainmenu2; // Top button (stay)
                    8'h28 : // ENTER
                        begin
                            nextstate = gameon; // Start game
                            Mode = 1'b0; // AI Mode
                        end
                    default :
                        begin
                            nextstate = mainmenu2; // Stay
                            MainMenuOn = 2'b01;
                            GameStart = 1'b0;
                            GameOver = 1'b0;
                            WipeScore = 1'b1;
                        end
                endcase
            
            
            mainmenu3 : // Bottom button (Play 2P) selected
                case (Inputs)
                    8'h1A : // W
                        nextstate = mainmenu2; // Other button
                    8'h04 : // A
                        nextstate = mainmenu3;  // Bot button (stay)
                    8'h16 : // S
                        nextstate = mainmenu3; // Bot Button (stay)
                    8'h07 : // D
                        nextstate = mainmenu3; // Bot button (stay)
                    8'h28 : // ENTER
                        begin
                            nextstate = gameon; // Start game
                            Mode = 1'b1; // Power mode
                        end
                    default :
                        begin
                            nextstate = mainmenu3; // Stay
                            MainMenuOn = 2'b10;
                            GameStart = 1'b0;
                            GameOver = 1'b0;
                            WipeScore = 1'b1;
                        end
                endcase
            
            
            gameon : 
                case (TimeOver) // Use input from scoreboard timer
                    1'b1 : // Time has run out, move to scoreboard
                        nextstate = mainmenu1; // scoreboard before
                    default :
                        begin
                            nextstate = gameon;
                            MainMenuOn = 2'b11;
                            GameStart = 1'b1;
                            GameOver = 1'b0;
                            WipeScore = 1'b0;
                        end
                endcase
            
            
            scoreboard :
                case (Inputs) // Hit enter to go back to main menu
                    8'h28 : // ENTER
                        nextstate = mainmenu2;
                    default :
                        begin
                            nextstate = scoreboard;
                            MainMenuOn = 2'b11;
                            GameStart = 1'b0;
                            GameOver = 1'b1;
                            WipeScore = 1'b0;
                        end
                endcase
        endcase
    end
endmodule

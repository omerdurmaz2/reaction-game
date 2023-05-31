/*module devre(output reg [1:3] s, input b1, input b2);
    always @ (b1,b2) begin 
        if(!b1 && !b2)
            s=3'b011;
        if(b1 && !b2)
            s=3'b101;
        if(!b1 && b2)
            s=3'b110;
        if(b1 && b2)
            s=3'b000;
    end
endmodule



module led (
    input sys_clk,
    input sys_rst_n,
    output reg [2:0] led // 110 R, 101 B, 011 G
);

reg [31:0] counter;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        counter <= 31'd0;
        led <= 3'b110;
    end
    else if (counter < 31'd1350_0000)       // 0.5s delay
        counter <= counter + 1;
    else begin
        counter <= 31'd0;
        led[2:0] <= {led[1:0],led[2]};
    end
end

endmodule*/

module ReactionGame (
    input wire clk,
    input wire reset,
    input wire button,
    output wire [3:0] leds
);

reg [3:0] led_counter;
reg [3:0] reaction_time;
reg [3:0] best_time;
reg game_start;
reg game_over;
reg button_pressed;
reg [15:0] timer;

parameter GAME_DURATION = 16'd10; 

always @(posedge clk) begin
    if (reset) begin
        led_counter <= 4'b0000;
        reaction_time <= 4'b0000;
        best_time <= 4'b1111;
        game_start <= 1'b0;
        game_over <= 1'b0;
        button_pressed <= 1'b0;
        timer <= 16'd0;
    end else begin
        if (game_start && !game_over) begin
            timer <= timer + 16'd1;
        end
        
        if (timer >= GAME_DURATION) begin
            game_over <= 1'b1;
        end
        
        if (button && !button_pressed && game_start && !game_over) begin
            button_pressed <= 1'b1;
            reaction_time <= timer[3:0];
            timer <= 16'd0;
            
            if (reaction_time < best_time) begin
                best_time <= reaction_time;
            end
        end else if (!button) begin
            button_pressed <= 1'b0;
        end
        
        if (led_counter == reaction_time && game_start && !game_over) begin
            led_counter <= led_counter + 1;
        end else if (led_counter == 4'd9) begin
            led_counter <= 4'b0000;
            game_start <= 1'b1;
        end else if (game_over) begin
            led_counter <= 4'b0000;
            game_start <= 1'b0;
        end else begin
            led_counter <= led_counter;
        end
    end
end

assign leds = (game_start && !game_over) ? (led_counter == reaction_time) ? 4'b1111 : 4'b0000 : (game_over) ? 4'b1111 : 4'b0000;

endmodule
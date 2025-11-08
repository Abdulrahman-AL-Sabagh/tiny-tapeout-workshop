`timescale 1ns/1ps

module four_connect_tb;
	
	// Inputs to UUT
	reg clk_in = 1'b0;
	reg toggle0 = 1'b0;
	reg [5:0] buttons = 6'h3F; // Assume Active-Low: '111111' means released.

	// Output from UUT (Only ws_data remains)
	wire ws_data;

	// Clock generator (100MHz / 5ns period)
	always #5 clk_in = ~clk_in; 

	// Instantiate the Device Under Test (UUT)
	fourConnect uut (
		.clk_in(clk_in),
		.toggle0(toggle0),
		.buttons(buttons),
		.ws_data(ws_data)
	);

	// --- Task for Button Press (Active-Low) ---
    // Simulates pressing one button and releasing it.
	task press_button;
        input [5:0] active_low_mask; // e.g., 6'b111110 (Button 0 pressed)
        begin
            $display("@%0t: PRESS - Setting buttons to %b", $time, active_low_mask);
            buttons = active_low_mask;
            #20; // Wait 2 clock cycles to ensure state change
            $display("@%0t: RELEASE - Setting buttons to 6'h3F", $time);
            buttons = 6'h3F; // All released
            #20;
        end
    endtask

	initial begin
		$display("=== Starting fourConnect Debug Testbench ===");
		$dumpfile("fourConnect_tb.vcd");
		$dumpvars(0, four_connect_tb);
        // Dump the internal memory array for full visibility
        for (integer i = 0; i < 64; i = i + 1) begin
            $dumpvars(0, uut.ws2812_inst.led_reg[i]);
        end 
		
		// Initial Delay
		#20; 
		
		// --- TEST CASE 1: Test the toggle0 input ---
        // Expect: LED 1 is set to RED in the WS2812 internal memory (led_reg[1])
		$display("\n[TEST 1] Testing toggle0 (Expected: uut.ws2812_inst.led_reg[0] = YELLOW)");
        
        toggle0 = 1'b1;
        #10; // Wait 1 clock cycle for synchronous logic to update
        
        // 1. Check the inputs to the WS2812 core (uut.led_num and uut.color)
        if (uut.led_num == 7'd0 && uut.color == 24'hFFFF00 && uut.write == 1'b1) begin
             $display("PASS: Inputs to WS2812 are correct (LED 0, YELLOW, Write=1).");
        end else begin
            $error("FAIL: Inputs to WS2812 are incorrect (L:%0d, C:0x%06h, W:%0d)", 
                    uut.led_num, uut.color, uut.write);
        end

        // 2. Check the final state in the WS2812 internal memory array
        if (uut.ws2812_inst.led_reg[1] == 24'hFF0000) begin
            $display("PASS: Internal LED memory (led_reg[1]) successfully updated to RED.");
        end else begin
            $error("FAIL: Internal LED memory (led_reg[1]) expected 0xFF0000, got 0x%06h", 
                    uut.ws2812_inst.led_reg[1]);
        end
        
        toggle0 = 1'b0; // Reset toggle0
        #20; 

        // --- TEST CASE 2: Test Button 0 (LSB) ---
        // Expect: LED 1 is set to WHITE in the WS2812 internal memory (led_reg[1])
		$display("\n[TEST 2] Testing Button 0 (Expected: uut.ws2812_inst.led_reg[1] = WHITE)");
        
        // Press button 0 (Active-low mask: 6'b111110)
        press_button(6'b111110); 
        
        // Check 1: Check the inputs to the WS2812 core (uut.led_num and uut.color)
        // Since the button is pressed, the inputs should be asserted immediately
        if (uut.led_num == 7'd1 && uut.color == 24'hFFFFFF && uut.write == 1'b1) begin
             $display("PASS: Inputs to WS2812 are correct (LED 1, WHITE, Write=1).");
        end else begin
            $error("FAIL: Inputs to WS2812 are incorrect (L:%0d, C:0x%06h, W:%0d)", 
                    uut.led_num, uut.color, uut.write);
        end
        
        // 2. Check the final state in the WS2812 internal memory array
        if (uut.ws2812_inst.led_reg[1] == 24'hFFFFFF) begin
            $display("PASS: Internal LED memory (led_reg[1]) successfully updated to WHITE.");
        end else begin
            $error("FAIL: Internal LED memory (led_reg[1]) expected 0xFFFFFF, got 0x%06h", 
                    uut.ws2812_inst.led_reg[1]);
        end
		
		#50;
		$finish;
	end

endmodule

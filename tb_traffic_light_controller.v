`timescale 1ns/1ps

module testbench;

    // Inputs to the UUT (Unit Under Test)
    logic clk;
    logic reset;

    // Outputs from the UUT
    logic [2:0] lights_ns;
    logic [2:0] lights_ew;

    // Instantiate the Unit Under Test (UUT)
    traffic_light_controller uut (
        .clk(clk),
        .reset(reset),
        .lights_ns(lights_ns),
        .lights_ew(lights_ew)
    );

    // 1. Generate standard clock signal (Period = 10ns -> Toggle every 5ns)
    always begin
        #5 clk = ~clk;
    end

    // 2. Test Sequence
    initial begin
        // Setup waveform dumping for EDA Playground EPWave viewer
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        // Initialize signals
        clk = 0;
        reset = 1;

        // Hold reset active for 20ns
        #20;
        reset = 0;

        // Run the simulation long enough to watch multiple full cycles 
        // 1 cycle = Green(10) + Yellow(3) + Green(10) + Yellow(3) = 26 cycles * 10ns = 260ns
        #350;

        // End simulation
        $display("Simulation finished successfully.");
        $finish;
    end

endmodule

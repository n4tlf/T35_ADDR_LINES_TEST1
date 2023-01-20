/********************************************************************
*   FILE:  T35_ADDR_LINES_TEST1_top.v                               *
*                                                                   *
*   This is a simple project that increments the S-100 Address      *
*   lines on John Monahan's FPGA SBC board via the T35.             *
*   Adress lines 0-15 increment up at a 1MHz rate using PLL0        *
*   while address lines 16-19 count backwards (19 - 16).            *
*   TFOX, N4TLF September 11, 2022   You are free to use it         *
*       however you like.  No warranty expressed or implied         *
*                                                                   *
*   A 27-bit counter is used to divide the 2MHz PLL clock output    *
        to various slower frequencies                               *
*   This version runs much slower (helping with visual inspection). *
*       Adjusting the "assign" statements for the two Address and   *
*       SBCLEDS busses can change the operating speed.              *
*   Currently, A0 runs at approx. 488Hz, SBCLED D0 approx 2Hz.      *
*   Assign S100adr0_15 to counter[15:0] sets A0 to ap0prox. 1MHz    *
********************************************************************/

module  T35_ADDR_LINES_TEST1_top (
    n_reset,            // Reset to T25 board is active low
    pll0_LOCKED,        // signal shows the PLL is locked
    pll0_2MHz,          // 2MHz PLL out that is "master" clock signal
    n_boardReset,       // on board reset push button
    S100adr0_15,        // The regular 16 address bits
    S100adr16_19,       // These are wires backwards, so
                        // lowest bit is A19, highest is A16
    SBCLEDS,            // The SBC LEDs also show activity
    pDBIN,              // S100 pDBIN (proc. Data Bus In signal)
    pSYNC,              // S100 pSYNC (proc. Sync signal)
    pSTVAL,             // S100 pSTVAL (proc. Status Valid)
    n_pWR,              // Active low processor write signal
    sMWRT,              // proc. Status Memory Write signal
    seg7,               // T35 seven-segment display bus
    seg7_dp,            // T35 seven-segment decimal point
                        //   used as a visual "heartbeat"
    boardActive,        // SBC LED to show board is active
    F_add_oe,           // FPGA SBC drivers Address output enable
    F_bus_stat_oe,      // FPGA SBC Status output enable
    F_bus_ctl_oe);      // FPGA SBC Control output enable
        
    input   n_reset;            // active low eset fom S100 bus
    input   pll0_LOCKED;        // PLL is locked (good)
    input   pll0_2MHz;          // 2MHz PLL Clock signal
    input   n_boardReset;       // onboard active low reset
    output  [15:0] S100adr0_15; // S100 Address bus 0:15
    output  [3:0] S100adr16_19; // S100 Address but 16-19
    output  [7:0] SBCLEDS;      // "F_BAR" LEDs on SBC board
    output  pDBIN;              // GPIOT_RXP21
    output  pSYNC;              // GPIOT_RXP20
    output  pSTVAL;             // GPIOT_RXN21
    output  n_pWR;              // GPIOT_RXP20
    output  sMWRT;              // GPIOR_121
    output  [6:0] seg7;         // T35 7-segment output bus
    output  seg7_dp;            // T35 7-segment decimal point
    output  boardActive;        // GPIOT_RXN20
    output  F_add_oe;           // GPIOB_TXN17
    output  F_bus_stat_oe;      // GPIOB_TXN19
    output  F_bus_ctl_oe;       // GPUIOR_120

reg [26:0]  counter;            // 27-bit counter for A0 to A15

assign F_add_oe = 0;                    // enable address outputs
assign F_bus_stat_oe = 0;               // enable CPU Status outputs
assign F_bus_ctl_oe = 0;                // enable CPU Control outp[uts
assign S100adr0_15 = counter[26:11];    // Change to [15:0] for A0=1MHz
assign S100adr16_19 = counter[21:18];   // run Address 16-19 backwards
assign boardActive = pll0_LOCKED;       // Show that the PLL is locked
assign SBCLEDS = ~(counter[26:19]);     // LEDs active low, complement
assign pDBIN = !pll0_2MHz;              // Fake an S100 pDBIN signal
assign pSYNC = pll0_2MHz;               // Fake an S100 pSYNC signal
assign pSTVAL = !pll0_2MHz;             // Fake an S100 pSTVAL signal
assign n_pWR = 1'b1;                    // keep processor write high
assign sMWRT = 1'b0;                    // keep memory write low

assign seg7 = 7'b1111001;           // Set T35 7-segment to the number "1"
assign seg7_dp = counter[20];       // blink T35 decimal point roughly 1sec

always @(posedge pll0_2MHz)         // at every positive edge of 2MHz PLL out,
    begin
        if((n_reset == 0) | (n_boardReset == 0)) begin  // if reset set low...
            counter <= 27'b0;           // reset counter to 0
        end                             // end of resetting everything
        else
            counter <= counter + 1;     // just increment counter
                                        // it falls through max back to zero
    end
endmodule

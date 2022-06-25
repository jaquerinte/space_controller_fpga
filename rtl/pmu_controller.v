`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/25/2022 03:22:37 PM
// Design Name: 
// Module Name: pmu_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pmu_controller#(
    // Users to add parameters here
    parameter COUNTERSIZE = 8,
    parameter REGISTER_SIZE = 4,
    parameter SIZE_WORD = 3,
    parameter DATA_WIDTH = 8,
    parameter SYMBOL_WITH = 4,
    parameter BAUD_RATE = 115200,
    parameter CLOCK_SPEED = 125000000,
    parameter [8:0]ESCAPE_CHARCTER = 8'h0D,
    parameter [8:0]CLEAN_CHARCTER = 8'h20,
    parameter [8:0]LINEFEED = 8'h0A,
    parameter [8:0]NEWLINE = 8'h0D
	)
(
    
    input  wire clk,
    input  wire rst,
    input  wire rxd_pmu,
    input  wire [2:0] trx_error,
    input  wire [2:0] output_io_error,
    input  wire [2:0] command_arrive,
    input  wire  [2:0] command_arrive_discrepancy,
    output wire  txd_pmu

    );


    (* mark_debug = "true" *)reg [REGISTER_SIZE-1:0] pmu_register;
    (* mark_debug = "true" *)reg [REGISTER_SIZE-1:0] input_data;
    (* mark_debug = "true" *)reg valid_pmu_register;

    (* mark_debug = "true" *)wire valid_value;
    (* mark_debug = "true" *)wire [COUNTERSIZE-1:0] pmu_value;

    reg [15:0] preescalar_data_rate = CLOCK_SPEED/(BAUD_RATE*DATA_WIDTH);

    // create register for the input and output of the data
    (* mark_debug = "true" *)reg [DATA_WIDTH-1:0] uart_tx_axis_tdata;
    reg uart_tx_axis_tvalid;
    wire uart_tx_axis_tready;

    //(* mark_debug = "true" *) 
    (* mark_debug = "true" *)wire [DATA_WIDTH-1:0] uart_rx_axis_tdata;
    wire uart_rx_axis_tvalid;
    reg uart_rx_axis_tready;

    // create the register for store the data to be send
    (* mark_debug = "true" *)  reg [(COUNTERSIZE * 4)-1:0] send_data_register;
    // register to now if is sending data
    (* mark_debug = "true" *)  reg sending_data;
    // regsiter to store the actual size
    (* mark_debug = "true" *)reg [SIZE_WORD-1:0] data_size_actual;

    // pmu module to record the data
    pmu_module #(
        .COUNTERSIZE(COUNTERSIZE),
        .REGISTER_SIZE(REGISTER_SIZE)
        ) pmu_module_inst(
            .clk(clk),
            .rst(rst),
            .trx_error(trx_error),
            .output_io_error(output_io_error),
            .command_arrive(command_arrive),
            .command_arrive_discrepancy(command_arrive_discrepancy),
            .pmu_register(pmu_register),
            .valid_pmu_register(valid_pmu_register),
            .pmu_value(pmu_value),
            .valid_value(valid_value)
            );

    // UART communication module
    uart #(
        .DATA_WIDTH(DATA_WIDTH)
    )
    uart_inst_pmu(
        .clk(clk),
        .rst(rst),
        .prescale (preescalar_data_rate),
        .s_axis_tdata(uart_tx_axis_tdata),
        .s_axis_tvalid(uart_tx_axis_tvalid),
        .s_axis_tready(uart_tx_axis_tready),
        // AXI output
        .m_axis_tdata(uart_rx_axis_tdata),
        .m_axis_tvalid(uart_rx_axis_tvalid),
        .m_axis_tready(uart_rx_axis_tready),
        .rxd(rxd_pmu),
        .txd(txd_pmu),
        .tx_busy(),
        .rx_busy(),
        .rx_overrun_error(),
        .rx_frame_error()
    );


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            uart_tx_axis_tdata <= 0;
            uart_rx_axis_tready <= 0;
            uart_tx_axis_tvalid <= 0;
            data_size_actual <= 0; 
            send_data_register <= 0;
            sending_data <= 0;
            pmu_register <= 0;
            input_data <= 0;
            valid_pmu_register <= 1'b0;
        end
        else begin
                if (uart_tx_axis_tvalid) begin
                // attempting to transmit a byte
                // so can't receive one at the moment
                uart_rx_axis_tready <= 0;
                // if it has been received, then clear the valid flag
                if (uart_tx_axis_tready) begin
                    uart_tx_axis_tvalid <= 0;
                end
            end
            // process if we are sending data
            else if (sending_data) begin
                // now the control value is not valid
                valid_pmu_register <= 1'b0;
                if (data_size_actual == 3'b000)begin
                    // end sending words
                    send_data_register <= 0;
                    sending_data <= 0;
                    uart_tx_axis_tvalid <= 0;
                end
                else begin
                    // reduce by one the size
                    data_size_actual <= data_size_actual - 1'b1;
                    // transmit enable
                    uart_tx_axis_tvalid <= 1'b1;
                    // data to be send
                    uart_tx_axis_tdata <= send_data_register[DATA_WIDTH-1: 0];
                    // shift the value
                    send_data_register <= send_data_register >> DATA_WIDTH;
                end
            end
            // if a signal to send a word has been recibed
            if (valid_value) begin
                // now the control value is not valid
                valid_pmu_register <= 1'b0;
                // set all of the variables
                sending_data <= 1'b1;
                // set the value of the data to be send
                uart_tx_axis_tvalid <= 0;
                // convert the data to ASCII
                // first half of the word that is the first 4 bits from pmu_value and the other 4 bits are 3 in hezxadecimal
                send_data_register[7: 0] <= {4'h3,pmu_value[7: 4]} ;
                // second half of the word that is the last 4 bits from pmu_value and the other 4 bits are 3 in hezxadecimal
                send_data_register[(COUNTERSIZE * 2)-1: (COUNTERSIZE)] <=   {4'h3,pmu_value[3: 0]};
                // third half of the word that is the first 4 bits for the ASCII newline
                send_data_register[(COUNTERSIZE * 3)-1: (COUNTERSIZE * 2)] <= LINEFEED;
                send_data_register[(COUNTERSIZE * 4)-1: (COUNTERSIZE * 3)] <= NEWLINE;
                data_size_actual <= 3'h4; // DATA_WIDTH/2 because the data is in ASCII so one hex is for the ASCII and the other for the value
            end
            else begin
                // ready to receive byte
                uart_rx_axis_tready <= 1;
                valid_pmu_register <= 1'b0;
                if (uart_rx_axis_tvalid) begin
                    // got one, so make sure it gets the correct ready signal
                    // (either clear it if it was set or set it if we just got a
                    // byte out of waiting for the transmitter to send one)
                    uart_rx_axis_tready <= ~uart_rx_axis_tready;
                    // move the shift register 
                    input_data <= input_data << SYMBOL_WITH;
                    input_data [SYMBOL_WITH-1: 0] <= uart_rx_axis_tdata[SYMBOL_WITH-1:0];
                    // if if wnd code recibed 
                    if ( uart_rx_axis_tdata == ESCAPE_CHARCTER)
                    begin
                        valid_pmu_register <= 1'b1;
                        pmu_register <= input_data;
                        input_data <= 0;
                        
                    end
                    else if ( uart_rx_axis_tdata == CLEAN_CHARCTER) begin
                        input_data <= 0;
                    end
                    else begin
                        valid_pmu_register <= 1'b0;
                    end
                    
                end
            end
        end
    end

endmodule

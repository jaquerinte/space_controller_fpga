`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2021 10:43:06 AM
// Design Name: 
// Module Name: top_module
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
module top_module #
(
    parameter WORD_SIZE = 32,
    parameter SIZE_WORD = 3,
    parameter INPUT_DATA_SIZE = 52,
    parameter STATUS_SIGNALS = 6,
    parameter DATA_WIDTH = 8,
    parameter BAUD_RATE = 115200,
    parameter CLOCK_SPEED = 125000000,
    parameter OUTPUTS = 32,
    parameter INPUTS = 32,
    parameter COUNTERSIZE = 8
)
(
    input wire clk,
    input wire btn,
    input wire rxd,
    input wire rxd_pmu,
    input wire [3:0] sw,
    output wire [3:0] led,
    output wire txd,
    output wire txd_pmu
);

    wire rst;

    wire [INPUTS  - 1: 0] inputs;
    wire [OUTPUTS - 1 :0] outputs;
    wire [2:0] trx_error;
    wire [2:0] io_error; 
    wire [2:0] command_arrive;
    wire [2:0] command_arrive_discrepancy;

    
    assign rst = btn;
    assign inputs[3:0] = sw;
    assign led = outputs[3:0];


    main_gpio_complex #(
        .WORD_SIZE(WORD_SIZE),
        .SIZE_WORD(SIZE_WORD),
        .STATUS_SIGNALS(STATUS_SIGNALS),
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_DATA_SIZE(INPUT_DATA_SIZE),
        .OUTPUTS(OUTPUTS),
        .INPUTS(INPUTS),
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_SPEED(CLOCK_SPEED)
    )main_gpio_complex_inst(
        .clk(clk),
        .rst(rst),
        .rx(rxd),
        .tx(txd),
        .input_io(inputs),
        .output_io_signal(outputs),
        .trx_error(trx_error),
        .output_io_error(io_error),
        .command_arrive(command_arrive),
        .command_arrive_discrepancy(command_arrive_discrepancy)
    );

    pmu_controller #(
        .SIZE_WORD(SIZE_WORD),
        .DATA_WIDTH(DATA_WIDTH),
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_SPEED(CLOCK_SPEED),
        .COUNTERSIZE(COUNTERSIZE)
    )pmu_controller_inst(
        .clk(clk),
        .rst(rst),
        .rxd_pmu(rxd_pmu),
        .txd_pmu(txd_pmu),
        .trx_error(trx_error),
        .output_io_error(io_error),
        .command_arrive(command_arrive),
        .command_arrive_discrepancy(command_arrive_discrepancy)
    );

endmodule
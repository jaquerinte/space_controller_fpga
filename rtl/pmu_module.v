`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2022 08:58:41 PM
// Design Name: 
// Module Name: pmu_module
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


module pmu_module #
(
    // Users to add parameters here
    parameter COUNTERSIZE = 8,
    parameter REGISTER_SIZE = 4
	)
(
    input clk,
    input rst,
    input  wire [2:0] trx_error,
    input  wire [2:0] output_io_error,
    input  wire [2:0] command_arrive,
    input  wire  [2:0] command_arrive_discrepancy,
    input  wire  [REGISTER_SIZE-1:0] pmu_register,
    input  wire  valid_pmu_register,
    output reg  [COUNTERSIZE-1:0] pmu_value,
    output reg  valid_value

    );

    reg [COUNTERSIZE-1:0] total_errors_trx                  [0:2];
    reg [COUNTERSIZE-1:0] total_errors_io                   [0:2];
    reg [COUNTERSIZE-1:0] total_command_arrive              [0:2];
    reg [COUNTERSIZE-1:0] total_command_arrive_discrepancy  [0:2];
    reg [COUNTERSIZE-1:0] total_unrecobable_errors_trx;
    reg [COUNTERSIZE-1:0] total_unrecobable_errors_io;
    reg [COUNTERSIZE-1:0] total_unrecobable_commands;
    (* mark_debug = "true" *) reg [COUNTERSIZE-1:0] total_request;


    always @(posedge clk) begin
        if (rst) begin
            total_errors_trx[0]                 <= {COUNTERSIZE {1'b0}};
            total_errors_trx[1]                 <= {COUNTERSIZE {1'b0}};
            total_errors_trx[2]                 <= {COUNTERSIZE {1'b0}};
            total_errors_io[0]                  <= {COUNTERSIZE {1'b0}};
            total_errors_io[1]                  <= {COUNTERSIZE {1'b0}};
            total_errors_io[2]                  <= {COUNTERSIZE {1'b0}};
            total_command_arrive[0]             <= {COUNTERSIZE {1'b0}};
            total_command_arrive[1]             <= {COUNTERSIZE {1'b0}};
            total_command_arrive[2]             <= {COUNTERSIZE {1'b0}};
            total_command_arrive_discrepancy[0] <= {COUNTERSIZE {1'b0}};
            total_command_arrive_discrepancy[1] <= {COUNTERSIZE {1'b0}};
            total_command_arrive_discrepancy[2] <= {COUNTERSIZE {1'b0}};
            total_unrecobable_errors_trx        <= {COUNTERSIZE {1'b0}};
            total_unrecobable_errors_io         <= {COUNTERSIZE {1'b0}};
            total_unrecobable_commands          <= {COUNTERSIZE {1'b0}};
            total_request                       <= {COUNTERSIZE {1'b0}};
            valid_value                         <= 1'b0;
            pmu_value                           <= {COUNTERSIZE {1'b0}};
        end
        else begin
            // reseting valid_value
            valid_value <= 1'b0;
            // couting errors 
            if (trx_error != 3'b000) begin
                case (trx_error)
                    3'b001:  total_errors_trx[0] <= total_errors_trx[0] + 1;
                    3'b010:  total_errors_trx[1] <= total_errors_trx[1] + 1;
                    3'b100:  total_errors_trx[2] <= total_errors_trx[2] + 1;
                    default: total_unrecobable_errors_trx <= total_unrecobable_errors_trx + 1;
                endcase
            end 
            if (output_io_error != 3'b000) begin
                case (trx_error)
                    3'b001:  total_errors_io[0] <= total_errors_io[0] + 1;
                    3'b010:  total_errors_io[1] <= total_errors_io[1] + 1;
                    3'b100:  total_errors_io[2] <= total_errors_io[2] + 1;
                    default: total_unrecobable_errors_io <= total_unrecobable_errors_io + 1;
                endcase
            end
            if (command_arrive != 3'b000) begin
                // general counter
                total_request <= total_request +1;
                // specific counter
                total_command_arrive[0] <=  total_command_arrive[0] + command_arrive[0];
                total_command_arrive[1] <=  total_command_arrive[1] + command_arrive[1];
                total_command_arrive[2] <=  total_command_arrive[2] + command_arrive[2];
            end
            if (command_arrive_discrepancy != 3'b000) begin
                case (trx_error)
                    3'b001:  total_command_arrive_discrepancy[0] <= total_command_arrive_discrepancy[0] + 1;
                    3'b010:  total_command_arrive_discrepancy[1] <= total_command_arrive_discrepancy[1] + 1;
                    3'b100:  total_command_arrive_discrepancy[2] <= total_command_arrive_discrepancy[2] + 1;
                    default: total_unrecobable_commands <= total_unrecobable_commands + 1;
                endcase
            end

        end
        // PMU response
        if (valid_pmu_register) begin
            case (pmu_register)
                4'h0: pmu_value <= total_request;
                4'h1: pmu_value <= total_unrecobable_commands;
                4'h2: pmu_value <= total_unrecobable_errors_trx;
                4'h3: pmu_value <= total_unrecobable_errors_io;
                4'h4: pmu_value <= total_command_arrive[0];
                4'h5: pmu_value <= total_command_arrive[1];
                4'h6: pmu_value <= total_command_arrive[2];
                4'h7: pmu_value <= total_command_arrive_discrepancy[0];
                4'h8: pmu_value <= total_command_arrive_discrepancy[1];
                4'h9: pmu_value <= total_command_arrive_discrepancy[2];
                4'hA: pmu_value <= total_errors_trx[0];
                4'hB: pmu_value <= total_errors_trx[1];
                4'hC: pmu_value <= total_errors_trx[2];
                4'hD: pmu_value <= total_errors_io[0];
                4'hE: pmu_value <= total_errors_io[1];
                4'hF: pmu_value <= total_errors_io[2];
                default: pmu_value <= {COUNTERSIZE {1'b0}};
            endcase
            valid_value <= 1'b1;
        end
    end
endmodule

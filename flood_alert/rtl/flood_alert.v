
module flood_alert #(
    parameter DEBOUNCE_MAX = 4,
    parameter RISE_WINDOW  = 10
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [2:0] water,
    output reg  [1:0] alert_level,
    output reg        siren,
    output reg        sensor_fault
);

    reg [2:0] water_sync;
    reg [2:0] water_stable;
    reg [2:0] previous_water;

    reg [7:0] debounce_count;
    reg [7:0] rise_count;

    reg [1:0] water_level;
    reg [1:0] previous_level;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            water_sync     <= 3'b000;
            water_stable   <= 3'b000;
            previous_water <= 3'b000;
            debounce_count <= 0;
            rise_count     <= 0;
            water_level    <= 0;
            previous_level <= 0;
            alert_level    <= 0;
            siren          <= 0;
            sensor_fault   <= 0;
        end else begin
            water_sync <= water;

            if (water_sync == water_stable) begin
                debounce_count <= 0;
            end else if (debounce_count >= DEBOUNCE_MAX) begin
                water_stable <= water_sync;
                debounce_count <= 0;
            end else begin
                debounce_count <= debounce_count + 1;
            end

            sensor_fault <=
                (water_stable == 3'b010) ||
                (water_stable == 3'b101);

            case (water_stable)
                3'b000: water_level <= 0;
                3'b001: water_level <= 1;
                3'b011: water_level <= 2;
                3'b111: water_level <= 3;
                default: water_level <= water_level;
            endcase

            if (water_level > previous_level) begin
                rise_count <= 0;
                previous_level <= water_level;

                if (water_level - previous_level >= 2)
                    alert_level <= 3;
                else if (alert_level < water_level)
                    alert_level <= water_level;
            end else if (rise_count < RISE_WINDOW) begin
                rise_count <= rise_count + 1;
            end else begin
                previous_level <= water_level;
            end

            if (alert_level >= 2 || sensor_fault)
                siren <= 1;
            else
                siren <= 0;
        end
    end

endmodule

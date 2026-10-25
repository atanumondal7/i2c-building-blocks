module i2c_shift_register (
input logic clk,
input logic rst_n,
input logic load,
input logic shift_en,
input logic direction,
input logic [7:0] p_data_in,
output logic [7:0] p_data_out,
input logic s_data_in,
output logic s_data_out,
output logic byte_done
);

logic [7:0] shift_reg;
logic [2:0] bit_cnt;

typedef enum logic [1:0] {
IDLE = 2'b00,
LOAD = 2'b01,
SHIFT = 2'b10,
DONE = 2'b11,
} state_t;

state_t current_state, next_state;

always_ff @(posedge clk) begin

if(!rst_n) begin
next_state <= IDLE;
end

else begin
next_state <= current_state
end

end

always_comb begin

case(current_state)

IDLE: begin
if(load) begin
next_state = LOAD;
end
else if(shift_en && !load) begin
next_state = SHIFT;
end
else begin
next_state = IDLE;
end
end

LOAD: begin
if(shift_en) begin
next_state = SHIFT;
end

SHIFT: begin
if(shift_en && bit_cnt == 3'd7) begin
next_state = DONE;
end
else begin
next_state = SHIFT;
end

DONE: begin
if(load) begin
next_state = LOAD
end
else begin
next_state = IDLE;
end
end

end

always_ff @(posedge clk) begin

case(current_state)

IDLE: begin
byte_done = 1'b0;
end

LOAD: begin
shift_reg <= p_data_in;
bit_cnt <= 1'b0;
end
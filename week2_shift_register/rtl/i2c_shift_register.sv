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
DONE = 2'b11
} state_t;

state_t current_state, next_state;

always_ff @(posedge clk) begin

if(!rst_n) begin
current_state <= IDLE;
end

else begin
current_state <= next_state;
end

end

always_comb begin

next_state = current_state;

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
else begin
next_state = IDLE;
end
end

SHIFT: begin
if(load) begin
next_state = LOAD;
end
else if(shift_en && bit_cnt == 3'd7) begin
next_state = DONE;
end
else begin
next_state = SHIFT;
end
end

DONE: begin
if(load) begin
next_state = LOAD;
end
else begin
next_state = IDLE;
end
end

default: next_state = current_state;

endcase

end

always_ff @(posedge clk) begin

if(!rst_n) begin
shift_reg <= '0;
bit_cnt <= '0;
end

else begin

case(current_state)

LOAD: begin
shift_reg <= p_data_in;
bit_cnt <= '0;
end

SHIFT: begin
if(shift_en) begin
if(!direction) begin
shift_reg <= {shift_reg[6:0], s_data_in};
end
else begin
shift_reg <= {s_data_in, shift_reg[7:1]};
end
bit_cnt <= bit_cnt + 1'b1;
end
end

DONE: begin
bit_cnt <= '0;
end

default: ;

endcase
end

end

assign byte_done = (current_state == DONE);
assign p_data_out = shift_reg;
assign s_data_out = direction ? shift_reg[0]:shift_reg[7];

endmodule
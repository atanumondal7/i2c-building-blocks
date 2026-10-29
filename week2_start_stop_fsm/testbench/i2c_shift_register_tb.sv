module i2c_shift_register_tb;

logic clk = 0;
logic rst_n;
logic load;
logic shift_en;
logic direction;
logic [7:0] p_data_in;
logic [7:0] p_data_out;
logic s_data_in;
logic s_data_out;
logic byte_done;

i2c_shift_register dut (
.clk(clk),
.rst_n(rst_n),
.load(load),
.shift_en(shift_en),
.direction(direction),
.p_data_in(p_data_in),
.p_data_out(p_data_out),
.s_data_in(s_data_in),
.s_data_out(s_data_out),
.byte_done(byte_done)
);

always #5 clk = ~clk;

typedef enum logic [1:0] {
IDLE = 2'b00,
LOAD = 2'b01,
SHIFT = 2'b10,
DONE = 2'b11
} state_t;

state_t current_state, next_state;
logic [7:0] m_shift_reg;
logic [2:0] m_bit_cnt;

task automatic check();

if(!rst_n) begin
next_state = IDLE;
m_shift_reg = '0;
m_bit_cnt = '0;
current_state = next_state;
end
else begin

current_state = next_state;

case (current_state)

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

else if(shift_en && m_bit_cnt == 3'd7) begin
next_state = DONE;
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

default: ;
endcase

case(current_state) 

LOAD: begin
m_shift_reg = p_data_in;
m_bit_cnt = '0;
end

SHIFT: begin
if(shift_en) begin
if(direction) begin
m_shift_reg = {s_data_in, m_shift_reg[7:1]};
end
else begin
m_shift_reg = {m_shift_reg[6:0], s_data_in};
end
m_bit_cnt = m_bit_cnt + 1'b1;
end
end

DONE: begin
m_bit_cnt = '0;
end

default: ;

endcase

current_state = next_state;

end
endtask

int pass = 0;
int errors = 0;

always @(posedge clk) begin
check();
#1;
if(p_data_out === m_shift_reg && byte_done === (current_state == DONE) && s_data_out === (direction ? m_shift_reg[0] : m_shift_reg[7])) begin
$display("(%0t) [SUCCESS] Inputs: rst_n=%0b, load=%0b, shift_en=%0b, direction=%0b, p_data_in=%b, s_data_in=%0b | Outputs: p_data_out=%b, s_data_out=%0b, byte_done = %0b", $time, rst_n, load, shift_en, direction, p_data_in, s_data_in, p_data_out, s_data_out, byte_done);
++pass;
end
else begin
++errors;
$display("(%0t) [ERROR] Inputs: rst_n=%0b, load=%0b, shift_en=%0b, direction=%0b, p_data_in=%b, s_data_in=%0b | Outputs: EXP - p_data_out=%b, s_data_out=%0b, byte_done = %0b ; GOT - p_data_out=%h, s_data_out=%0b, byte_done = %0b", $time, rst_n, load, shift_en, direction, p_data_in, s_data_in, m_shift_reg, s_data_out, (current_state == DONE), p_data_out, s_data_out, byte_done);
end

end

initial begin
rst_n = 0; 
load = 0;
shift_en = 0;
direction = 0;
s_data_in = 0;
p_data_in = '0;

repeat (3) begin
@(negedge clk);
end
rst_n = 1;

load = 1;
p_data_in = 8'b01010101;
@(negedge clk);
@(negedge clk);
load = 0;
shift_en = 1;
direction = 0;
s_data_in = 1;
p_data_in = '0;
repeat (10) begin
@(negedge clk);
end

shift_en = 0;
@(negedge clk);

load = 1;
p_data_in = 8'b10111010;
@(negedge clk);
@(negedge clk);
load = 0;
shift_en = 1;
direction = 1;
s_data_in = 0;
p_data_in = '0;
repeat (10) begin
@(negedge clk);
end

load = 1;
p_data_in = 8'b11000101;
@(negedge clk);
@(negedge clk);
load = 0;
shift_en = 1;
direction = 1;
p_data_in = '0;
repeat (10) begin
s_data_in = $urandom_range(0, 1);
@(negedge clk);
end

load = 1;
p_data_in = 8'b11000101;
@(negedge clk);
@(negedge clk);
load = 0;
shift_en = 1;
direction = 0;
p_data_in = '0;
repeat (10) begin
s_data_in = $urandom_range(0, 1);
@(negedge clk);
end

load = 1;
p_data_in = 8'b11000101;
@(negedge clk);
@(negedge clk);
load = 0;
shift_en = 1;
direction = 1;
p_data_in = '0;
repeat (4) begin
s_data_in = $urandom_range(0, 1);
@(negedge clk);
end
load = 1;
p_data_in = 8'b11011000;
@(negedge clk);
@(negedge clk);
load = 0;
shift_en = 1;
direction = 1;
p_data_in = '0;
repeat (6) begin
s_data_in = $urandom_range(0, 1);
@(negedge clk);
end

repeat (50) begin

@(negedge clk);
load = ($urandom_range(0, 9) == 0);
shift_en = $urandom_range(0, 1);
direction = $urandom_range(0, 1);
s_data_in = $urandom_range(0, 1);
p_data_in = $urandom;
end

$display("Done. pass=%0d, errors = %0d", pass, errors);
$finish;
end

endmodule
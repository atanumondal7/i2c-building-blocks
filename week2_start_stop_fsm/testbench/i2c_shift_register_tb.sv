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
current_state = IDLE;
m_shift_reg = '0;
m_bit_cnt = '0;
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

else if(shift_en && bit_cnt == 3'd7) begin
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

next_state = current_state;

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

DONE: begin
m_bit_cnt = '0;
end

default: ;

endcase

end
endtask

int errors = 0;

always @(posedge clk) begin
check();
if(p_data_out === m_shift_reg || byte_done === (current_state == DONE) || s_data_out !== (direction ? m_shift_reg[0] : m_shift_reg[7])) begin
$display("[SUCCESS]");
end
else begin
errors++;
$error("t=%0t MISMATCH: p_out=%h exp=%h | done=%b exp=%b | s_out=%b", $time, p_data_out, m_shift_reg, byte_done, (m_state==DONE), s_data_out);
end

end

initial begin
rst_n = 0; 
load = 0;
shift_en = 0;
direction = 0;
s_data_in = 0;
p_data_in = '0;

repeat (2000) begin

@(negedge clk);
load = ($urandom_range(0, 9) == 0);
shift_en = $urandom_range(0, 1);
direction = $urandom_range(0, 1);
s_data_in = $urandom_range(0, 1);
p_data_in = $urandom;
end

$display("Done. errors = %0d", errors);
$finish;
end

endmodule
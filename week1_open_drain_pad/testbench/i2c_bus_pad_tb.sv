module i2c_bus_pad_tb;

logic data_in;
logic drive_en;
wire bus_io;
logic data_out;

pullup(bus_io);

i2c_bus_pad dut (
.data_in(data_in),
.drive_en(drive_en),
.bus_io(bus_io),
.data_out(data_out)
);

task check();

logic t_data_out;
logic t_bus_io;

t_bus_io = (drive_en && !data_in) ? 1'b0:1'bz;
if(t_bus_io === 1'bz) begin
t_bus_io = 1'b1;
end
t_data_out = t_bus_io;

if(t_data_out == data_out && t_bus_io == bus_io) begin
$display("[SUCCESS] data_in=%0b, drive_en=%0b -> bus_io=%0b, data_out=%0b", data_in, drive_en, bus_io, data_out);
end
else begin
$display("[ERROR] data_in=%0b, drive_en=%0b -> EXP: bus_io=%0b, data_out=%0b | GOT: bus_io=%0b, data_out=%0b", data_in, drive_en, t_bus_io, t_data_out, bus_io, data_out);
end

endtask

initial begin

drive_en = 1'b1; data_in = 1'b0; #10;
check();
drive_en = 1'b1; data_in = 1'b1; #10;
check();

end

endmodule
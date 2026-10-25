module i2c_bus_pad (
input logic data_in,
input logic drive_en,
inout wire bus_io,
output logic data_out
);

assign bus_io = (drive_en && !data_in) ? 1'b0:1'bz;

assign data_out = bus_io;

endmodule
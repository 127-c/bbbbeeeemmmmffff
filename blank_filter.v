module blank_filter(
input           i_bf_clk,
input           i_bf_rstn,

//reg
input           i_bf_en,
input           i_bf_out_fen,
input           i_bf_out_ren,
input  [1:0]    i_bf_mode,
input           i_bf_pwm_ren,
input           i_bf_pwm_fen,
input  [9:0]    i_bf_num,

//io
input           i_pwm_in,
input           i_sin,

output          o_sout,
output          o_sout_pluse,//filtered edge detect
output reg      o_sout_cz_sts_set//intsts

);






















endmodule
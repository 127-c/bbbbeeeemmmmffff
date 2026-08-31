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
wire en = i_bf_en;
//==========================
reg pwm_in_d0;
reg pwm_in_d1;
reg pwm_in_d2;
wire pwm_in_r_pulse = i_bf_pwm_ren & pwm_in_d1 & (~pwm_in_d2);//rise
wire pwm_in_f_pulse = i_bf_pwm_fen & (~pwm_in_d1) & pwm_in_d2;//fall
wire pwm_in_pluse = pwm_in_r_pulse | pwm_in_f_pulse;

always@(posedge i_bf_clk or negedge i_bf_rstn)
begin
    if(i_bf_rstn == 1'b0)
        begin
            pwm_in_d0 <= 1'b0;
            pwm_in_d1 <= 1'b0;
            pwm_in_d2 <= 1'b0;
        end
    else
        begin
            pwm_in_d0 <= i_pwm_in;
            pwm_in_d1 <= pwm_in_d0;
            pwm_in_d2 <= pwm_in_d1;
        end
end

reg [9:0] fcnt;
wire      fcnt_max;
wire      fcnt_max_d; 
wire      fcnt_max_pluse;
reg       cnting_flag;// cnting flag
//=================================================
always@(posedge i_bf_clk or negedge i_bf_rstn)
begin
    if(i_bf_rstn == 1'b0)
        begin
            cnting_flag <= 1'b0;
        end
    else if (fcnt_max_pluse)
        begin
            cnting_flag <= 1'b0;
        end
    else if (pwm_in_pluse)
        begin
            cnting_flag <= 1'b1;
        end
end
//==============================================
//================begin  bf

always@(posedge i_bf_clk or negedge i_bf_rstn)
begin
    if(i_bf_rstn == 1'b0)
            fcnt <= 10'b0;

    else if (en == 1'b0)
            fcnt <= 1'b0;

    else if (i_bf_mode != 2'b11)
        begin
            if(pwm_in_pluse)
                fcnt <= 1'b1;
            else if ((fcnt != i_bf_num) && (fcnt != 1'b0))
                fcnt <= fcnt + 1'b1;
        end
    else
        begin
            if((pwm_in_pluse) && (cnting_flag == 1'b0))
                fcnt <= 1'b1;
            else if ((fcnt != i_bf_num) && (fcnt != 1'b0))// cnting begin 因为pwm_in_pluse 只拉高一个周期
                fcnt <= fcnt +1'b1;
        end
end

always@(posedge i_bf_clk or negedge i_bf_rstn)
begin
if(i_bf_rstn == 1'b0)
        fcnt_max_d<= 1'b0;
else if (en == 1'b0)
        fcnt_max_d<= 1'b0;
else
        fcnt_max_d <= fcnt_max;
end
assign fcnt_max = (fcnt == i_bf_num);
assign fcnt_max_pluse = fcnt_max & (~ fcnt_max_d);//fcnt max pluse
//===============================================================================
//sout generate
//wire sout
reg sout_a;
reg sout_b;
//reg sout_c;
reg sout_d;

always@(posedge i_bf_clk or negedge i_bf_rstn)
begin
    if(i_bf_rstn == 1'b0)
        sout_a <= 1'b0;
    else if (en == 1'b0)
        sout_a <= 1'b0;
    else if (fcnt_max_pluse)
        sout_a <= sin;
end

always@(posedge i_bf_clk or negedge i_bf_rstn)
begin
    if(i_bf_rstn == 1'b0)
        sout_b <= 1'b0;
    else if (en == 1'b0)
        sout_b <= 1'b0;
    else if (fcnt_max)
        sout_b <= sin;
end
//always@(posedge i_bf_clk or negedge i_bf_rstn)
//begin
//    if(i_bf_rstn == 1'b0)
//        sout_c <= 1'b0;
//    else if (en == 1'b0)
//        sout_c <= 1'b0;
//    else if (fcnt_max && pwm_in_pluse)
//        sout_c <= sin;
//end

//assign sout = by_byps ? sin   :
//                (i_bf_mode == 00)? sout_a:
//                (i_bf_mode == 01)? sout_b:
//                (i_bf_mode == 10)? sout_c:
//                (i_bf_mode == 11)? sout_a : sout_a;
//assign sout = bf_en ? sout_a :sin;
assign sout = i_bf_en ? ((i_bf_mode == 2'b01) ? sout_b : sout_a):sin;

//=====================================
//Handler
//=====================================
//sout fall rise detect
wire sout_r_pulse;
wire sout_f_pulse;
reg  sout_d;
always@(posedge i_bf_clk or negedge i_bf_rstn)
begin
    if(i_bf_rstn == 1'b0)
        sout_d <= 1'b0;
    else if (en == 1'b0)
        sout_d <= 1'b0;
    else
        sout_d <= sout;
end

assign sout_r_pulse =i_bf_out_ren & sout & (~sout_d);
assign sout_f_pulse =i_bf_out_fen & (~sout) & sout_d;
assign o_sout_pluse = sout_r_pulse | sout_f_pulse; // out !!!!!!!!

//======================================
//interrupt
always@(posedge i_bf_clk or negedge i_bf_rstn)
begin
    if(i_bf_rstn == 1'b0)
        o_sout_cz_sts_set <= 1'b0;
    else if (en == 1'b0)
        o_sout_cz_sts_set <= 1'b0;
    else if (o_sout_cz_sts_set)
        o_sout_cz_sts_set <= 1'b0; // 向寄存器发出寄存硬件拉高的脉冲。
    else if (o_sout_pluse)
        o_sout_cz_sts_set <= 1'b1;
end

endmodule








endmodule

module afe_bemf_reg(
    //apb bus
    input               presentn,
    input               pclk,
    input               penable,
    input               pwrite,
    input               psel,
    input [8:0]         paddr,
    input [15:0]        pwdata,
    input [9:0]         psecid,
    output reg [15:0]   prdata,
    output reg          pready,
    output reg          pslverr,
    //data sts reg
    output reg          ph2_vc_sts,
    input               ph2_vc_sts_set,//interupt?
    output reg          ph2_cz_sts,
    input               ph2_cz_sts_set,
    input               ph2_vout_after_bl,//bl的dvout
    input               ph2_vout_after_sf,
    output reg          ph1_vc_sts,
    input               ph1_vc_sts_set,
    output reg          ph1_cz_sts,
    input               ph1_cz_sts_set,
    input               ph1_vout_after_bl,
    input               ph1_vout_after_sf,
    output reg          ph0_vc_sts,
    input               ph0_vc_sts_set,
    output reg          ph0_cz_sts,
    input               ph0_cz_sts_set,
    input               ph0_vout_after_bl,
    input               ph0_vout_after_sf,
    output reg [1:0]    ph0_sf_mode,
    output reg          ph0_sf_en,
    output reg          ph0_inv_en,
    output reg [1:0]    ph1_sf_mode,
    output reg          ph1_sf_en,
    output reg          ph1_inv_en,
    output reg [1:0]    ph2_sf_mode,
    output reg          ph2_sf_en,
    output reg          ph2_inv_en,
    output reg [15:0]   ph0_sf_num,
    output reg [15:0]   ph1_sf_num,
    output reg [15:0]   ph2_sf_num,
    output reg        ph0_cz_inten,
    output reg        ph0_bf_out_fen,
    output reg        ph0_bf_out_ren,
    output reg [1:0]  ph0_bf_mode,
    output reg        ph0_bf_pwm_fen,
    output reg        ph0_bf_pwm_ren,
    output reg [5:0]  ph0_pwm_sel_en,
    output reg        ph0_pwm_src_sel,
    output reg        ph0_bf_en,

    output reg        ph1_cz_inten,
    output reg        ph1_bf_out_fen,
    output reg        ph1_bf_out_ren,
    output reg [1:0]  ph1_bf_mode,
    output reg        ph1_bf_pwm_fen,
    output reg        ph1_bf_pwm_ren,
    output reg [5:0]  ph1_pwm_sel_en,
    output reg        ph1_pwm_src_sel,
    output reg        ph1_bf_en,

    output reg        ph2_cz_inten,
    output reg        ph2_bf_out_fen,
    output reg        ph2_bf_out_ren,
    output reg [1:0]  ph2_bf_mode,
    output reg        ph2_bf_pwm_fe,
    output reg        ph2_bf_pwm_ren,
    output reg [5:0]  ph2_pwm_sel_en,
    output reg        ph2_pwm_src_sel,
    output reg        ph2_bf_en,
    output reg [9:0]  ph0_bf_num,
    output reg [9:0]  ph1_bf_num,
    output reg [9:0]  ph2_bf_num,
    output reg        ph0_det_high_en,
    output reg        ph0_det_rise_en,
    output reg        ph0_det_fall_en,
    output reg        ph0_vc_inten,
    output reg        ph1_det_high_en,
    output reg        ph1_det_rise_en,
    output reg        ph1_det_fall_en,
    output reg        ph1_vc_inten,
    output reg        ph2_det_high_en,
    output reg        ph2_det_rise_en,
    output reg        ph2_det_fall_en,
    output reg        ph2_vc_inten,
    output reg [1:0]  ph0_bemf_crn0,
    output reg [1:0]  ph0_bemf_crp0,
    output reg        ph0_bemf_en,
    output reg [1:0]  ph1_bemf_crn1,
    output reg [1:0]  ph1_bemf_crp1,
    output reg        ph1_bemf_en,
    output reg [1:0]  ph2_bemf_crn2,
    output reg [1:0]  ph2_bemf_crp2,
    output reg        ph2_bemf_en,
    output reg        bemf_pmsm_sel,
    output reg [1:0]  bemf_res,
    output reg [5:0]  bemf_hys_sel,
    output reg [2:0]  bemf_dly
);

parameter STS              = 9'h00;
parameter PH0_SF_CR        = 9'h02;
parameter PH1_SF_CR        = 9'h04;
parameter PH2_SF_CR        = 9'h06;
parameter PH0_SF_TIME_CFG  = 9'h08;
parameter PH1_SF_TIME_CFG  = 9'h0A;
parameter PH2_SF_TIME_CFG  = 9'h0C;
parameter PH0_BL_CR        = 9'h0E;
parameter PH1_BL_CR        = 9'h10;
parameter PH2_BL_CR        = 9'h12;
parameter PH0_BL_TIME_CFG  = 9'h14;
parameter PH1_BL_TIME_CFG  = 9'h16;
parameter PH2_BL_TIME_CFG  = 9'h18;
parameter PH0_VC_CR        = 9'h1A;
parameter PH1_VC_CR        = 9'h1C;
parameter PH2_VC_CR        = 9'h1E;
parameter ANA_BEMF_PH0_CR  = 9'h20;
parameter ANA_BEMF_PH1_CR  = 9'h22;
parameter ANA_BEMF_PH2_CR  = 9'h24;
parameter ANA_BEMF_CR      = 9'h26;

wire [15:0] sts;
wire [15:0] ph0_sf_cr;
wire [15:0] ph1_sf_cr;
wire [15:0] ph2_sf_cr;
wire [15:0] ph0_sf_time_cfg;
wire [15:0] ph1_sf_time_cfg;
wire [15:0] ph2_sf_time_cfg;
wire [15:0] ph0_bl_cr;
wire [15:0] ph1_bl_cr;
wire [15:0] ph2_bl_cr;
wire [15:0] ph0_bl_time_cfg;
wire [15:0] ph1_bl_time_cfg;
wire [15:0] ph2_bl_time_cfg;
wire [15:0] ph0_vc_cr;
wire [15:0] ph1_vc_cr;
wire [15:0] ph2_vc_cr;
wire [15:0] ana_bemf_ph0_cr;
wire [15:0] ana_bemf_ph1_cr;
wire [15:0] ana_bemf_ph2_cr;
wire [15:0] ana_bemf_cr;

wire rise_penable;
reg  [15:0] rdata;

assign sts[15:12] = 'h0;
assign sts[11]    = ph2_vc_sts;
assign sts[10]    = ph2_cz_sts;
assign sts[9]     = ph2_vout_after_bl;
assign sts[8]     = ph2_vout_after_sf;
assign sts[7]     = ph1_vc_sts;
assign sts[6]     = ph1_cz_sts;
assign sts[5]     = ph1_vout_after_bl;
assign sts[4]     = ph1_vout_after_sf;
assign sts[3]     = ph0_vc_sts;
assign sts[2]     = ph0_cz_sts;
assign sts[1]     = ph0_vout_after_bl;
assign sts[0]     = ph0_vout_after_sf;

assign ph0_sf_cr[15:4] = 'h0;
assign ph0_sf_cr[3:2]  = ph0_sf_mode;
assign ph0_sf_cr[1]    = ph0_sf_en;
assign ph0_sf_cr[0]    = ph0_inv_en;

assign ph1_sf_cr[15:4] = 'h0;
assign ph1_sf_cr[3:2]  = ph1_sf_mode;
assign ph1_sf_cr[1]    = ph1_sf_en;
assign ph1_sf_cr[0]    = ph1_inv_en;

assign ph2_sf_cr[15:4] = 'h0;
assign ph2_sf_cr[3:2]  = ph2_sf_mode;
assign ph2_sf_cr[1]    = ph2_sf_en;
assign ph2_sf_cr[0]    = ph2_inv_en;

assign ph0_sf_time_cfg[15:0] = ph0_sf_num;
assign ph1_sf_time_cfg[15:0] = ph1_sf_num;
assign ph2_sf_time_cfg[15:0] = ph2_sf_num;

assign ph0_bl_cr[15]    = 'h0;
assign ph0_bl_cr[14]    = ph0_cz_inten;
assign ph0_bl_cr[13]    = ph0_bf_out_fen;
assign ph0_bl_cr[12]    = ph0_bf_out_ren;
assign ph0_bl_cr[11:10] = ph0_bf_mode;
assign ph0_bl_cr[9]     = ph0_bf_pwm_fen;
assign ph0_bl_cr[8]     = ph0_bf_pwm_ren;
assign ph0_bl_cr[7:2]   = ph0_pwm_sel_en;
assign ph0_bl_cr[1]     = ph0_pwm_src_sel;
assign ph0_bl_cr[0]     = ph0_bf_en;

assign ph1_bl_cr[15]    = 'h0;
assign ph1_bl_cr[14]    = ph1_cz_inten;
assign ph1_bl_cr[13]    = ph1_bf_out_fen;
assign ph1_bl_cr[12]    = ph1_bf_out_ren;
assign ph1_bl_cr[11:10] = ph1_bf_mode;
assign ph1_bl_cr[9]     = ph1_bf_pwm_fen;
assign ph1_bl_cr[8]     = ph1_bf_pwm_ren;
assign ph1_bl_cr[7:2]   = ph1_pwm_sel_en;
assign ph1_bl_cr[1]     = ph1_pwm_src_sel;
assign ph1_bl_cr[0]     = ph1_bf_en;

assign ph2_bl_cr[15]    = 'h0;
assign ph2_bl_cr[14]    = ph2_cz_inten;
assign ph2_bl_cr[13]    = ph2_bf_out_fen;
assign ph2_bl_cr[12]    = ph2_bf_out_ren;
assign ph2_bl_cr[11:10] = ph2_bf_mode;
assign ph2_bl_cr[9]     = ph2_bf_pwm_fen;
assign ph2_bl_cr[8]     = ph2_bf_pwm_ren;
assign ph2_bl_cr[7:2]   = ph2_pwm_sel_en;
assign ph2_bl_cr[1]     = ph2_pwm_src_sel;
assign ph2_bl_cr[0]     = ph2_bf_en;

assign ph0_bl_time_cfg[15:10] = 'h0;
assign ph0_bl_time_cfg[9:0]   = ph0_bf_num;

assign ph1_bl_time_cfg[15:10] = 'h0;
assign ph1_bl_time_cfg[9:0]   = ph1_bf_num;

assign ph2_bl_time_cfg[15:10] = 'h0;
assign ph2_bl_time_cfg[9:0]   = ph2_bf_num;

assign ph0_vc_cr[15:4] = 'h0;
assign ph0_vc_cr[3]    = ph0_det_high_en;
assign ph0_vc_cr[2]    = ph0_det_rise_en;
assign ph0_vc_cr[1]    = ph0_det_fall_en;
assign ph0_vc_cr[0]    = ph0_vc_inten;

assign ph1_vc_cr[15:4] = 'h0;
assign ph1_vc_cr[3]    = ph1_det_high_en;
assign ph1_vc_cr[2]    = ph1_det_rise_en;
assign ph1_vc_cr[1]    = ph1_det_fall_en;
assign ph1_vc_cr[0]    = ph1_vc_inten;

assign ph2_vc_cr[15:4] = 'h0;
assign ph2_vc_cr[3]    = ph2_det_high_en;
assign ph2_vc_cr[2]    = ph2_det_rise_en;
assign ph2_vc_cr[1]    = ph2_det_fall_en;
assign ph2_vc_cr[0]    = ph2_vc_inten;

assign ana_bemf_ph0_cr[15:5] = 'h0;
assign ana_bemf_ph0_cr[4:3]  = ph0_bemf_crn0;
assign ana_bemf_ph0_cr[2:1]  = ph0_bemf_crp0;
assign ana_bemf_ph0_cr[0]    = ph0_bemf_en;

assign ana_bemf_ph1_cr[15:5] = 'h0;
assign ana_bemf_ph1_cr[4:3]  = ph1_bemf_crn1;
assign ana_bemf_ph1_cr[2:1]  = ph1_bemf_crp1;
assign ana_bemf_ph1_cr[0]    = ph1_bemf_en;

assign ana_bemf_ph2_cr[15:5] = 'h0;
assign ana_bemf_ph2_cr[4:3]  = ph2_bemf_crn2;
assign ana_bemf_ph2_cr[2:1]  = ph2_bemf_crp2;
assign ana_bemf_ph2_cr[0]    = ph2_bemf_en;

assign ana_bemf_cr[15:12] = 'h0;
assign ana_bemf_cr[11]    = bemf_pmsm_sel;
assign ana_bemf_cr[10:9]  = bemf_res;
assign ana_bemf_cr[8:3]   = bemf_hys_sel;
assign ana_bemf_cr[2:0]   = bemf_dly;

always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        ph2_vc_sts <= 'h0;
    end
    else if (ph2_vc_sts_set == 1'b1) begin
        ph2_vc_sts <= 1'b1;
    end
    else if ((psel) &&(rise_penable) &&(pwrite) &&(paddr[8:0] == STS) &&(pwdata[11] == 1'b1)) begin
        ph2_vc_sts <= 1'b0;
    end
end





















//APB 
reg adr_miss;
reg penable_1d;

always(*)
begin
    case(paddr [8:0])
        STS         : adr_miss = 1'b0 ;
        PH0_SF_CR   : adr_miss = 1'b0 ;
        PH1_SF_CR   : adr_miss = 1'b0 ;
        PH2_SF_CR   : adr_miss = 1'b0 ;
        PH0_SF_TIME_CFG : adr_miss = 1'b0 ;
        PH1_SF_TIME_CFG : adr_miss = 1'b0 ;
        PH2_SF_TIME_CFG : adr_miss = 1'b0 ;
        PH0_BL_CR   : adr_miss = 1'b0 ;
        PH1_BL_CR   : adr_miss = 1'b0 ;
        PH2_BL_CR   : adr_miss = 1'b0 ;
        PH0_BL_TIME_CFG : adr_miss = 1'b0 ;
        PH1_BL_TIME_CFG : adr_miss = 1'b0 ;
        PH2_BL_TIME_CFG : adr_miss = 1'b0 ;
        PH0_VC_CR       : adr_miss = 1'b0 ;
        PH1_VC_CR       : adr_miss = 1'b0 ;
        PH2_VC_CR       : adr_miss = 1'b0 ;
        ANA_BEMF_PH0_CR : adr_miss = 1'b0 ;
        ANA_BEMF_PH1_CR : adr_miss = 1'b0 ;
        ANA_BEMF_PH2_CR : adr_miss = 1'b0 ;
        ANA_BEMF_CR     : adr_miss = 1'b0 ;
        default         : adr_miss = 1'b0 ;
    endcase
end




always@(posedge pclk or negedge presentn)
begin
    if(!presentn)
        begin
            penable_1d <= 1'b0;
        end
    else
        begin
            penable_1d <= penable;
        end
end

assign rise_penable = penable & (~ penable_1d);

always@(posedge pclk or negedge presentn)
begin
    if (!presentn)
        begin
            prdata <= 16'b0;
        end
    else if (psel && rise_penable && !pwrite)
        begin
            prdata <= rdata;
        end
end

always@(posedge pclk or negedge presentn)
begin
    if(!presentn)
        begin
            pready <= 1'b0;
            pslverr <= 1'b0;
        end
    else if (psel)//sel!!!!
        begin
           if(pwrite)//write
                begin
                    if(penable && pready)//final phase need clean
                        begin
                            pready <= 1'b1;
                            pslverr <= 1'b0;
                        end
                    else
                        begin
                            pready <= 1'b1;//updata to write phase
                            pslverr <= adr_miss;
                        end
                        
                end 
            else // read
                begin
                    if(penable && pready)//transiton 
                        begin
                            pready <= 1'b1;
                            pslverr <= 1'b0;
                        end
                    else if (!rise_penable)//pull low ready befor read phase
                        begin
                            pready <= 1'b0;
                            pslverr <= 1'b0;
                        end
                    else 
                        begin
                            pready <= 1'b1;
                            pslverr <= adr_miss;
                        end


                end
        end
    else
        begin
            pready <= 1'b1;
            pslverr <= 1'b0;
        end
end



//rdata 
always(*)
begin
    case(paddr [8:0])
        STS         : rdata = sts ;
        PH0_SF_CR   : rdata = ph0_sf_cr;
        PH1_SF_CR   : rdata = ph1_sf_cr;
        PH2_SF_CR   : rdata = ph2_sf_cr;
        PH0_SF_TIME_CFG : rdata = ph0_sf_time_cfg;
        PH1_SF_TIME_CFG : rdata = ph1_sf_time_cfg;
        PH2_SF_TIME_CFG : rdata = ph2_sf_time_cfg;
        PH0_BL_CR   : rdata = ph0_bl_cr;
        PH1_BL_CR   : rdata = ph1_bl_cr;
        PH2_BL_CR   : rdata = ph2_bl_cr;
        PH0_BL_TIME_CFG : rdata = ph0_bl_time_cfg;
        PH1_BL_TIME_CFG : rdata = ph1_bl_time_cfg;
        PH2_BL_TIME_CFG : rdata = ph2_bl_time_cfg;
        PH0_VC_CR       : rdata = ph0_vc_cr;
        PH1_VC_CR       : rdata = ph1_vc_cr;
        PH2_VC_CR       : rdata = ph2_vc_cr;
        ANA_BEMF_PH0_CR : rdata = ana_bemf_ph0_cr;
        ANA_BEMF_PH1_CR : rdata = ana_bemf_ph1_cr;
        ANA_BEMF_PH2_CR : rdata = ana_bemf_ph2_cr;
        ANA_BEMF_CR     : rdata = ana_bemf_cr;
        default         : rdata = 16'h0;
    endcase
end



endmodule
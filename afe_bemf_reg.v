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
    // 

);
reg rise_penable;
reg [15:0]  rdata;


















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
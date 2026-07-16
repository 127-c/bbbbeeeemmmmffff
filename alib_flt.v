module alib_flt #(
    parameter DEFAULT_VALUE = 1'b0;
    parameter FLT_NUM_WD    = 8   ;
)(
    input   i_flt_clk,
    input   i_flt_rstn,
    input   i_flt_din,

//reg
    input                       i_reg_flten,
    input   [FLT_NUM_WD-1 :0]   i_reg_fltnum,
    input   [2         -1 :0]   i_reg_fltmode,

output  wire                    o_flt_dout 
)

//insite reg
reg     flt_din_r1;
reg [FLT_NUM_WD-1 : 0]     flt_cnt;
reg     flt_dout_per;

//wire
wire    din_edge;
wire    flt_match;
wire    flt_zero;

//===========din  reg ===============
always@(posedge i_flt_clk or negedge i_flt_rstn)begin
    if(i_flt_rstn == 1'b0)begin
        flt_din_r1 <= DEFAULT_VALUE;
    end
    else if(i_reg_flten == 1'b0)begin
        flt_din_r1 <= DEFAULT_VALUE; 
    end
    else begin
        flt_din_r1 <= i_flt_din;
    end
end

assign  din_edge = i_flt_din ^ flt_din_r1;
//============mode====================
always@(posedge i_flt_clk or negedge i_flt_rstn)begin
    if(i_flt_rstn ==1'b0)begin
        flt_cnt <= {FLT_NUM_WD{1'b0}};
    end
    else if (i_reg_flten == 1'b0)begin
        flt_cnt <= {FLT_NUM_WD{1'b0}};
    end
    else if (i_reg_fltmode==2'b00)begin// flt mode 00
            if(i_flt_din == ~DEFAULT_VALUE)begin
                if(flt_match == 1'b1)begin
                    flt_cnt <= flt_cnt;//hold cnt 
                end
            end 
                else begin
                    flt_cnt <= flt_cnt +1'b1;
                end
            else begin
                if(flt_zero == 1'b1)begin//hole cnt
                    flt_cnt <= flt_cnt;
                end
                else begin
                    flt_cnt <= flt_cnt -1'b1;
                end
            end
    end

    else if (i_reg_fltmode==2'b01)begin// flt mode 01 ignor low level
            if(i_flt_din == 1'b0)begin//flt high,ignor low level
                flt_cnt <= {FLT_NUM_WD{1'b0}};
            end
            else begin
                if(flt_match == 1'b1)begin
                    flt_cnt <= flt_cnt;//hold cnt 
                end
                else begin
                    flt_cnt <= flt_cnt +1'b1;
                end
            end
    end

    else if (i_reg_fltmode==2'b10)begin// flt mode 01 ignor high level
            if(i_flt_din == 1'b1)begin//flt low 
                flt_cnt <= {FLT_NUM_WD{1'b0}};
            end
            else begin
                if(flt_match == 1'b1)begin
                    flt_cnt <= flt_cnt;//hold cnt 
                end
                else begin
                    flt_cnt <= flt_cnt +1'b1;
                end
            end
    end

    else if (i_reg_fltmode==2'b11)begin// flt mode 11 edge 
            if(din_edge == 1'b1)begin//flt edge 
                flt_cnt <= {FLT_NUM_WD{1'b0}};
            end
            else begin
                if(flt_match == 1'b1)begin
                    flt_cnt <= flt_cnt;//hold cnt 
                end
                else begin
                    flt_cnt <= flt_cnt +1'b1;
                end
            end
    end
end
assign  flt_zero = (flt_cnt=={FLT_NUM_WD{1'b0}});
assign  flt_match= (flt_cnt == i_reg_fltnum);

//=======================out ========================
always@(posedge i_flt_clk or negedge i_flt_rstn)begin
    if(i_flt_rstn == 1'b0)begin
        flt_dout_per <= DEFAULT_VALUE;     
    end
    else if (i_reg_flten == 1'b0)begin
        flt_dout_per <= DEFAULT_VALUE;     
    end
    else if (i_reg_fltmode == 2'b00)begin
        if(flt_match == 1'b1)begin
            flt_dout_per <= ~DEFAULT_VALUE;
        end
        else if (flt_zero == 1'b1)begin
            flt_dout_per <= DEFAULT_VALUE;
        end
    end
    else if (i_reg_fltmode == 2'b01)begin//high level
        if(i_flt_din == 1'b0)begin
            flt_dout_per <=1'b0;
        end
        else if (flt_match == 1'b1)begin
            flt_dout_per <=1'b1;
        end
    end
    else if (i_reg_fltmode == 2'b10)begin//low level
        if(i_flt_din == 1'b1)begin
            flt_dout_per <=1'b1;
        end
        else if (flt_match == 1'b1)begin
            flt_dout_per <=1'b0;
        end
    end
    else begin//low high 
        if(din_edge == 1'b0 && flt_match)begin
            flt_dout_per <= i_flt_din;
        end
    end    
end

assign o_flt_dout = i_reg_flten ? flt_dout_per:i_flt_din;

endmodule
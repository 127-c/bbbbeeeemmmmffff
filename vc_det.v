module vc_det(
input       clk,
input       rst_n,

//reg
input       det_high_en,
input       det_rise_en,
input       det_fall_en,

//io
input       sin,
output reg  vc_intsts_set
);

//detect===============================
reg sin_r;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        sin_r <= 1'b0;
    end
    else begin
        sin_r <= sin;
    end
end

wire det_rise = sin &(~sin_r);
wire det_fall = (~sin) & sin_r;
wire det = (sin & det_high_en)  |  (det_fall_en & det_fall) | (det_rise_en & det_rise);

//vc_intsts_set

always@(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        vc_intsts_set <= 1'b0;
    end

    else if(vc_intsts_set)begin
        vc_intsts_set <= 1'b0;//hardware dismiss 0
    end
    else if(det)begin
        vc_intsts_set <= 1'b1;
    end

end



endmodule
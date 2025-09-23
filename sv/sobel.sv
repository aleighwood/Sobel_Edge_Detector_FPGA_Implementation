module sobel #(
    parameter IMG_WIDTH,
    parameter IMG_HEIGHT
)(
    input logic clock,
    input logic reset,
    input logic grey_out_empty,
    output logic grey_out_rd_en,
    input logic [7:0] grey_out_dout,
    output logic [7:0] sobel_out,
    output logic f3_wr_en,
    input logic f3_full
);


typedef enum logic [3:0] {s0, s1, s2, s3,s4} state_t;
state_t state, state_c;

logic [7:0] sobel_out_c;

// shift register 
logic shift_full;
logic shift;
//reg [0:1442] [7:0] shift_reg;
reg [0:2*IMG_WIDTH+2] [7:0] shift_reg;
reg [0:2*IMG_WIDTH+2] [7:0] shift_reg_c;


logic [7:0] i_1,i_1_c;
logic [7:0] i_2,i_2_c;
logic [7:0] i_3,i_3_c;
logic [7:0] i_4,i_4_c;
logic [7:0] i_5,i_5_c;
logic [7:0] i_6,i_6_c;
logic [7:0] i_7,i_7_c;
logic [7:0] i_8,i_8_c;
logic [7:0] i_9,i_9_c;

//counter for whole process
logic [18:0] counter;
logic [18:0] shift_counter;
logic [18:0] counter_c;
logic [18:0] shift_counter_c;

//items for sobel operation
logic [10:0] horiz_c_a;
logic [10:0] horiz_c_b;
logic [10:0] abs_horiz_c;

logic [10:0] vert_c_a;
logic [10:0] vert_c_b;
logic [10:0] abs_vert_c;

logic [10:0] avg_c;

logic [7:0] v,v_c;


//for row triple shift
logic [4:0] i, i_c;


always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        state <= s0;
        //reset shift register
        i<= 5'b0;
        counter <= 19'b1;
        shift_counter <= 19'b1;
        //f3_wr_en <= 1'b0;
        //grey_out_rd_en <= 1'b0;
        shift_reg[0:2*IMG_WIDTH+2] <= 8'h0;
    end else begin
        shift_reg <= shift_reg_c;
        state <= state_c;
        shift_counter <= shift_counter_c;
        counter <= counter_c;
        i <= i_c;
        v <= v_c;
        i_1 = i_1_c;
        i_2 = i_2_c;
        i_3 = i_3_c;
        i_4 = i_4_c;
        i_5 = i_5_c;
        i_6 = i_6_c;
        i_7 = i_7_c;
        i_8 = i_8_c;
        i_9 = i_9_c;

    end
end

always_comb begin 
    state_c = state;
    grey_out_rd_en = 1'b0;
    f3_wr_en =1'b0;
    sobel_out_c = 8'b0;
    shift = 1'b1;

    case (state)

//Reset register

// look at reset at the end
    s0: begin
        if(reset ==1'b1) begin 
            shift_reg_c[0:2*IMG_WIDTH+2] <= 8'h0;
            state_c = s0;
            shift_counter_c = 19'b1;
            counter_c = 19'b1;
            i_c = 5'b0;
            shift_full = 1'b0;
        end
        else begin 
            state_c = s1;
        end
    end


// just shifting 
    s1: begin 
        
        if (grey_out_empty == 1'b0 && shift ==1'b1) begin 
        //if(shift ==1'b1) begin
            // next reg logic 
            shift_reg_c[1:2*IMG_WIDTH+2] = shift_reg[0:2*IMG_WIDTH+1];
            shift_reg_c[0] = grey_out_dout;
            shift_counter_c = shift_counter + 19'b1; 

        //extract items of square
            i_1_c = shift_reg[2*IMG_WIDTH+2];
            i_2_c = shift_reg[2*IMG_WIDTH+1];
            i_3_c = shift_reg[2*IMG_WIDTH];
            i_4_c = shift_reg[IMG_WIDTH+2];
            i_5_c = shift_reg[IMG_WIDTH+1];
            i_6_c = shift_reg[IMG_WIDTH];
            i_7_c = shift_reg[2];
            i_8_c = shift_reg[1];
            i_9_c = shift_reg[0];
        
        if(shift_full == 1'b0 && i_1_c == 8'h51)begin
            shift_full = 1'b1;
            state_c = s2;
        end

        // continue filling shift register until full
        if (shift_full == 1'b0 && counter) state_c = s1;
        else state_c = s2;

    
        //if (shift_counter< 2*IMG_WIDTH+3) state_c = s1;
        //else state_c = s2;
        grey_out_rd_en =1'b1;

        end
    end 


//calculate sobel values
    s2: begin

        $display("");
        $display("%h %h %h",i_1, i_2, i_3);
        $display("%h %h %h", i_4, i_5,i_6);
        $display("%h %h %h", i_7,i_8,i_9);



    //check if at end of row 
    if (counter % IMG_WIDTH-1 == 0 && counter_c !=  19'd1) begin
        // shift by 3 
        state_c = s4;
        $display("shift by 3 start");
        //counter_c = counter + 19'b1;
    end 

    else if(f3_full == 1'b0) begin
        // find sobel values
            horiz_c_a = (i_7 + (i_8_c<<1) + i_9);
            horiz_c_b = (i_1 + (i_2_c<<1) + i_3);
            abs_horiz_c = (horiz_c_a < horiz_c_b) ? horiz_c_b - horiz_c_a : horiz_c_a - horiz_c_b;

            vert_c_a = (i_3 + (i_6<<1) + i_9);
            vert_c_b = (i_1+ (i_4<<1) + i_7);   
            abs_vert_c = (vert_c_a < vert_c_b) ? vert_c_b - vert_c_a : vert_c_a - vert_c_b;

        //find avgerage
            avg_c = (abs_horiz_c + abs_vert_c)>>1;
            v_c = (avg_c > 255) ? 8'hff : avg_c;
            //sobel_out_c = avg_c;
            state_c = s3;
        end
    end

//write out
    s3: begin
        sobel_out = v;
        //write to fifo
        f3_wr_en = 1'b1;
        // increment counter
        counter_c = counter + 19'b1;
        state_c = s1;

    end

//shift by 3 session 
    s4: begin 
        grey_out_rd_en = 1'b1;

        if(i<'d3) begin
            shift_reg_c[1:2*IMG_WIDTH+2] = shift_reg[0:2*IMG_WIDTH+1];
            shift_reg_c[0] = grey_out_dout;
        shift_counter_c = shift_counter + 19'b1; 
        i_c = i + 5'b1;
        state_c = s4;
        end
        else begin
            $display("shift by 3 end");
            counter_c = counter + 19'b1;
            i_c = 5'b0;
            state_c = s1;
  
        end

    end


    default: begin
        state_c = s0;
        f3_wr_en = 1'b0;
        shift = 1'b1;
        counter_c = 19'b1;
        shift_counter_c = 19'b1;
    end


    endcase


end 
endmodule
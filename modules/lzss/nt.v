
module nt_deflate();

    localparam                                              lzss_future_size                 = 10;

    localparam q_full                           = 48;
    localparam q_half                           = 24;
    localparam SF                               = 2.0**-24.0;  

    localparam q_full_hp            = 64;
    localparam q_half_hp            = 32;
    localparam SF_hp                = 2.0**-32.0;  



    localparam address_len                      = 24;

    localparam sum_bpu_full                     = 24;

    localparam width                            = 320;
    localparam height                           = 240;




    integer i, j, k , l;
    real dtb_b;
    integer whole;
    real dec, temp, added;
    integer q_is_neg;

    localparam                 [q_full - 1 : 0]                    floating_part_mask           = (2 << (q_half - 1)) - 1;
    // localparam                 [q_full - 1 : 0]                    floating_part_mask_full_q_hp        = (2 << (q_half_hp - 1)) - 1;

    localparam                                                     full_color_range                    = 256;

    localparam                                              freq_list_width                 = 63;

    localparam      signed     [q_full - 1 : 0]                    one_signed                          = 'b000000000000000000000001_000000000000000000000000;   //  1.0
    localparam      signed     [q_full - 1 : 0]                    one_over_2_signed                   = 'b000000000000000000000000_100000000000000000000000;   //  0.5
    localparam      signed     [q_full - 1 : 0]                    one_over_3_signed                   = 'b000000000000000000000000_010101010101010101010101;   //  0.3333333333333333
    localparam      signed     [q_full - 1 : 0]                    one_over_4_signed                   = 'b000000000000000000000000_010000000000000000000000;   //  0.25
    localparam      signed     [q_full - 1 : 0]                    one_over_5_signed                   = 'b000000000000000000000000_001100110011001100110011;   //  0.2

    localparam      signed     [q_full - 1 : 0]                    one_twnty_eight_signed              = 'b000000000000000010000000_000000000000000000000000;   //  128.0
    localparam      signed     [q_full - 1 : 0]                    minus_one_twnty_eight_signed        = 'b111111111111111101111111_111111111111111111111111;   //  -128.0

    localparam      signed     [q_full - 1 : 0]                    minus45p25                          = 'b111111111111111111010010_101111111111111111111111;   //  -45.25
    localparam      signed     [q_full - 1 : 0]                    plus17p99_signed                    = 'b000000000000000000010001_111111010111000010100011;   //  -45.25
    localparam      signed     [q_full - 1 : 0]                    two_fifty_five_signed               = 'b000000000000000011111111_000000000000000000000000;   //  255
    localparam      signed     [q_full - 1 : 0]                    minus_two_fifty_five_signed         = 'b111111111111111100000000_111111111111111111111111;   //  -255


    localparam                 [q_full - 1 : 0]                    one                                 = 1 << (q_half);
    localparam                 [q_full - 1 : 0]                    point5                              = 1 << (q_half-1);
    localparam                 [q_full - 1 : 0]                    point49                             = 'b000000000000000000000000_011111111111100000000000;   //  0.49
    localparam                 [q_full - 1 : 0]                    point2                              = 'b000000000000000000000000_001100110011001100110011;   //  0.2
    localparam                 [q_full - 1 : 0]                    one_point2                          = 'b000000000000000000000001_001100110011001100110011;   //  1.2
    localparam      signed     [q_full - 1 : 0]                    minus_one_point2                    = 'b111111111111111111111110_110011001100110011001100;   //  -1.2
    localparam                 [q_full - 1 : 0]                    two                                 = 1 << (q_half + 1);
    localparam                 [q_full - 1 : 0]                    four                                = 1 << (q_half + 2);
    localparam                 [q_full - 1 : 0]                    three                               = 'b000000000000000000000011_000000000000000000000000;   //  3
    localparam                 [q_full - 1 : 0]                    one_over_3                          = 'b000000000000000000000000_010101010101010101010101;   //  0.3333333333333333

    localparam                 [q_full - 1 : 0]                    two_fifty_five                      = 'b000000000000000011111111_000000000000000000000000;   //  255
    localparam                 [q_full - 1 : 0]                    one_eighty                          = 'b000000000000000010110100_000000000000000000000000;   //  180
    localparam                 [q_full - 1 : 0]                    one_seventy_nine                    = 'b000000000000000010110011_000000000000000000000000;   //  180

    localparam                 [q_full - 1 : 0]                    one_over_100000                     = 'b000000000000000000000000_000000000000000010100111;   //  1e-05
    localparam                 [q_full - 1 : 0]                    one_over_10000                      = 'b000000000000000000000000_000000000000011010001101;   //  0.0001

    localparam                 [q_full - 1 : 0]                    one_over_1200                       = 'b000000000000000000000000_000000000011011010011101;   //  0.0008333, actually: 0.000732421875
    localparam                 [q_full - 1 : 0]                    one_over_1000                       = 'b000000000000000000000000_000000000100000110001001;   //  0.001
    localparam                 [q_full - 1 : 0]                    one_over_255                        = 'b000000000000000000000000_000000010000000100000001;   //  0.00392156862745098
    localparam                 [q_full - 1 : 0]                    one_over_hundared                   = 'b000000000000000000000000_000000101000111101011100;   //  0.01
    localparam                 [q_full - 1 : 0]                    one_over_64                         = 'b000000000000000000000000_000001000000000000000000;   //  0.015625
    localparam                 [q_full - 1 : 0]                    one_over_16                         = 'b000000000000000000000000_000100000000000000000000;   //  0.0625

    localparam                 [q_full - 1 : 0]                    one_over_eight                      = 'b000000000000000000000000_001000000000000000000000;   //  0.125
    localparam                 [q_full - 1 : 0]                    one_over_six                        = 'b000000000000000000000000_001010101010101010101010;   //  0.16666666666666666
    localparam                 [q_full - 1 : 0]                    one_over_4                          = 'b000000000000000000000000_010000000000000000000000;   //  0.25

    localparam                 [q_full - 1 : 0]                    hundared                            = 'b000000000000000001100100_000000000000000000000000;   //  100
    localparam                 [q_full - 1 : 0]                    one_twenty_eight                    = 'b000000000000000010000000_000000000000000000000000;   //  128

    localparam                 [q_full - 1 : 0]                    one_thousand                        = 'b000000000000001111101000_000000000000000000000000;   //  1_000
    localparam                 [q_full - 1 : 0]                    one_million                         = 'b000011110100001001000000_000000000000000000000000;   //  1_000_000
    

    
    //     y = 0.299 * r + 0.587 * g + 0.114 * b
    localparam                 [q_full - 1 : 0]                    yc1                                 = 'b000000000000000000000000_010011001000101101000011;   //  0.299 
    localparam                 [q_full - 1 : 0]                    yc2                                 = 'b000000000000000000000000_100101100100010110100001;   //  0.587
    localparam                 [q_full - 1 : 0]                    yc3                                 = 'b000000000000000000000000_000111010010111100011010;   //  0.114

    localparam                 [q_full - 1 : 0]                    ycb1                                = 'b000000000000000000000000_001010110011001001001000;   //  0.168736 
    localparam                 [q_full - 1 : 0]                    ycb2                                = 'b000000000000000000000000_010101001100110110110111;   //  0.331264
    localparam                 [q_full - 1 : 0]                    ycb3                                = 'b000000000000000000000000_100000000000000000000000;   //  0.5

    localparam                 [q_full - 1 : 0]                    ycr1                                = 'b000000000000000000000000_100000000000000000000000;   //  0.5 
    localparam                 [q_full - 1 : 0]                    ycr2                                = 'b000000000000000000000000_011010110010111100100011;   //  0.418688
    localparam                 [q_full - 1 : 0]                    ycr3                                = 'b000000000000000000000000_000101001101000011011100;   //  0.081312

    localparam                 [q_full - 1 : 0]                    one_over_sqrt_2                     = 'b000000000000000000000000_101101010000010011110011;   //  0.7071067811865475, 1. / np.sqrt(2)




    // 320 * 240
    // localparam                 [q_full - 1 : 0]                    one_over_width_cropped              = 'b000000000000000000000000_000001100110011001100110;   //  0.025
    // localparam                 [q_full - 1 : 0]                    one_over_height_cropped             = 'b000000000000000000000000_000010001000100010001000;   //  0.03333333333333333
    // localparam                 [q_full - 1 : 0]                    one_over_width                      = 'b000000000000000000000000_000000001100110011001100;   //  0.003125
    // localparam                 [q_full_hp - 1 : 0]     one_over_width_cropped_hp           = 'b00000000000000000000000000000000_00000110011001100110011001100110;   //  0.025
    // localparam                 [q_full_hp - 1 : 0]     one_over_height_cropped_hp          = 'b00000000000000000000000000000000_00001000100010001000100010001000;   //  0.03333333333333333
    // localparam                 [q_full_hp - 1 : 0]     one_over_width_hp                   = 'b00000000000000000000000000000000_00000000110011001100110011001100;   //  0.003125
    // localparam                 [q_full - 1 : 0]                    one_over_block_pixels_count         = 'b000000000000000000000000_000000000011011010011101;   //  1 / 1200




    // 112 * 80 and crop_count=8
    localparam                 [q_full - 1 : 0]                     one_over_width_cropped              = 'b000000000000000000000000_000100100100100100100100;   //  1 / 14
    localparam                 [q_full - 1 : 0]                     one_over_height_cropped             = 'b000000000000000000000000_000110011001100110011001;   //  1 / 10
    localparam                 [q_full - 1 : 0]                     one_over_width                      = 'b000000000000000000000000_000000100100100100100100;   //  1 / 112
    localparam                 [q_full_hp - 1 : 0]                  one_over_width_cropped_hp           = 'b00000000000000000000000000000000_00010010010010010010010010010010;   //  1 / 14
    localparam                 [q_full_hp - 1 : 0]                  one_over_height_cropped_hp          = 'b00000000000000000000000000000000_00011001100110011001100110011001;   //  1 / 10
    localparam                 [q_full_hp - 1 : 0]                  one_over_width_hp                   = 'b00000000000000000000000000000000_00000010010010010010010010010010;   //  1 / 112
    localparam                 [q_full - 1 : 0]                     one_over_block_pixels_count         = 'b000000000000000000000000_000000011101010000011101;   //  1 / 140






    localparam                 [q_full_hp - 1 : 0]     one_over_ten_hp                     = 'b00000000000000000000000000000000_00011001100110011001100110011001;   //  0.1
    localparam                 [q_full_hp - 1 : 0]     one_over_eight_hp                   = 'b00000000000000000000000000000000_00100000000000000000000000000000;   //  0.125
    localparam                 [q_full_hp - 1 : 0]     one_over_four_hp                    = 'b00000000000000000000000000000000_01000000000000000000000000000000;   //  0.25
    localparam                 [q_full_hp - 1 : 0]     one_over_two_hp                     = 'b00000000000000000000000000000000_10000000000000000000000000000000;   //  0.5


    // // GENERIC FUNCTIONS

    function  [q_full - 1 : 0] mult;
        input [q_full - 1 : 0] mult_first;
        input [q_full - 1 : 0] mult_second;
        reg   [2 * q_full - 1 : 0] mult_buf;
        begin
                mult_buf = mult_first * mult_second;
                mult = mult_buf[3 * q_half - 1 : q_half];
        end
    endfunction


    function  signed [q_full - 1 : 0] signed_mult;
        input signed [q_full - 1 : 0] mult_first;
        input signed [q_full - 1 : 0] mult_second;
        reg   signed [2 * q_full - 1 : 0] mult_buf;
        begin
                mult_buf = mult_first * mult_second;
                signed_mult = mult_buf[3 * q_half - 1 : q_half];
        end
    endfunction




    /*
    this multipication is used to multiply two numbers
    the first number is not left shifted and is in raw full_q
    the second number is left_shifted in high precision; this must be a constant
    with q_full_hp bits
    */
    function  [q_full - 1 : 0]                      mult_hp;
        input [q_full - 1 : 0]                      mult_first;
        input [q_full_hp - 1 : 0]       mult_second;
        
        reg   [q_full_hp - 1 : 0]       mult_first_cast;
        reg   [2 * q_full_hp - 1 : 0]   mult_buf;
        begin
                mult_first_cast = mult_first << q_half_hp;
                // $display("%b, %f", mult_first_cast, SF_hp * mult_first_cast);
                // $display("%b, %f", mult_second, SF_hp * mult_second);
                mult_buf = mult_first_cast * mult_second;
                // $display("%b", mult_buf);

                mult_hp = mult_buf[q_half + q_full_hp - 1 : q_full_hp - q_half];
                // $display("%b, %f", mult_hp, SF * mult_hp);
                // $display("%d", mult_hp >> q_half);


        end
    endfunction











    /*
    Rounding
    */
    function  [q_full - 1 : 0] round_to_int;
        input    [q_full - 1 : 0] x;
        begin
            // $display("%b", x & floating_part_mask);
            // $display("%b", rounding_treshold);

            

            if((x & floating_part_mask) >= point49) begin
                // $display("larger");
                round_to_int = ((x >> q_half) + 1) << q_half;

            end else begin
                // $display("smaller");
                round_to_int = ((x >> q_half)) << q_half;
                
            end

        end
        ;
        
    endfunction





    /*
    Rounding
    */
    function  signed [q_full - 1 : 0] signed_round_to_int;
        input    signed [q_full - 1 : 0] x;
        reg      [q_full - 1 : 0] x_pos;
        reg      [q_full - 1 : 0] round_to_int_value;
        begin
            x_pos = (x >= 0) ? x : -x;

            // $display("x_pos: %f", SF*x_pos);
            // $display("x_pos & floating_part_mask: %f", SF*(x_pos & floating_part_mask));
            // $display("point5: %f", SF*point5);

            round_to_int_value = round_to_int(x_pos);

            signed_round_to_int = (x >= 0) ? round_to_int_value : -round_to_int_value;

        end;
        
        
    endfunction






function signed [8 - 1 : 0] to_8_bits_signed;
    input signed [q_full - 1 : 0] value_in;

    begin
        if (value_in < minus_one_twnty_eight_signed) begin
            $display("smaller than lower limit");
            to_8_bits_signed = -8'sd127;
        end else if (value_in > one_twnty_eight_signed) begin
            $display("larger than upper limit");
            to_8_bits_signed = 8'sd127;
        end else begin
            // $display("in middle");

            to_8_bits_signed = (value_in >> (q_half));
        end
    end
    
endfunction




// F6
reg     no_longer_match_F6;


function [lzss_future_size - 1 : 0] number_of_bytes_shared;
    input [(lzss_future_size * 8) - 1 : 0] bus_1;
    input [(lzss_future_size * 8) - 1 : 0] bus_2;
    // input [8 - 1 : 0] comparison_size;

    begin


        // $display("%b, %b", bus_1, bus_2);
        no_longer_match_F6 = 0;
        number_of_bytes_shared = 0;

        for (i = 0; i < lzss_future_size; i = i + 1) begin

            if ((bus_1[lzss_future_size * 8 - i*8 - 1 -: 8] ==
                 bus_2[lzss_future_size * 8 - i*8 - 1 -: 8]
            ) && (no_longer_match_F6 == 0)) begin

                number_of_bytes_shared = number_of_bytes_shared + 1;
                
            end else begin
                
                no_longer_match_F6 = 1;

            end

            
        end
        ;
    end
    
    
endfunction




// F7

function display_freq_list_entry;
    input [freq_list_width - 1 : 0] bus;
    input [q_full - 1 : 0] counter;

    begin

        $display("%d, symbol:%d, freq:%d, used?%d, node?:%d, left_count:%d, left_start_addr:%d, right_count:%d, right_start_addr:%d",
        counter,
        bus[62:54],
        bus[53:42],
        bus[41],
        bus[40],
        bus[39:32],
        bus[31:20],
        bus[19:12],
        bus[11:0]
        );
        display_freq_list_entry = 0;
    end
    
endfunction




// F8

function display_huffman_code;
    input [freq_list_width - 1 : 0] bus;
    input [q_full - 1 : 0] counter;

    begin

        $display("%d, symbol: %d, code length: %d, code: %b",
        counter,
        bus[40:32],
        bus[31:20],
        bus[19:0]
        );
        display_huffman_code = 0;
    end
    
endfunction





// F9

function display_vs;
    input [22 - 1 : 0] bus;
    input [q_full - 1 : 0] counter;

    begin

        $display("displaying vs: idx: %d,     (%d,  %d),      node depth: %d",
        counter,
        bus[21:13],
        bus[12:4],
        bus[3:0]
        );
        display_vs = 0;
    end
    
endfunction







// F10

function [12 - 1: 0] two_to_power;
    input [8 - 1 : 0] power;

    begin
        two_to_power = 1;


        if (power > 0) begin

            for (i = 0; i < power; i = i + 1) begin
                two_to_power =  2 * two_to_power;
            end 
        end

    end
    
endfunction














endmodule
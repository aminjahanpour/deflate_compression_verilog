modules = {

    'lzss': {
        'source_files': ['05_D_lzss.v'],
        'starter':
            """
                               history_length_D            = 0;
                               ll_symbols_mem_write_addr   = 0;
                               distance_symbols_mem_write_addr = 0;
                               lzss_output_mem_write_addr  = 0;
                               i_counter_D0                = 0;
                               i_lagger_D0                 = 0;
                               D0_lzss_main_loop_flag      = 1;
            """,

        'output_files': [
            'D6_output_file_ll_symbols_mem',
            'D6_output_file_distance_symbols_mem',
            'D6_output_file_lzss_output_mem',
            'D_output_file_general'
        ],

        'rams':
            {'input_bits': {'width': '8', 'depth': 'input_bytes_count', 'resetable': 0,
                            'source_file': '"./input_bitstring.mem"',
                            'comments': 'Input bit stream'},

             'll_table': {'width': '17', 'depth': 'length_symbol_counts', 'resetable': 0,
                          'source_file': '"./ll_table.mem"',
                          'comments': 'll table rom'},

             'distance_table': {'width': '22', 'depth': 'distance_symbol_counts', 'resetable': 0,
                                'source_file': '"./distance_table.mem"',
                                'comments': 'distance table rom'},

             'll_symbols': {'width': '9', 'depth': 'input_bytes_count', 'resetable': 0,
                            'source_file': 0,
                            'comments': 'literal and length values in 9 this ram is used as feed to the huffman coding',
                            },

             'distance_symbols': {'width': '9', 'depth': 'input_bytes_count', 'resetable': 0,
                                  'source_file': 0,
                                  'comments': 'distance values in 5 bits  this ram is used as feed to the huffman coding',
                                  },

             'lzss_output': {'width': 'lzss_output_width', 'depth': 'input_bytes_count', 'resetable': 0,
                             'source_file': 0,
                             'comments': 'lzss output. this is what we get from running lzss'},

             },
        'duration': '5000000',
        'utilities' : ['memory_frame', 'nt']
    },

    'freq_list': {
        'source_files': ['06_C_freq_list.v'],
        'starter':
            """
                                  lagger_CC                   = 0;
                                  CC_read_config_file_flag    = 1;
            """,

        'output_files': [
            'C2_output_file_freq_mem',
            'C2_output_file_freq_list_mem'
        ],
        'rams': {
            'fl_input_symbols': {'width': '9', 'depth': 'input_bytes_count', 'resetable': 0,
                                 'source_file': '"./input.txt"',},

            'fl_config': {'width': 'q_full', 'depth': '20', 'resetable': 0,
                          'source_file': '"./config.txt"'},

            'fl_freq': {'width': 'q_full', 'depth': 'max_length_symbol', 'resetable': 1,
                        'source_file': 0},

            'fl_freq_list': {'width': 'freq_list_width', 'depth': 'freq_list_depth', 'resetable': 0,
                             'source_file': 0},

        },
        'duration': '20000',
        'utilities' : ['memory_frame']

    },

    'huffman': {
        'source_files': ['07_E_huffman.v'],

        'starter':
            """
                                  counter_E11 = 0;
                                  lagger_E11 = 0;
                                  count_of_free_freq_list_entries = 0;
                                  this_is_the_last_node_E11 = 0;
                                  E11_find_count_of_free_freq_list_entries_flag = 1;
                                  huffman_nodes_mem_write_addr         = 0;
            """,

        'output_files': [
            'E2_output_file_huff_freq_mem',
            'E4_output_file_freq_list_mem',
            'E10_output_file_huffman_nodes_mem',
            'E14_output_file_huffman_codes_mem',
        ],

        'rams': {
            'freq_list': {'width': 'freq_list_width', 'depth': 'freq_list_depth', 'resetable': 0,
                          'source_file': '"./input.txt"'},

            'huffman_nodes': {'width': '9', 'depth': 'huffman_nodes_count', 'resetable': 1,
                              'source_file': 0},

            'huffman_codes': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 1,
                              'source_file': 0},

        },
        'duration': '5000000',
        'utilities' : ['memory_frame', 'nt']

    },

    'clv': {
        'source_files': ['08_F_clrec.v'],

        'starter':
            """
                                  counter_F0 = 0;
                                  read_lagger_F0 = 0;
                                  write_lagger_F0 = 0;
                                  sorter_bump_flag_F0 = 0;
                                  sorter_stage_F0 = sorter_stage_looping_F0;
                                  F0_argsort_cl_table_flag = 1;
            """,

        'output_files': [
            'F1_output_file_huffman_codes_mem',
            'F2_output_file_argsrot_idx_for_cl_mem',
            'F4_output_file_clrec_freq_list_mem',
            'F8_output_file_clrec_vs_mem',
        ],

        'rams': {
            'huffman_codes': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 0,
                              'source_file': '"./input.txt"',
                              'comments': 'a memory to store huffman codes'},

            'argsrot_idx_for_cl': {'depth': 'max_length_symbol', 'width': '9', 'resetable': 2,
                                   'source_file': 0,
                                   'comments': 'to store indecies of the argsort operation on code lengths in huffman_codes'},

            'clrec_vs': {'depth': 'max_length_symbol', 'width': '22', 'resetable': 1,
                         'source_file': 0,
                         'comments': 'to store vs vectors while recovering codes from code length'},

            'clrec_freq_list': {'depth': 'freq_list_depth', 'width': 'freq_list_width', 'resetable': 1,
                                'source_file': 0,
                                'comments': 'we store the recovered frequencies here'},

        },
        'duration': '850000',
        'utilities' : ['memory_frame', 'nt']
    },

    'clcoding': {
        'source_files': ['09_G_clcoding.v'],

        'starter':
            """
                                  counter_G6              = max_length_symbol - 1;
                                  lagger_G6               = 0;
                                  hlit_G                  = 0;
                                  G6_find_tail_zeros_flag = 1;
            """,

        'output_files': [
            'G4_output_file_pre_bitstream',
            'G5_output_file_symbols_mem',
            'G6_output_file_general',
        ],

        'rams': {

            'input_huffman_codes': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 0,
                                    'source_file': '"./input.txt"',
                                    'comments': 'input memory from which we read huffman codes.'},

            'pre_bitstream_clcoding': {'width': 'pre_bitstream_width', 'depth': 'max_length_symbol', 'resetable': 0,
                                       'source_file': 0},

            'symbols': {'width': '9', 'depth': 'input_bytes_count', 'resetable': 0,
                        'source_file': 0},

        },
        'duration': '100000',
        'utilities' : ['memory_frame']

    },

    'writer': {
        'source_files': ['10_H_writer.v'],
        'starter':
            """
                                  counter_HC              = 0;
                                  lagger_HC               = 0;
                                  HC_load_writer_input_config_flag   = 1;
            """,

        'output_files': [
            'H_output_file_general',
            'H4_output_file_bit_stream_mem',
        ],

        'rams':
            {

                'input_pre_bitstream': {'width': 'pre_bitstream_width', 'depth': 'max_length_symbol', 'resetable': 0,
                                        'source_file': '"./input.txt"'},

                'writer_input_config': {'width': '16', 'depth': '10', 'resetable': 0,
                                        'source_file': '"./config.txt"'},

                'bit_stream': {'width': 'encoded_mem_width', 'depth': 'max_length_symbol', 'resetable': 1,
                               'source_file': 0,
                               'comments': 'output bitstream of the module'},

            },
        'duration': '1000000',
        'utilities' : ['memory_frame']

    },

    'recode': {
        'source_files': ['11_I_recode.v', '11_J_recode.v'],
        'starter':
            """
                                   lagger_IC               = 0;
                                   IC_read_config_file_flag   = 1;
            """,

        'output_files': [
            'I4_output_file_recoded_cl_encoding_pre_bitstream_mem',
            'J1_output_file_recode_cl_cl_reordered_pre_bitstream_mem',
            'I_output_file_general',

        ],
        'rams':
            {

                'recode_input': {'width': 'pre_bitstream_width', 'depth': 'max_length_symbol', 'resetable': 0,
                                 'source_file': '"./input.txt"'},

                'recode_config': {'width': 'q_full', 'depth': '5', 'resetable': 0,
                                  'source_file': '"./config.txt"'},

                'recode_codes': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 0,
                                 'source_file': '"./codes.txt"'},

                'recoded_cl_encoding_pre_bitstream': {'width': 'pre_bitstream_width', 'depth': 'max_length_symbol', 'resetable': 1,
                                                      'source_file': 0,
                                                      'comments': 'output bitstream of the module'},

                'recode_cl_cl_reordered_pre_bitstream': {'width': 'pre_bitstream_width', 'depth': 'cl_cl_count', 'resetable': 1,
                                                         'source_file': 0,
                                                         'comments': 'output bitstream of the module'},

            },
        'duration': '50000',
        'utilities' : ['memory_frame']
    },

    'compiler': {
        'source_files': ['12_K_compiler.v', '12_N_encoder.v'],
        'starter':
                """
                                       counter_KC              = 0;
                                       lagger_KC               = 0;
                                       KC_read_config_file_flag   = 1;
                """,

            'output_files': [
                'K7_output_file_header_pre_bitstream_mem',
                'K_output_file_general',

            ],
            'rams':
                {

                    'compiler_input_cl_ll_pre_bitstream': {'width': 'pre_bitstream_width','depth': 'max_length_symbol', 'resetable': 0,
                                                           'source_file': '"./input_cl_ll_pre_bitstream.txt"',
                                                           'comments': 'pre-bitstream of the fully encoded cl code length for ll \n'},

                    'compiler_input_cl_distance_pre_bitstream': { 'width': 'pre_bitstream_width', 'depth': 'max_length_symbol', 'resetable': 0,
                        'source_file': '"./input_cl_distance_pre_bitstream.txt"',
                        'comments': 'pre-bitstream of the fully encoded cl code length for distance \n'},

                    'compiler_input_cl_cl_ll_pre_bitstream': {'width': 'pre_bitstream_width', 'depth': 'max_length_symbol', 'resetable': 0,
                        'source_file': '"./input_cl_cl_ll_pre_bitstream.txt"',
                        'comments': 'pre-bitstream of the cl of the fully encoded cl code length for ll \n'},

                    'compiler_input_cl_cl_distance_pre_bitstream': {'width': 'pre_bitstream_width', 'depth': 'max_length_symbol', 'resetable': 0,
                        'source_file': '"./input_cl_cl_distance_pre_bitstream.txt"',
                        'comments': 'pre-bitstream of the cl of the fully encoded cl code length for distance \n'},

                    'compiler_input_ll_codes': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 0,
                                     'source_file': '"./input_ll_codes.txt"'},

                    'compiler_input_distance_codes': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol',                                                 'resetable': 0,
                                                'source_file': '"./input_distance_codes.txt"'},

                    'compiler_input_lzss_output': {'width': 'lzss_output_width', 'depth': 'input_bytes_count', 'resetable': 0,
                                    'source_file': '"./input_lzss_output.txt"'},

                    'compiler_config': {'width': 'q_full', 'depth': '20', 'resetable': 0,
                                        'source_file': '"./config.txt"',
                                        'comments': 'config \n'},

                    'header_pre_bitstream': {'width': 'pre_bitstream_width', 'depth': 'compiler_max_output_count', 'resetable': 1,
                                             'source_file': 0,
                                             'comments': 'complete set of pre-bitstream for the header'},

                },
        'duration': '100000',
        'utilities' : ['memory_frame']

        },

    'interperter': {
        'source_files': ['13_L_interperter.v'],

        'starter':
                """
                    // resetting the reader
                    previous_stage_left_over_bus_L = 0;
                    previous_stage_left_over_bus_length_L = 0;
                    previous_read_addr_L = 0;
            
            
                    //setting and launching L1
                    counter_L1 = 0;
                    lagger_L1 = 0;
                    L1_interperter_main_loop_flag = 1;

                """,

            'output_files': [
                'L_output_file_general',
                'L15_output_file_interperter_cl_cl_ll_mem',
                'L16_output_file_interperter_cl_cl_distance_mem'

            ],
            'rams':
                {

                    'interperter_cl_cl_ll': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 1,
                                      'source_file': 0,
                                      'comments': 'store cl values in the format of huffman codes. feed to clv'},
                    'interperter_cl_cl_distance': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 1,
                                         'source_file': 0,
                                         'comments': 'store cl values in the format of huffman codes. feed to clv'},

                },
        'duration': '100000',
        'utilities' : ['memory_frame', 'bits_reader']

        },

    'cl_decode': {
        'source_files': ['14_M_cl_decode.v'],

        'starter':
            """
                    MC_read_config_file_flag    = 1;
                    counter_MC                  = 0;
                    lagger_MC                  = 0;
                    

            """,

        'output_files': [
            'M_output_file_general',
            'M4_output_file_cl_decode_cl_ll_mem',
            'M5_output_file_cl_decode_cl_distance_mem',
            'M6_output_file_cl_decode_extracted_cl_symbols_mem'

        ],
        'rams':
            {

                'cl_decode_codes_cl_ll': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 0,
                                    'source_file': '"./codes_cl_ll.txt"'},

                'cl_decode_codes_cl_distance': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 0,
                                          'source_file': '"./codes_cl_distance.txt"'},

                'cl_decode_config': {'width': 'q_full', 'depth': '20', 'resetable': 0,
                                    'source_file': '"./config.txt"'},

                'cl_decode_cl_ll': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 1,
                                     'source_file': 0,
                                     'comments': 'store cl values in the format of huffman codes. feed to clv'},

                'cl_decode_cl_distance': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol', 'resetable': 1,
                                    'source_file': 0,
                                    'comments': 'store cl values in the format of huffman codes. feed to clv'},
                'cl_decode_extracted_cl_symbols': {'width': '9', 'depth': 'input_bytes_count', 'resetable': 0,
                            'source_file': 0, 'comment': 'just for debugging'},

            },
        'duration': '1000000',
        'utilities' : ['memory_frame', 'bits_reader']

    },

    'decoder': {
        'source_files': ['15_O_decoder.v'],

        'starter':
            """
                    OC_read_config_file_flag    = 1;
                    counter_OC                  = 0;
                    lagger_OC                  = 0;
    
    
            """,

        'output_files': [
            'O10_output_file_decoded_bits_mem'
            # 'M5_output_file_cl_decode_cl_distance_mem'

        ],
        'rams':
            {
                'decoder_input_ll_codes': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol',
                                            'resetable': 0,
                                            'source_file': '"./input_ll_codes.txt"'},

                'decoder_input_distance_codes': {'width': 'huffman_codes_width', 'depth': 'max_length_symbol',
                                                  'resetable': 0,
                                                  'source_file': '"./input_distance_codes.txt"'},

                'll_symbols_table': {'width': '12', 'depth': '29', 'resetable': 0,
                             'source_file': '"./ll_symbols_table.mem"',
                             'comments': 'll table rom'},

                'distance_symbols_table': {'width': '19', 'depth': '30', 'resetable': 0,
                                   'source_file': '"./distance_symbols_table.mem"',
                                   'comments': 'distance table rom'},

                'decoder_config': {'width': 'q_full', 'depth': '20', 'resetable': 0,
                                     'source_file': '"./config.txt"'},

                'decoded_content': {'width': '8', 'depth': 'input_bytes_count', 'resetable': 0,
                                 'source_file': 0},

                'decoded_bits': {'width': '8', 'depth': 'input_bytes_count', 'resetable': 0,
                            'source_file': 0},

                 },
        'duration': '1000000',
        'utilities' : ['memory_frame', 'bits_reader']

    }

}

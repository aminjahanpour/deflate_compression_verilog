

shared_local_params = {
    'address_len':              24,
    'laggers_len':              8,
    'q_full':                   48,
    'q_half':                   24,

    'input_bytes_count':        66,
    'lzss_future_size':         10,
    'lzss_min_search_len':      2,
    'lzss_history_size':        32768,
    'lzss_mlwbr':               3,

    'length_symbol_counts':     255,
    'distance_symbol_counts':   999,
    'max_length_symbol':        286,        # 'the total count of possible values for length symbols. symbols range from 0 to 285 inclusive',
    'max_distance_symbol':      30,         #'the total count of possible values for distance symbols. sy,bols range from 0 to 29 inclusive',
    'freq_list_width':          63,
    'vs_val_for_taken_by_symbol': 229,

    'encoded_mem_width':        8,
    'input_bits_to_writer_width': 16,
    'pre_bitstream_width':      21,
    'cl_cl_count':              19,


    'lzss_output_width':        40,
    'huffman_codes_width':      41,

    'll_freq_list_depth':       573, # (2 * max_length_symbol + 1)   'the depth of memory to store freq_list values, even by adding new nodes, freq_list can never grow larger than its initial size ',
    'distance_freq_list_depth': 61,  # (2 * max_distance_symbol + 1)  'the depth of memory to store freq_list values',
    'freq_list_depth':          573, # (2 * max_length_symbol + 1)   'the depth of memory to store freq_list values',

    'huffman_nodes_count':      2860,# (10 * max_length_symbol),

    'compiler_max_output_count':2860,
    'total_header_bits_width'  : 24,

    'mem_bits_reader_bus_width': 24, # bus width for the mem bits reader

}


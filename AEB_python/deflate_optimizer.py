import huf




def assemble_encoded_bitstream(encoded, ll_table_huffman_encoding, distance_table_huffman_encoding):
    bitstream = ''

    for el in encoded:
        if len(el) == 1: # this is a literal
            bitstream = bitstream + ll_table_huffman_encoding[el[0]]
        else:
            length_symbol, length_offset_bits, distance_symbol, distance_offset_bits =   el
            bitstream = bitstream + ll_table_huffman_encoding[length_symbol]
            bitstream = bitstream + length_offset_bits
            bitstream = bitstream + distance_table_huffman_encoding[distance_symbol]
            bitstream = bitstream + distance_offset_bits

    return bitstream



def find_best_blocks(raw_bytes_count, block_size_r, literals, length_symbols, distance_symbols, encoded):

    # ranges are inclusive at the left end and exclusive at the right end

    # blocks_count = 1
    # blocks_index_ranges = [[0, raw_bytes_count]]
    
    valid = 1

    blocks_count = len(block_size_r) + 1
    blocks_index_ranges = []

    for r in block_size_r:
        # find the first index that is not smaller than r * raw_bytes_count
        for el in encoded:
            if (el[0] >= r * raw_bytes_count):
                if (len(blocks_index_ranges) == 0):

                    blocks_index_ranges.append([0, el[0]])
                else:
                    blocks_index_ranges.append([blocks_index_ranges[-1][1], el[0]])
                break

    if blocks_count == 1:
        blocks_index_ranges = [[0, raw_bytes_count]]
    else:
        blocks_index_ranges.append([blocks_index_ranges[-1][1],raw_bytes_count])

    valid = valid and len(blocks_index_ranges) == blocks_count


    block_lengths = []
    for el in blocks_index_ranges:
        block_lengths.append(el[1] - el[0])


    ll_table_symbols_per_block          = {}
    distance_table_symbols_per_block    = {}

    encoded_per_block = {}

    for i in range(blocks_count):
        ll_table_symbols_per_block[i]       = []
        distance_table_symbols_per_block[i] = []
        encoded_per_block[i]                = []


    for el in literals:
        for idx, block_index_range in enumerate(blocks_index_ranges):
            if block_index_range[0] <= el[0] < block_index_range[1]:
                ll_table_symbols_per_block[idx].append(el[1])

    for el in length_symbols:
        for idx, block_index_range in enumerate(blocks_index_ranges):
            if block_index_range[0] <= el[0] < block_index_range[1]:
                ll_table_symbols_per_block[idx].append(el[1])
                
                


    for el in distance_symbols:
        for idx, block_index_range in enumerate(blocks_index_ranges):
            if block_index_range[0] <= el[0] < block_index_range[1]:
                distance_table_symbols_per_block[idx].append(el[1])

    for el in encoded:
        for idx, block_index_range in enumerate(blocks_index_ranges):
            if block_index_range[0] <= el[0] < block_index_range[1]:
                encoded_per_block[idx].append(el[1])


    ll_table_symbols_freq_dict_per_block = {}
    distance_table_symbols_freq_dict_per_block = {}
    ll_table_huffman_tree_per_block = {}
    ll_table_huffman_codes_per_block = {}
    distance_table_huffman_tree_per_block = {}
    distance_table_huffman_codes_per_block = {}

    encoded_bitstream_per_block = []

    for idx, block_index_range in enumerate(blocks_index_ranges):

        if valid:
            if len(ll_table_symbols_per_block[idx]) < 1:
                valid = 0

            if len(distance_table_symbols_per_block[idx]) < 1:
                valid = 0
        

        if valid:

            ll_table_symbols_freq_dict_per_block[idx] = huffman.get_symbols_frequency_dict(ll_table_symbols_per_block[idx])
            distance_table_symbols_freq_dict_per_block[idx] = huffman.get_symbols_frequency_dict(distance_table_symbols_per_block[idx])

            # print(f'a={list(ll_table_symbols_freq_dict_per_block[idx].keys())};')
            # print(f'p={[x/ sum(ll_table_symbols_freq_dict_per_block[idx].values()) for x in list(ll_table_symbols_freq_dict_per_block[idx].values())]};')
            # print("huffmandict(a,p)")



            ll_table_huffman_tree,          ll_table_huffman_codes       ,valid_1    = huffman.encode_based_on_provided_frequency_dict(ll_table_symbols_freq_dict_per_block[idx])
            distance_table_huffman_tree,    distance_table_huffman_codes ,valid_2    = huffman.encode_based_on_provided_frequency_dict(distance_table_symbols_freq_dict_per_block[idx])

            valid = valid and valid_1 and valid_2

        if valid:
            ll_table_huffman_tree_per_block[idx] = ll_table_huffman_tree
            ll_table_huffman_codes_per_block[idx] = ll_table_huffman_codes
    
            distance_table_huffman_tree_per_block[idx] = distance_table_huffman_tree
            distance_table_huffman_codes_per_block[idx] = distance_table_huffman_codes
    
            
            encoded_bitstream_per_block.append(assemble_encoded_bitstream(encoded_per_block[idx], ll_table_huffman_codes, distance_table_huffman_codes))


    # ll_table_symbols = [x[1] for x in literals] + [x[1] for x in length_symbols]
    # distance_table_symbols = [x[1] for x in  distance_symbols]

    # ll_table_symbols_freq_dict = huffman.get_symbols_frequency_dict(ll_table_symbols)
    # distance_table_symbols_freq_dict = huffman.get_symbols_frequency_dict(distance_table_symbols)

    # ll_table_huffman_tree,          ll_table_huffman_codes          = huffman.encode_based_on_provided_frequency_dict(ll_table_symbols_freq_dict)
    # distance_table_huffman_tree,    distance_table_huffman_codes    = huffman.encode_based_on_provided_frequency_dict(distance_table_symbols_freq_dict)


    # encoded_bitstream_per_block = assemble_encoded_bitstream(encoded, ll_table_huffman_codes, distance_table_huffman_codes)


    return encoded_bitstream_per_block, block_lengths, ll_table_symbols_freq_dict_per_block, distance_table_symbols_freq_dict_per_block ,valid

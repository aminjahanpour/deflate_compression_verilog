import hue_analysis

from g_toolkit import *


# sa_colors = pd.read_csv('../aeb_receiver/bent-cool-warm-table-byte-1024.csv')

"""
this is encoder and decoder for one payload
one payload contains ppp pixels

the payload size for each sum_bpu is taken from the datasheet.ods table
payload should be the largest integer that is smaller than 33,
and results in ppp and ppb values that are integer.

sum_bpu of 1 and 2 are only used in the Y color system.
"""




def encoder(payload_array, vs):

    sum_bpu = vs['sum_bpu']
    color_system = vs['color_system']
    bpu_r = vs['bpu_r']
    bpu_g = vs['bpu_g']
    bpu_b = vs['bpu_b']
    gray_config = vs['gray_config']
    hue_min = vs['hue_min']
    hue_max = vs['hue_max']

    payload_array = payload_array.reshape((height * width, 3))

    aeb_string_buffer = ''

    aeb_buffer_counter = 0

    n_pixels = len(payload_array)

    output_size_in_bytes = int(n_pixels * sum_bpu / 8)

    encoded_buffer = bytearray(output_size_in_bytes)


    for idx, rgb in enumerate(payload_array):

        r_org = rgb[0]
        g_org = rgb[1]
        b_org = rgb[2]

        r_org_norm = r_org / 255
        g_org_norm = g_org / 255
        b_org_norm = b_org / 255

        """
        perform the conversion to the target color system
        encode
        build aeb
        """

        if color_system == 0:
            # RGB. no conversion needed.
            r = int(r_org_norm * (2 ** bpu_r - 1))
            g = int(g_org_norm * (2 ** bpu_g - 1))
            b = int(b_org_norm * (2 ** bpu_b - 1))

            # print(r,g,b)

            aeb = r << (bpu_g + bpu_b) | g << (bpu_b) | b


        elif color_system == 1:
            # YIQ
            yiq_org = hue_analysis.rgb_to_yiq(r_org_norm, g_org_norm, b_org_norm)
            y = int(yiq_org[0] * (2 ** bpu_r - 1))
            ii = int(yiq_org[1] * (2 ** bpu_g - 1))
            q = int(yiq_org[2] * (2 ** bpu_b - 1))

            aeb = y << (bpu_g + bpu_b) | ii << (bpu_b) | q


        elif color_system == 2:
            # HSV
            hsv_org = hue_analysis.rgb_to_hsv(r_org_norm, g_org_norm, b_org_norm)

            hh = int(hsv_org[0] * (2 ** bpu_r - 1))
            ss = int(hsv_org[1] * (2 ** bpu_g - 1))
            vv = int(hsv_org[2] * (2 ** bpu_b - 1))

            aeb = hh << (bpu_g + bpu_b) | ss << (bpu_b) | vv


        elif color_system == 3:
            # Y
            # yp is build based on the original true color
            # yp is an 8-bit number in essence.
            yp_org = round(gray_config[0] * rgb[0] + gray_config[1] * rgb[1] + gray_config[2] * rgb[2], 0)
            y = int(yp_org * (2 ** sum_bpu - 1) / 255)

            # print(yp_org)

            aeb = y


        elif color_system == 4:
            # HUE
            hue_org = hue_analysis.rgb_to_hue(r_org_norm, g_org_norm, b_org_norm)
            hue = int(hue_org * (2 ** sum_bpu - 1))

            aeb = hue


        elif color_system == 5:
            # FOCUSED HUE
            hue_org = hue_analysis.rgb_to_hue(r_org_norm, g_org_norm, b_org_norm)


            if hue_min <= hue_org <= hue_max:
                hue_focus = (hue_org - hue_min)/ (hue_max - hue_min)
                hue = int(hue_focus * (2 ** sum_bpu - 1))
            else:
                hue = 0

            aeb = hue

        """
        put the encoded pixel in the buffer
        """
        # print(aeb)
        dd = toBinaryStringofLenght(aeb, sum_bpu)
        aeb_string_buffer = aeb_string_buffer + dd

        if (len(aeb_string_buffer) % 8 == 0):
            chunks = [aeb_string_buffer[i:i + 8] for i in range(0, len(aeb_string_buffer), 8)]
            for b in chunks:

                encoded_buffer[aeb_buffer_counter] = int(b, 2) & 0xff

                aeb_buffer_counter += 1

            aeb_string_buffer = ''





        if idx == 0:
            aeb_payload_buffer = aeb << ((n_pixels - 1) * sum_bpu)
        else:
            aeb_payload_buffer = aeb_payload_buffer | aeb << ((n_pixels - idx - 1) * sum_bpu)


    return encoded_buffer




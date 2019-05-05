import re


# Note: start with ch
#       --> create group channel
#       --> match any character until first : is found
#       --> match next 3 chars --> create group sensors
channel_sensor_index_pattern = r'ch(?P<channel>\d{2}).+?:.{3}(?P<sensor>\d{2})'


def read_output_from_device(file_path):
    # set of tuples
    _output = set()

    with open(file_path) as fp:
        file_content = fp.read()

        for match in re.finditer(channel_sensor_index_pattern, file_content):
            _output.add((match.group('channel'), match.group('sensor')))

    return _output


if __name__ == '__main__':
    alen_of_interest = [('08', '02'), ('02', '02')]

    alen_fag = read_output_from_device('file_to_read.txt')
    print(alen_fag)
    print('are all channel, sensor pairs in file?', all([(ch_sens[0], ch_sens[1]) in alen_fag for ch_sens in alen_of_interest]))

    # print('are all channels in file?', all([channel in channels for channel in channels_of_interest]))
    # print('is any channel in file?', any([channel in channels for channel in channels_of_interest]))
    #
    # print('are all sensors in file?', all([sensor in sensors for sensor in sensors_of_interest]))
    # print('is any sensor in file?', any([sensor in sensors for sensor in sensors_of_interest]))





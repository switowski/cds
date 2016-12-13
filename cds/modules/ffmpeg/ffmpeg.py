# -*- coding: utf-8 -*-
#
# This file is part of CERN Document Server.
# Copyright (C) 2016 CERN.
#
# CERN Document Server is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# CERN Document Server is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CERN Document Server; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307, USA.
#
# In applying this license, CERN does not
# waive the privileges and immunities granted to it by virtue of its status
# as an Intergovernmental Organization or submit itself to any jurisdiction.

"""Python wrappers for the ffmpeg command-line utility."""

from __future__ import absolute_import

from math import gcd
from subprocess import check_output

import json
import pexpect


def ff_probe(input_filename, field):
    """Retrieve requested field from the output of ffprobe.

    **OPTIONS**

    * *-v error* show all errors
    * *-select_streams v:0* select only video stream
    * *-show_entries stream=<field>* show only requested field
    * *-of default=noprint_wrappers=1:nokey=1* extract only values
    """
    return check_output([
        'ffprobe', '-v', 'error',
        '-select_streams', 'v:0',
        '-show_entries', 'stream={}'.format(field),
        '-of', 'default=noprint_wrappers=1:nokey=1',
        '{}'.format(input_filename)
    ]).rstrip()


def ff_probe_all(input_filename):
    """Retrieve all video metadata from the output of ffprobe.

    **OPTIONS**

    * *-v error* show all errors
    * *-show_format -print_format json* output in JSON format
    * *-show_streams -select_streams v:0* show information for video streams
    """
    ffprobe_output = check_output([
        'ffprobe', '-v', 'error',
        '-show_format', '-print_format', 'json',
        '-show_streams', '-select_streams', 'v:0',
        '{}'.format(input_filename)
    ]).decode('utf-8')
    ffprobe_output = json.loads(ffprobe_output)
    ffprobe_output = fix_display_ratio(ffprobe_output)
    return ffprobe_output


def ff_frames(input_file, start, end, step, output, progress_callback=None):
    """Extract requested frames from video.

    :param input_file:
    :param start: percentage of the video to begin extracting frames.
    :param end: percentage of the video to stop extracting frames.
    :param step: percentage between of the video between frames.
    :param output: output folder and format for the file names as in ``ffmpeg``,
        i.e /path/to/somewhere/frames-%d.jpg
    :param progress_callback: function taking as first parameter the number of seconds
        processed and as second parameter the total duration of the video.
    """
    duration = float(ff_probe(input_file, 'duration'))
    # Calculate time step
    start_time = (duration * start / 100)
    end_time = (duration * end / 100)
    time_step = duration * step / 100

    cmd = 'ffmpeg -i {0} -ss {1} -to {2} -vf fps=1/{3} {4}'.format(
        input_file, start_time, end_time, time_step, output
    )

    thread = pexpect.spawn(cmd)

    regex = thread.compile_pattern_list(
        [pexpect.EOF, 'time=(\d\d:\d\d:\d\d).\d\d']
    )
    while True:
        index = thread.expect_list(regex, timeout=None)
        if index == 0:
            break
        elif progress_callback:
            progress_callback(sum(
                int(amount) * 60 ** power for power, amount in
                enumerate(reversed(thread.match.group(1).split(b':')))
            ), duration)


def fix_display_ratio(metadata):
    """Fix the field with display ratio, if it's incorrect.

    Sometimes, ffprobe can't identify the display aspect ratio, but we can
    calculate it from the width and height, so let's fix it.
    """
    def calculate_aspect_ratio(width, height):
        """Calculate the aspect ratio based on the width and height.

        :param width: integer with the width
        :param height: integer with the height
        """
        greatest_common_divisor = gcd(width, height)
        return "{0}:{1}".format(width // greatest_common_divisor,
                                height // greatest_common_divisor)

    aspect_ratio = metadata.get('streams', [])[0].get('display_aspect_ratio')
    if aspect_ratio == '0:1':
        # 0:1 means undefined aspect_ratio. Let's fix it
        width = metadata.get('streams', [])[0].get('width')
        height = metadata.get('streams', [])[0].get('height')
        metadata['streams'][0]['display_aspect_ratio'] = \
            calculate_aspect_ratio(width, height)
    return metadata

import argparse
import os
import csv
from pydub import AudioSegment, scipy_effects

parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input_directory')
parser.add_argument('-s', '--trial_start_times')
parser.add_argument('-t', '--trial_length')
parser.add_argument('-o', '--output_directory')
args = parser.parse_args()

# concatenate all audio files in trial folder
with open(args.trial_start_times, encoding='utf-8-sig') as f:
    reader = csv.reader(f)
    starts = {rows[0]:rows[1] for rows in reader}
    for key in starts:
        starts[key] = int(starts[key]) * 60000

if not os.path.isdir(args.output_directory):
    os.makedirs(args.output_directory)

for folder in os.listdir(args.input_directory):
    trial = os.path.join(args.input_directory, folder)
    if not os.path.isdir(trial):
        continue
    combined = AudioSegment.empty()
    for song in os.listdir(trial):
        if song.endswith('.wav'):
            new = AudioSegment.from_wav(os.path.join(trial, song))
            combined = combined + new
    start_time = starts[folder]
    end_time = starts[folder] + int(args.trial_length) * 60000
    segment = combined[start_time:end_time]
    segment = segment.high_pass_filter(500, order = 5)
    segment = AudioSegment.normalize(segment)
    segment.export(os.path.join(args.output_directory, folder + '.wav'), format= 'wav')

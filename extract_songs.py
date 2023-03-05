import argparse
import os
import numpy as np
from pydub import AudioSegment

parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input_audio')
parser.add_argument('-t', '--timing_files')
parser.add_argument('-o', '--output_audio')
args = parser.parse_args()

if not os.path.isdir(args.output_audio):
    os.makedirs(args.output_audio)

for filename in os.listdir(args.input_audio):
    if filename.endswith('.wav'):
        recording = AudioSegment.from_wav(os.path.join(args.input_audio, filename))
        times = np.genfromtxt(os.path.join(args.timing_files, filename.split('.')[0] + '.csv'), delimiter=',', skip_header = 1) * 1000
        times = times.astype(int)
        for i in range(times.shape[0]):
            segment = recording[times[i,0]:times[i,1]]
            out_name = os.path.join(args.output_audio, filename.split('.')[0] + '_' + str(i + 1) + '.wav')
            segment.export(out_f = out_name, format = 'wav')
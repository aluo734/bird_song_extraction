**The scripts here are an audio processing pipeline that takes raw audio recordings (wav files) from ZEFI experimental trials, finds individual songs, and extracts them from the recordings**

# Inputs and Outputs

## Input files
1. Directory of raw recordings. This directory should include subdirectories, each representing a trials with all the recordings inside.
	- Do not include slashes (forward or backward) or periods in the names. The trial names don't actually have to follow the temp_male_date format, but they should be identical in the directory and csv file of trial start times.

Input_directory
	Temperature_male_date
		audio1.wav
		audio2.wav
		audio3.wav
	Temperature_male_date
		audio1.wav
		audio2.wav
		audio3.wav
	Temperature_male_date
		audio1.wav
		audio2.wav
		audio3.wav

2. One csv file with two columns: (1) the name of the trials and (2) the start times of each trial, relative to the begnning of recording.
	- Do not include a header (first row should be data, not the column names).
 	- Trial names should match the folder names in the directory.
	- Start time should be in minutes

Temperature_male_date, 35
Temperature_male_date, 24
Temperature_male_date, 65

3. Folder with audio templates to look for.
	- For zebra finches, these should be motifs (not whole bouts!) and individual introductory notes. Individual beeps that aren't followed by song motifs will be filtered out.

## Output files
1. A folder containing a concatenated recording of each trial.
2. A folder containing csv files with the start and end times of songs relative to the beginning of the trial, in seconds.
3. A folder containing individual song files.

# Directions
For each step, run the relevant script and replace the names after each flag with your actual paths and values.

1. Concatenate all the short recording clips from each trial into a single audio file, clipped to only the experimental period
```
python3 concatenate_trial_audio.py \
-i [path to directory with raw audio recordings described above] \
-s [csv file with trial start times described above] \
-t [length of trial in minutes] \
-o [path to output folder]
```

2. For each trial, identify the times that each song begins and ends.

The time durations should be in seconds.
```
Rscript bout_identification.R [input audio directory] [template directory] [output directory] [minimum song duration] [minimum gap duration]
```

3. Extract individual songs into new audio clips
```
python3 extract_songs.py \
-i [folder of audio recording of trials, output of step 1] \
-t [folder of csv files with song start and end times, output of step 2] \
-o [path to output folder]
```


## Example
```
python3 concatenate_trial_audio.py \
-i example/raw_experimental_recordings \
-s example/trial_start_times.csv \
-t 5 \
-o example/trial_recordings

Rscript bout_identification.R \
example/trial_recordings \
example/cross_corr_templates \
example/song_starts_ends \
1 \
0.3

python3 extract_songs.py \
-i example/trial_recordings \
-t example/song_starts_ends \
-o example/individual_ZEFI_songs
```

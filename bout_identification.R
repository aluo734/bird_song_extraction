library(magrittr)
library(monitoR)

find_songs <- function(in_audio, template_directory, output_directory, min_song_length = 1, min_song_gap = 0.3) {
  # make templates
  templates <- file.path(template_directory, list.files(template_directory)[1]) %>%
    makeCorTemplate(., overlap = 256, name = list.files(template_directory)[1])
  for (i in list.files(template_directory)[-1]) {
    temp <- makeCorTemplate(file.path(template_directory, i), overlap = 256, name = i)
    templates <- combineCorTemplates(templates, temp)
  }

  # look for template patterns in trial recordings
  cscores <- corMatch(in_audio, survey = , templates = templates, parallel = T, time.source = 'fileinfo')
  detections <- findPeaks(cscores, parallel = TRUE)

  # use template detections to extract detection start and end points
  detection_t <- data.frame(getDetections(detections)[,c(1,3)], start = NA, end = NA)
  
  dur_halfs <- c()
  for (i in list.files(template_directory)) {
    new <- file.path(template_directory, i) %>%
      tuneR::readWave(.) %>%
      length(.)/44100/2
    dur_halfs <- append(dur_halfs, new)
    names(dur_halfs)[length(dur_halfs)] <- i
  }
  for (i in 1:nrow(detection_t)) {
    diff = dur_halfs[detection_t[i,1]]
    detection_t[i,3] = detection_t[i, 2] - diff
    detection_t[i,4] = detection_t[i, 2] + diff
  }

  detection_t <- detection_t[order(detection_t$start),]
  
  # then collapse detections of song templates into song segments
  seg_start = c()
  seg_end = c()
  for (i in 1:nrow(detection_t)) {
    if (i == 1) {
      seg_start = append(seg_start, detection_t[1, 3])
    } else if (i == nrow(detection_t)) {
      seg_end = append(seg_end, detection_t[nrow(detection_t), 4])
    } else {
      if (detection_t[i, 3] > (detection_t[i-1, 4] + as.numeric(min_song_gap))) {
        seg_start = append(seg_start, detection_t[i, 3])
        seg_end = append(seg_end, detection_t[i-1, 4])
      } else {
        next
      }
    }
  }
  
  segment_times <- data.frame(start = sort(seg_start), end = sort(seg_end))

  # remove individual beeps and little sounds
  to_delete = c()
  for (i in 1:nrow(segment_times)) {
    if (segment_times[i, 2] - segment_times[i, 1] < as.numeric(min_song_length)) {
      to_delete = append(to_delete, i)
    }
  }
  if (length(to_delete) > 0) {segment_times = segment_times[-to_delete,]}

  # export segment times as a csv
  if (!dir.exists(output_directory)) {
    dir.create(output_directory)
  }
  out_name <- strsplit(in_audio, '\\/|\\.')[[1]] %>%
    .[length(.)-1] %>%
    paste0(., '.csv') %>%
    file.path(output_directory, .)
  write.csv(segment_times, out_name, row.names = F)
}

args = commandArgs(trailingOnly = T)
for (i in list.files(args[1])) {
  input = file.path(args[1], i)
  find_songs(input, args[2], args[3], args[4], args[5]) %>%
  suppressMessages(.)
}
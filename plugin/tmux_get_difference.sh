#!/bin/bash

if [ $# -ne 6 ]; then
    echo $0: usage: get_difference.sh socket_name target_pane slime_paste_file slime_current_file slime_snapshot_file difference_trim
    exit 1
fi

socket_name=$1
target_pane=$2
slime_paste_file=$3
slime_current_file=$4
slime_snapshot_file=$5
difference_trim=$6

tmux -L $socket_name capture-pane -S -9999 -t $target_pane;
tmux -L $socket_name save-buffer $slime_current_file;
tmux -L $socket_name delete-buffer;

num_current_lines=$(wc -l $slime_current_file | awk '{print $1}');
num_paste_lines=$(wc -l $slime_paste_file | awk '{print $1}');
num_current_lines_trimmed=$(printf "%s" "$(<$slime_current_file)" | wc -l);
num_snapshot_lines_trimmed=$(printf "%s" "$(<$slime_snapshot_file)" | wc -l);

num_diff=$(($num_current_lines_trimmed - $num_snapshot_lines_trimmed - $num_paste_lines + 1));
tail_offset=$(($num_current_lines - $num_snapshot_lines_trimmed - 1));
head_offset=$(($num_diff - $difference_trim));

tail -n $tail_offset $slime_current_file | head -n $head_offset;

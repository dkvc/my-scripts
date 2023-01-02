#!/usr/bin/env bash
export LD_PRELOAD=/lib64/libfreetype.so.6
cd $HOME/MATLAB/MATLAB/bin/
if !(bash matlab -nosplash); then
  sh activate_matlab.sh
else
  bash matlab -desktop
fi
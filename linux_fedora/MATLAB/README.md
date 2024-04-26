# MATLAB Installation Docs

**Prerequisites:** gtk2
If you're using Fedora, `sudo dnf install gtk2`

1. Extract files of MATLAB setup && cd
2. `export LD_PRELOAD=/lib64/libfreetype.so.6`
3. `./install`

4. Change location to home/{your_username}/MATLAB/MATLAB
5. Set bin to home/{your_username}/MATLAB/MATLABbin

6. Download logo from:
https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png
and save it at /home/{your_username}/Pictures/Logo/Matlab_Logo.png

7. cd ~/MATLAB/
8. Create a file named MATLAB.sh (for example, if you're using vim)
vim MATLAB.sh

Copy the following:

```bash
#!/usr/bin/env bash
export LD_PRELOAD=/lib64/libfreetype.so.6
cd $HOME/MATLAB/MATLAB/bin/
if !(bash matlab -nosplash); then
  sh activate_matlab.sh
else
  bash matlab -desktop
fi
```

9. `cd /usr/local/share/applications/`
10. Create a file named MATLAB.desktop using root privileges (for example, if you're using vim)

```bash
sudo vim MATLAB.desktop
```

Now copy the following with your username the places of {your_username}

```
[Desktop Entry]
Name=MATLAB
Exec=sh /home/{your_username}/MATLAB/MATLAB.sh
Icon=/home/{your_username}/Pictures/Logos/Matlab_Logo.png
Type=Application
Categories=Development;
Terminal=false
PrefersNonDefaultGPU=true
```

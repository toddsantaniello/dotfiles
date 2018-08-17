[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

#setxkbmap -variant dvorak
xbindkeys
export _JAVA_AWT_WM_NONREPARENTING=1
exec xmonad

#!/bin/bash
# Khôi phục giao diện Ptyxis gốc (trước khi đổi sang HDH-Dark ngày 2026-10-27)
gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/f88b7a12d22e3c9442ee44086aa05ee6/ palette 'Ubuntu'
gsettings set org.gnome.Ptyxis use-system-font true
gsettings set org.gnome.Ptyxis font-name "Monospace 10"

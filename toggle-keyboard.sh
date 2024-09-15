#!/bin/bash
(setxkbmap -query | grep -q "layout:\s\+us") && setxkbmap de || setxkbmap us

@echo off
call node Server.js -h 127.0.0.1 -p 3011
call index.html
call node debug P1.js -h 127.0.0.1 -p 3011
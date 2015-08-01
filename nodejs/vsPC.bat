@echo off
cls

start node Server.js -h 127.0.0.1 -p 3011 -k 30 11
start index.html

REM start "Bot C++" cmd /c call P1.exe -h 127.0.0.1 -p 3011 -k 30
start node P2.js -h 127.0.0.1 -p 3011 -k 30
REM start "Bot Java" cmd /c call java -jar P1.jar -h 127.0.0.1 -p 3011 -k 30

start "Bot C++" cmd /c call "e:\Workspace\project150614\trunk\c++\2008_release\AI_Template.exe" -h 127.0.0.1 -p 3011 -k 11
REM start node P2.js -h 127.0.0.1 -p 3011 -k 11
REM start "Bot Java" cmd /c call java -jar P2.jar -h 127.0.0.1 -p 3011 -k 11
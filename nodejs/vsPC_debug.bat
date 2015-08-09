@echo off

SET mypath=%~dp0
pushd %mypath:~0,-1%

start node Server.js -h 127.0.0.1 -p 3011 -k 30 11
start index.html

start node P1.js -h 127.0.0.1 -p 3011 -k 30

popd
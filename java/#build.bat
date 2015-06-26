@echo off
javac -cp ".;tyrus-standalone-client-1.10.jar" *.java
jar cvfm Client.jar manifest.txt *.class
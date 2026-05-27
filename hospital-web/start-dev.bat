@echo off
set PATH=C:\Users\京康\Desktop\医院管理系统\node-v16.20.2-win-x64;%PATH%
cd /d C:\Users\京康\Desktop\医院管理系统\hospital-web
node node_modules\cross-env\dist\bin\cross-env.js NODE_ENV=development node node_modules\webpack-dev-server\bin\webpack-dev-server.js --open --hot

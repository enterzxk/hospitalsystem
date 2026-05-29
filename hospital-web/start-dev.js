const cp = require('child_process');
const path = require('path');

const nodeExe = path.join(__dirname, '..', 'node-v16.20.2-win-x64', 'node.exe');
const webpackDevServer = path.join(__dirname, 'node_modules', 'webpack-dev-server', 'bin', 'webpack-dev-server.js');

const server = cp.spawn(nodeExe, [webpackDevServer, '--open', '--hot'], {
  cwd: __dirname,
  env: { ...process.env, NODE_ENV: 'development' },
  stdio: 'inherit'
});

server.on('error', (e) => console.error('Server error:', e));
server.on('exit', (code) => console.log('Server exited with code:', code));

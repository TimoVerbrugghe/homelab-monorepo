const { spawn } = require('node:child_process');
const { createHash } = require('node:crypto');
const { mkdirSync } = require('node:fs');
const { homedir, tmpdir } = require('node:os');
const { join } = require('node:path');

const userId = createHash('sha256').update(homedir()).digest('hex').slice(0, 12);
const directory = join(tmpdir(), `proxmox-mcp-${userId}`);
mkdirSync(directory, { recursive: true, mode: 0o700 });

const child = spawn('uvx', ['proxmox-mcp-plus'], {
  env: {
    ...process.env,
    PROXMOX_JOBS_SQLITE_PATH: join(directory, 'proxmox-jobs.sqlite3'),
  },
  stdio: 'inherit',
});

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, () => child.kill(signal));
}

child.on('error', (error) => {
  console.error('Failed to start Proxmox MCP:', error.message);
  process.exitCode = 1;
});
child.on('exit', (code) => {
  process.exitCode = code ?? 1;
});

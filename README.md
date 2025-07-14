# Nginx + PHP8.3 + Node.js + NVM Docker Image

## Pre-configured Environment Variables

The following environment variables are pre-set in the Docker image:

```bash
NODE_BINARY=/usr/bin/node
NPM_BINARY=/usr/bin/npm
CHROME_PATH=/usr/bin/chromium-browser
NODE_MODULES_PATH=/usr/lib/node_modules
```

## Laravel Configuration

In a Laravel application, you can use these environment variables in your `.env` file:

```env
NODE_BINARY=/usr/bin/node
NPM_BINARY=/usr/bin/npm
CHROME_PATH=/usr/bin/chromium-browser
NODE_MODULES_PATH=/usr/lib/node_modules
```

## How It Works

1. **Stable Binary Paths**: The Node.js and npm binaries are symlinked from the NVM installation to `/usr/bin/`, providing consistent paths regardless of NVM version changes.

2. **Global Node Modules**: Global node modules (including Puppeteer) are symlinked to `/usr/lib/node_modules/` for a stable reference path.

3. **NVM Flexibility**: While SSH'd into the container, you can still use NVM to switch Node versions for testing or development. The symlinks at `/usr/bin/` will always point to the default NVM version set in the Dockerfile.

## Puppeteer/Browsershot Configuration

For Spatie Browsershot, the Chromium executable is available at:
- `/usr/bin/chromium-browser`

You can configure this in your Laravel application:

```php
use Spatie\Browsershot\Browsershot;

Browsershot::html($html)
    ->setChromePath('/usr/bin/chromium-browser')
    ->setNodeBinary('/usr/bin/node')
    ->setNpmBinary('/usr/bin/npm')
    ->setNodeModulesPath('/usr/lib/node_modules')
    ->save($pathToImage);
```

## Updating Node Version in Runtime

If you need to change the Node version while SSH'd in:

```bash
nvm install 18
nvm use 18
# Update symlinks to point to new version
ln -sf $NVM_DIR/versions/node/v18.*/bin/node /usr/bin/node
ln -sf $NVM_DIR/versions/node/v18.*/bin/npm /usr/bin/npm
```

Note: This change will be temporary and reset when the container restarts.

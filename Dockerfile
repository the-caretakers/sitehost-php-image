FROM registry.sitehost.co.nz/sitehost-php83-nginx:5.0.1-noble

# Support for Spatie/Browsershot (headless chromium PDF generation) - Ubuntu 24.04 compatible
RUN apt-get update \
    && apt-get install -y gconf-service libasound2t64 libatk1.0-0t64 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0t64 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libnss3 lsb-release xdg-utils wget libgbm-dev libxshmfence-dev \
    && npm install --global --unsafe-perm puppeteer \
    && chmod -R o+rx /usr/local/lib/node_modules/puppeteer/.local-chromium

# Create stable symlinks for Node.js binaries
RUN ln -sf /usr/local/bin/node /usr/bin/node \
    && ln -sf /usr/local/bin/npm /usr/bin/npm \
    && ln -sf /usr/local/bin/npx /usr/bin/npx

# Create a stable global node_modules location
RUN mkdir -p /usr/lib/node_modules \
    && ln -sf /usr/local/lib/node_modules/* /usr/lib/node_modules/

# Set environment variables for Laravel apps
ENV NODE_BINARY=/usr/bin/node
ENV NPM_BINARY=/usr/bin/npm
ENV NODE_MODULES_PATH=/usr/lib/node_modules

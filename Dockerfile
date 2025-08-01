FROM registry.sitehost.co.nz/sitehost-php83-nginx:5.0.1-noble

# Support for Spatie/Browsershot (headless chromium PDF generation)
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && apt-get install -y libasound2t64 libatk1.0-0t64 libc6 libcairo2 libcups2t64 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libgdk-pixbuf2.0-0 libglib2.0-0t64 libgtk-3-0t64 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libnss3 lsb-release xdg-utils wget libgbm-dev libxshmfence-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create Chrome user data directory with proper permissions
RUN mkdir -p /var/www/.local/share/applications \
    && mkdir -p /var/www/.cache/google-chrome \
    && mkdir -p /tmp/chrome-user-data \
    && chown -R www-data:www-data /var/www/.local \
    && chown -R www-data:www-data /var/www/.cache \
    && chown -R www-data:www-data /tmp/chrome-user-data \
    && chmod -R 755 /var/www/.local \
    && chmod -R 755 /var/www/.cache \
    && chmod -R 755 /tmp/chrome-user-data

# Make an explicit crash dumps directory
RUN mkdir -p /tmp/chrome-crash-dumps \
    && chown -R www-data:www-data /tmp/chrome-crash-dumps \
    && chmod -R 755 /tmp/chrome-crash-dumps

# Set up www-data user environment properly
RUN usermod -d /var/www www-data \
    && mkdir -p /var/www \
    && chown www-data:www-data /var/www \
    && chmod 755 /var/www

# Create stable symlinks for Node.js binaries
RUN ln -sf /usr/local/bin/node /usr/bin/node \
    && ln -sf /usr/local/bin/npm /usr/bin/npm \
    && ln -sf /usr/local/bin/npx /usr/bin/npx

# Set environment variables for Laravel apps and Puppeteer
ENV NODE_BINARY=/usr/bin/node
ENV NPM_BINARY=/usr/bin/npm
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu --disable-web-security --font-render-hinting=none --user-data-dir=/tmp/chrome-user-data"
ENV CHROME_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu --disable-web-security --font-render-hinting=none --user-data-dir=/tmp/chrome-user-data"
ENV PUPPETEER_CACHE_DIR=/var/www/.cache/puppeteer

FROM registry.sitehost.co.nz/sitehost-php83-nginx:5.0.1-noble

# Install Chromium and dependencies for Puppeteer
RUN apt-get update \
    && apt-get install -y \
    # Basic tools
    curl \
    gnupg \
    ca-certificates \
    # Chromium browser
    chromium-browser \
    # Additional fonts for better rendering
    fonts-liberation \
    fonts-noto-color-emoji \
    fontconfig \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Install Puppeteer globally using existing Node.js installation
RUN npm install --global --unsafe-perm puppeteer

# Create stable symlinks for Node.js binaries (from /usr/local/bin to /usr/bin for consistency)
RUN ln -sf /usr/local/bin/node /usr/bin/node \
    && ln -sf /usr/local/bin/npm /usr/bin/npm \
    && ln -sf /usr/local/bin/npx /usr/bin/npx

# Create a stable global node_modules location
RUN mkdir -p /usr/lib/node_modules \
    && ln -sf /usr/local/lib/node_modules/* /usr/lib/node_modules/

# Set environment variables for Laravel apps
ENV NODE_BINARY=/usr/bin/node
ENV NPM_BINARY=/usr/bin/npm
ENV CHROME_PATH=/usr/bin/chromium-browser
ENV NODE_MODULES_PATH=/usr/lib/node_modules

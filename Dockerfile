FROM registry.sitehost.co.nz/sitehost-php83-nginx:5.0.1-noble

# Install dependencies and download actual Chromium binary
RUN apt-get update \
    && apt-get install -y \
    # Basic tools
    curl \
    gnupg \
    ca-certificates \
    wget \
    unzip \
    # Additional fonts for better rendering
    fonts-liberation \
    fonts-noto-color-emoji \
    fontconfig \
    # Dependencies for Chromium (Ubuntu 24.04 Noble compatible)
    libasound2t64 \
    libatk-bridge2.0-0t64 \
    libdrm2 \
    libgtk-3-0t64 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libxss1 \
    libxfixes3 \
    libxinerama1 \
    libxkbcommon0 \
    libatk1.0-0t64 \
    libcairo-gobject2 \
    libgtk-4-1 \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Let Puppeteer download its own Chromium (most reliable)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false

# Install Puppeteer globally - it will download its own compatible Chromium
RUN npm install --global --unsafe-perm puppeteer

# Find and symlink the Puppeteer Chromium to a standard location
RUN CHROME_PATH=$(find /usr/local/lib/node_modules/puppeteer/.local-chromium -name chrome -type f 2>/dev/null | head -1) \
    && if [ -n "$CHROME_PATH" ]; then \
        ln -sf "$CHROME_PATH" /usr/bin/chromium-browser; \
        echo "Chromium symlinked from $CHROME_PATH"; \
    else \
        echo "ERROR: Could not find Puppeteer Chromium binary"; \
        exit 1; \
    fi

# Set environment variables pointing to Puppeteer's Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

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

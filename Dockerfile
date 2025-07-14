FROM registry.sitehost.co.nz/sitehost-php83-nginx:5.0.1-noble

# Install actual Chromium (not the snap wrapper)
RUN apt-get update \
    && apt-get install -y \
    # Basic tools
    curl \
    gnupg \
    ca-certificates \
    wget \
    # Additional fonts for better rendering
    fonts-liberation \
    fonts-noto-color-emoji \
    fontconfig \
    # Dependencies for Chromium
    libasound2 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libxss1 \
    # Try installing chromium directly (not chromium-browser which is snap wrapper)
    && apt-get install -y chromium \
    # If chromium package doesn't exist, install from alternative source
    || (wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
        && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
        && apt-get update \
        && apt-get install -y chromium-browser --no-install-recommends) \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for consistent chromium path
RUN if [ -f /usr/bin/chromium ]; then \
        ln -sf /usr/bin/chromium /usr/bin/chromium-browser; \
    elif [ -f /usr/bin/chromium-browser ]; then \
        echo "chromium-browser already exists"; \
    else \
        echo "No chromium binary found"; \
    fi

# Set environment variables for Puppeteer to use Chromium
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

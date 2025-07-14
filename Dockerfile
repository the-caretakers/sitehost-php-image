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

# Install NVM (Node Version Manager) and Node.js 20
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=20

RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Add node and npm to path so the commands are available
ENV NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Set environment variables for Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Install Puppeteer globally (without downloading Chromium)
RUN . $NVM_DIR/nvm.sh \
    && npm install --global --unsafe-perm puppeteer

# Create stable symlinks for Node.js binaries that won't change with NVM version switches
RUN ln -sf $NVM_DIR/versions/node/v$NODE_VERSION/bin/node /usr/bin/node \
    && ln -sf $NVM_DIR/versions/node/v$NODE_VERSION/bin/npm /usr/bin/npm \
    && ln -sf $NVM_DIR/versions/node/v$NODE_VERSION/bin/npx /usr/bin/npx

# Create a stable global node_modules location
RUN mkdir -p /usr/lib/node_modules \
    && ln -sf $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules/* /usr/lib/node_modules/

# Set environment variables for Laravel apps
ENV NODE_BINARY=/usr/bin/node
ENV NPM_BINARY=/usr/bin/npm
ENV CHROME_PATH=/usr/bin/chromium-browser
ENV NODE_MODULES_PATH=/usr/lib/node_modules

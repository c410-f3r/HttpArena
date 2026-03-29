FROM ubuntu:24.04
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates git python3 make g++ && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY package.json .
RUN npm install --omit=dev
COPY server.js .
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "server.js"]

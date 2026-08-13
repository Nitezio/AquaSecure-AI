FROM node:20-slim

WORKDIR /app

COPY package.json ./
RUN npm install

COPY src ./src
COPY data ./data

ENV WS_PORT=3001
EXPOSE 3001

CMD ["node", "src/index.js"]

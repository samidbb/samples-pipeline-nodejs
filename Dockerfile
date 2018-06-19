FROM node:alpine

WORKDIR /app
COPY ./src ./

RUN npm install --production

ENTRYPOINT [ "node", "main.js" ]
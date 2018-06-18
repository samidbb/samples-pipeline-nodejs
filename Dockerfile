FROM node:alpine

WORKDIR /app
COPY ./src ./

RUN npm install

ENTRYPOINT [ "node", "main.js" ]
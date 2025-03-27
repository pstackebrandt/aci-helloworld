FROM node:20-alpine

LABEL version="1.0.3" \
      description="Azure Container Instances Hello World Application" \
      maintainer="pstackebrandt"

RUN mkdir -p /usr/src/app
COPY ./app/* /usr/src/app/
WORKDIR /usr/src/app
RUN npm install
CMD ["node", "/usr/src/app/index.js"]
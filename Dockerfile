# To build nodejs_app image:
#     docker build -t nodejs_app_image .
# 
# To run nodejs_app container:
#     docker run --rm --name nodejs_app -d -p 3000:3000 -p 9229:9229 nodejs_app_image
#     
#
# To open terminal in nodejs_app container:
#     docker exec -it nodejs_app /bin/bash

FROM node:10.5.0

# Create app directory
WORKDIR /usr/nodejs_app

# what port your app runs on
EXPOSE 3000 

# what port you need to debug on
EXPOSE 9229 

# upgrade yarn
ENV YARN_VERSION 1.9.4

RUN curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
    && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
    && ln -snf /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -snf /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
    && rm yarn-v$YARN_VERSION.tar.gz


# Copy package.json before coping source files to cache node modules
COPY package.json .

# Install dependencies
RUN yarn install

# Copy source code to the image
COPY . .

# Start app_server in debug mode.
# Container is a different host with a different IP than our host machine.
# Address 0.0.0.0 opens debugger for connection from any IP. Of course,
# we won't do this on live servers.
# In Part 2 I moved  CMD to the docker-compose file
# CMD ["node", "--inspect=0.0.0.0","index.js"]


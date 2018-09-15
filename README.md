# Using VS Code & Docker for developing and debugging NodeJS apps

## Part 1

This setup covers minimal setup for:

- running NodeJS app in Docker container.
- debugging NodeJS app in VS Code.

Take a look at `Dockerfile`, `.vscode/launch.json` and `.dockerignore`.
They are well documented and self explained.

1. Build the image:

`docker build -t nodejs_app_image .`

2. Run the app in the Docker container

`docker run --rm --name nodejs_app -d -p 3000:3000 -p 9229:9229 nodejs_app_image`

3. Open VS Code and set the breakpoint at the `index.js:8`.

4. Run `Attach to Docker` from the Debugger Side Bar.

4. Execute `curl http://localhost:3000` from the terminal.

Application should stop at the breakpoint.


## Part 2: simplifying docker interaction

If we change the source code, we need to stop and remove container, rebuild the
image and start the container again:


    docker container stop nodejs_app  
    docker build -t nodejs_app_image .
    docker run --rm --name nodejs_app -d -p 3000:3000 -p 9229:9229 nodejs_app_image 

First command will stop and remove container because of `--rm` flag.

This is a quite a lot of things to do. This workflow can be simplified using `docker-compose` tool. Take a look at the `docker-compose.yml`.

Execute 
  
    docker-compose up
    
to build image and run container. It has the same effect as

    docker build -t nodejs_app_image .
    docker run --rm --name nodejs_app -d -p 3000:3000 -p 9229:9229 nodejs_app_image

To stop and remove container, run 

    docker-compose down

When we change the source, we need to rebuild image with

    docker-compose up --build

### Running app in detached (background) mode

    docker-compose up -d

To view app output, open another terminal and run

    docker logs nodejs_app

## Part 3: Making changes in the source files

So far, whenever we changed source file, we had to rebuild the image and
restart container which takes time. Our goal in this step is to whenever we
change the source file on host machine to automatically restart the app.
To do that we will use `nodemon`. Nodemon watches the changes in project files
and restarts the server as needed. This is also out first dependency we use.

1. Get the nodemon version info

    yarn info nodemon versions

2. Add `nodemon` dependency in the `package.json`:

```json
    "devDependencies": {
        "nodemon": "^1.18.4"
    }
```

3. Add `dev` script in package.json.

```json
    "scripts": {
        "dev": "nodemon --inspect=0.0.0.0 index.js"
    }
```

4. Change the command and add map the project directory in `docker-compose.yml` file:

```yml
    command:
    - yarn
    - 'run'
    - 'dev'
    volumes:
    - .:/usr/nodejs_app
```

Now we start app server is `yarn run dev`. We also map host app directory to
container app directory. It is important to specify `node_modules` in 
`.dockerignore`.

Execute 

    docker-compose up

and test is VS Code debugger is still working. Now, change the `index.js:8` line
to `response.end('Hello World 2\n');`. You should see that server is automatically
restarted and changes applied. You do not need to rebuild the image and restart
container. However, running debugger in VSCode is disconnected and you need to 
start it again to continue debugging.
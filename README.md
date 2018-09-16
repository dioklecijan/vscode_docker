# Using VS Code & Docker for developing and debugging NodeJS apps

## Part 1: Running NodeJS app in Docker container and debugging in VS Code

This step covers minimal setup for:

- running NodeJS app in Docker container.
- debugging NodeJS app in VS Code.

Open the git branch 'part_1' and take a look at `Dockerfile`, `.vscode/launch.json` 
and `.dockerignore`. They are well documented and self explained.

1. Build the image:

`docker build -t nodejs_app_image .`

2. Run the app in the Docker container:

`docker run --rm --name nodejs_app -d -p 3000:3000 -p 9229:9229 nodejs_app_image`

3. Open VS Code and set the breakpoint at the `index.js:8`.

4. Run `Attach to Docker` from the Debugger Side Bar.

4. Execute `curl http://localhost:3000` from the terminal.

Application should stop at the breakpoint.


## Part 2: Simplifying docker interaction

If we change the source code, we need to stop and remove container, rebuild the
image and start the container again:


    docker container stop nodejs_app  
    docker build -t nodejs_app_image .
    docker run --rm --name nodejs_app -d -p 3000:3000 -p 9229:9229 nodejs_app_image 

This workflow can be simplified using `docker-compose` tool. 

Switch to the git branch 'part_2'. Take a look at the `docker-compose.yml`.
I moved command for running app from `Dockerfile` to `docker-compose.yml`. 
This way, my Dockerfile or better say Docker image, is usable for other 
environments ('test', 'production').

Execute 
  
    docker-compose up
    
to build an image and run container. It has the same effect as

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

## Part 3: Automatically applying changes in the Docker app

So far, whenever we changed source file, we had to rebuild the image and
restart container which takes time. Our goal in this step is to whenever we
change the source file on host machine to automatically restart the app.
To do that we will use `nodemon` package. Package `nodemon` watches the changes in project files and restarts the server as needed. 

1. Get the `nodemon` version info

    yarn info nodemon versions

2. Add `nodemon` dependency in the `package.json`:

```json
    "devDependencies": {
        "nodemon": "^1.18.4"
    }
```

3. Add `dev` script in `package.json`.

```json
    "scripts": {
        "dev": "nodemon --inspect=0.0.0.0 index.js"
    }
```

4. Change the command and map the directories in `docker-compose.yml` file.

```yml
    command:
    - yarn
    - 'run'
    - 'dev'
    volumes:
    - .:/usr/nodejs_app
    - /usr/nodejs_app/node_modules
```

We start the app using `yarn run dev`. Host app directory (`.`) is mapped 
to the container app directory (`/usr/nodejs_app`). We need this because the 
changes we make in the source code on the host machine has to be automatically 
synchronized and applied to the app running in the container. However, we must
not synchronize `node_modules` between host and container.

Execute 

    docker-compose up

and test is VS Code debugger is still working. Now, change the `index.js:8` line
to `response.end('Hello World 2\n');`. You should see that server is automatically
restarted and changes applied. You do not need to rebuild the image and restart
container. However, running debugger in VSCode is disconnected and you need to 
start it again to continue debugging.
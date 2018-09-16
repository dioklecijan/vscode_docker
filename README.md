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

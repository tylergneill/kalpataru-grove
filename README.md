# kalpataru-grove

Website for the Kalpataru Grove ecosystem of digital Sanskrit projects.

This repo also serves as the source of truth for the build and deployment scripts used across local machines and the remote server. This has been done to increase transparency into how the Kalpataru Grove server is managed, so that others may learn from it. 

## Build and Deployment Process

This section documents the full workflow for building and deploying Kalpataru Grove apps, from local code change to running container on the server. The workflow uses Docker throughout: staging and production images are built from separate Dockerfiles, pushed to Docker Hub, then pulled and run on the server as containers on distinct ports (e.g. production skrutable on 5010, staging on 5012), each mapped by Nginx to its own domain (e.g. skrutable.info vs. skrutable-stg.duckdns.org). The scripts in this repo cover the local build process, server redeployment, and (TODO) Nginx configuration.

### Local machines

1. Clone this repo: `git clone https://github.com/tylergneill/kalpataru-grove`
2. Add to `~/.zshrc` or `~/.bashrc`:
   ```bash
   source /path/to/kalpataru-grove/scripts/build.sh
   ```
3. Adjust the Docker Hub username in `scripts/build.sh` as needed.

To build and push a Docker image, export the required env vars and run:
```bash
export APP_NAME=my-app
export VERSION=1.2.3
build_and_push         # targets Dockerfile (production)
build_and_push --stg   # targets Dockerfile.stg (staging)
```

### Remote server

1. Clone this repo: `git clone https://github.com/tylergneill/kalpataru-grove`
2. Adjust the Docker Hub username, server paths, and app/port entries in `scripts/redeploy.sh` as needed.
3. Add to `~/.bashrc`:
   ```bash
   source /path/to/kalpataru-grove/scripts/redeploy.sh
   ```

To redeploy a container:
```bash
redeploy <app_name> <version> [--stg]
```

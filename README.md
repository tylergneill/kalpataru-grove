# kalpataru-grove

Website for the Kalpataru Grove ecosystem of digital Sanskrit projects.

This repo also serves as the source of truth for the build and deployment scripts used across local machines and the remote server. This has been done to increase transparency into how the Kalpataru Grove server is managed, so that others may learn from it. 

## Build and Deployment Process

This section documents the full workflow for building and deploying Kalpataru Grove apps, from local code change to running container on the server. The workflow uses Docker throughout: staging and production images are built from separate Dockerfiles, pushed to Docker Hub, then pulled and run on the server as containers on distinct ports (e.g. production skrutable on 5010, staging on 5012), each mapped by Nginx to its own domain (e.g. skrutable.info vs. skrutable-stg.duckdns.org). The scripts in this repo cover the local build process, server redeployment, and (TODO) Nginx configuration.

### Local machines

1. Clone this repo: `git clone https://github.com/tylergneill/kalpataru-grove`
2. Add to `~/.zshrc` or `~/.bashrc`:
   ```bash
   source /path/to/kalpataru-grove/scripts/build_script.sh
   ```
3. Adjust any paths in `scripts/build_script.sh` as needed for your machine.

To build and push a Docker image, export the required env vars and run:
```bash
export APP_NAME=my-app
export VERSION=1.2.3
build_and_push         # targets Dockerfile (production)
build_and_push --stg   # targets Dockerfile.stg (staging)
```

### Remote server

1. Clone this repo: `git clone https://github.com/tylergneill/kalpataru-grove`
2. Adjust any paths in `scripts/redeploy_script.sh` as needed for the server.
3. Update the path in `scripts/redeploy_script_wrapper.sh` to match where the repo is cloned.
4. Add to `~/.bashrc`:
   ```bash
   source /path/to/kalpataru-grove/scripts/redeploy_script_wrapper.sh
   ```

To redeploy a container:
```bash
redeploy <app_name> <version> [--stg]
```

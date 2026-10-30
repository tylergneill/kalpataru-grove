LOCAL_DATA_PATH = $(shell realpath $(dir $(lastword $(MAKEFILE_LIST)))../kalpataru-grove-data)
# (or export LOCAL_DATA_PATH env var if different from above)

# for temporary local builds with full data
run:
	docker build . -f Dockerfile.dev -t kalpataru-grove-dev:debug
	docker run \
	  --rm \
	  -it \
	  -p 5062:5062 \
	  --name kalpataru-grove-dev \
	  kalpataru-grove-dev:debug

# for official stg and prod builds uploaded to Docker Hub
# to use: VERSION={version} make run-official
# (host side is 5062 because browsers block 5060/5061 as SIP ports)
run-official:
	docker run \
	  --rm \
	  -it \
	  -p 5062:5060 \
	  tylergneill/kalpataru-grove-app:$(VERSION)

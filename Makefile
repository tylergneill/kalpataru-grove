LOCAL_DATA_PATH = $(shell realpath $(dir $(lastword $(MAKEFILE_LIST)))../kalpataru-grove-data)
# (or export LOCAL_DATA_PATH env var if different from above)

# for temporary local builds with full data
run:
	docker build . -f Dockerfile.stg -t kalpataru-grove-dev:debug
	docker run \
	  --rm \
	  -it \
	  -p 5081:5081 \
	  --name kalpataru-grove-dev \
	  kalpataru-grove-dev:debug

# for official stg and prod builds uploaded to Docker Hub
# to use: VERSION={version} make run-official
run-official:
	docker run \
	  --rm \
	  -it \
	  -p 5080:5080 \
	  tylergneill/kalpataru-grove-app:$(VERSION)

ngrok:
	ngrok http 5081
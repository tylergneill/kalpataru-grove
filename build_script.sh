build_and_push() {
    DOCKERFILE="Dockerfile"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --stg)
                DOCKERFILE="Dockerfile.stg"
                shift
                ;;
            *)
                echo "Unknown argument: $1"
                return 1
                ;;
        esac
    done

    echo "Using Dockerfile: $DOCKERFILE"
    docker build -f "$DOCKERFILE" . --platform linux/amd64 -t tylergneill/"$APP_NAME"-app:"$VERSION"
    docker push tylergneill/"$APP_NAME"-app:"$VERSION"
}
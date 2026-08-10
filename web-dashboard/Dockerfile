FROM alpine:3.20

WORKDIR /app

COPY pubspec.yaml ./
COPY lib ./lib

EXPOSE 8080

CMD ["sh", "-c", "echo 'Flutter workspace scaffold ready on port 8080' && tail -f /dev/null"]

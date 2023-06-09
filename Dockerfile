# Dockerfile used in execution of Github Action
FROM denis256/tg-gh-action:master

# Uncomment to enable tracing of each command
# ENV TRACE=1

COPY ["./src/main.sh", "/action/main.sh"]
ENTRYPOINT ["/action/main.sh"]

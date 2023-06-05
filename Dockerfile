# Dockerfile used in execution of Github Action
FROM denis256/tg-gh-action:bdaf2414d00462fbcc86af5f7fca411d2dafdbab

ENV TF_INPUT=false
ENV TF_IN_AUTOMATION=1
ENV TRACE=1

# Dockerfile used in execution of Github Action
FROM denis256/tg-gh-action:master

ENV TF_INPUT=false
ENV TF_IN_AUTOMATION=1
ENV TRACE=1

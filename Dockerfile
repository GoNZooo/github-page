FROM ubuntu:14.04

# Update packages and install curl
RUN apt-get update
RUN apt-get install -y curl

# Fetch Racket from site, Ubuntu packages are extremely old
RUN curl http://mirror.racket-lang.org/installers/6.2/racket-6.2-x86_64-linux-ubuntu-precise.sh > racket.sh
RUN echo "yes\n1\n" | /bin/bash racket.sh
RUN rm racket.sh

# Copy github-page source to filesystem
COPY src /github-page-src
WORKDIR /github-page-src

EXPOSE 8080

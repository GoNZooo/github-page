FROM gonz/racket
MAINTAINER Rickard Andersson <gonz@severnatazvezda.com>

# Copy github-page source to filesystem
COPY src /github-page-src
WORKDIR /github-page-src

EXPOSE 8080
CMD ["racket", "web-start.rkt"]

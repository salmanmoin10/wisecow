FROM ubuntu:22.04

RUN apt-get update && apt-get install -y fortune-mod cowsay netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY wisecow.sh /app/wisecow.sh

WORKDIR /app

RUN chmod +x wisecow.sh

ENV PATH="/usr/games:${PATH}"

EXPOSE 4499

CMD ["/bin/bash", "-c", "PATH=/usr/games:$PATH ./wisecow.sh"]
FROM denoland/deno:1.27.0

EXPOSE 3000

ENV BACKEND_PORT 3000

WORKDIR /app

USER deno

COPY deps.ts .
RUN deno cache deps.ts

ADD . .

RUN deno cache src/main.ts

CMD ["run", "--allow-net", "--allow-env", "src/main.ts"]

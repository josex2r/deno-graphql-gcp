FROM denoland/deno:1.10.3

EXPOSE 3000

ENV BACKEND_PORT 3000

WORKDIR /app

USER deno

COPY deps.ts .
RUN deno cache deps.ts

ADD . .
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache src/main.ts

CMD ["run", "--allow-net", "--allow-env", "src/main.ts"]

import { Application, applyGraphQL, Router } from "./dependencies.ts";
import { MessageResolver } from "./resolver/message.ts";
import { MessageSchema } from "./schema/message.ts";

const app = new Application();

app.use(async (ctx, next) => {
  await next();

  const rt = ctx.response.headers.get("X-Response-Time");

  console.log(`${ctx.request.method} ${ctx.request.url} - ${rt}`);
});

app.use(async (ctx, next) => {
  const start = Date.now();

  await next();

  const ms = Date.now() - start;

  ctx.response.headers.set("X-Response-Time", `${ms}ms`);
});

const GraphQLService = await applyGraphQL<Router>({
  Router,
  typeDefs: MessageSchema,
  resolvers: MessageResolver,
});

app.use(GraphQLService.routes(), GraphQLService.allowedMethods());

console.log("Server start at http://localhost:3000");

await app.listen({ port: 3000 });

import { db } from "../database.ts";
import { MessageInput } from "../types.d.ts";

export const MessageResolver = {
  Query: {
    getMessage(_: unknown, { id }: { id: string }) {
      return db.get(id);
    },

    getAllMessages() {
      return db.list();
    },
  },

  Mutation: {
    async createMessage(_: unknown, { input }: { input: MessageInput }) {
      const message = await db.push(input);

      return message;
    },
  },
};

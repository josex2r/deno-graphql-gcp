import { LRU, uuid } from "../deps.ts";
import { Message, MessageInput } from "./types.d.ts";

const NAMESPACE_UUID = "6ba7b810-9dad-11d1-80b4-00c04fd430c8";

const cache = new LRU<string, Message>({
  max: 50,
  maxAge: 1000 * 60 * 60,
});

export const db = {
  async push(message: MessageInput): Promise<Message> {
    const uuidData = new TextEncoder().encode(message.body);
    const id = await uuid.v5.generate(NAMESPACE_UUID, uuidData);
    const data = {
      ...message,
      id,
    };

    cache.set(id, data);

    return data;
  },

  get(id: string) {
    return cache.get(id);
  },

  list() {
    return cache.values();
  },
};

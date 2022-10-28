import { gql } from "../../deps.ts";

export const MessageSchema = gql`
scalar Date

type Message {
  id : ID!
  author: String!
  body: String!
  date: Int!
}

input MessageInput {
  author: String!
  body: String!
  date: Int!
}

type Query {
  getMessage(id: ID!): Message
  getAllMessages: [Message]!
}

type Mutation {
  createMessage(input: MessageInput!): Message!
}
`;

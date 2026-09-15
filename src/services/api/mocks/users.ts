import type { StudentUser } from "@models/auth";

export type MockAccount = {
  password: string;
  user: StudentUser;
};

/**
 * Stand-in for the institution's user provisioning system (see docs/01,
 * section 4): accounts are pre-provisioned, never self-registered.
 */
const MOCK_ACCOUNTS: MockAccount[] = [
  {
    password: "123456",
    user: {
      id: "u_igorpereira",
      name: "Igor Pereira",
      email: "igor@email.com",
      registrationId: "senaiigorpereira",
      course: "Análise e Desenvolvimento de Sistemas",
    },
  },
];

export function findAccountByIdentifier(identifier: string): MockAccount | undefined {
  const normalized = identifier.trim();
  return MOCK_ACCOUNTS.find(
    (account) =>
      account.user.email.toLowerCase() === normalized.toLowerCase() ||
      account.user.registrationId === normalized,
  );
}

export function findAccountById(id: string): MockAccount | undefined {
  return MOCK_ACCOUNTS.find((account) => account.user.id === id);
}

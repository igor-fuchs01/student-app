import type { StudentUser } from "@models/auth";

export type MockAccount = {
  accessCode: string;
  password: string;
  user: StudentUser;
};

/**
 * Stand-in for the institution's user provisioning system (see docs/01,
 * section 4): accounts are pre-provisioned, never self-registered, and log in
 * with an access code instead of any personal data.
 */
const MOCK_ACCOUNTS: MockAccount[] = [
  {
    accessCode: "demo0001",
    password: "123456",
    user: {
      id: "u_demo0001",
      course: "Análise e Desenvolvimento de Sistemas",
    },
  },
];

export function findAccountByAccessCode(accessCode: string): MockAccount | undefined {
  return MOCK_ACCOUNTS.find((account) => account.accessCode === accessCode);
}

export function findAccountById(id: string): MockAccount | undefined {
  return MOCK_ACCOUNTS.find((account) => account.user.id === id);
}

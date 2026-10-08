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

// Codes the operator handed out for the first access (available_logins in the database); each
// becomes an account once claimed. Like the attempts, it resets when the page reloads.
const MOCK_AVAILABLE_LOGINS = new Set(["novo0001", "novo0002", "novo0003"]);

export function claimMockLogin(accessCode: string, password: string): MockAccount | undefined {
  if (!MOCK_AVAILABLE_LOGINS.delete(accessCode)) return undefined;
  const account: MockAccount = {
    accessCode,
    password,
    user: { id: `u_${accessCode}`, course: "Análise e Desenvolvimento de Sistemas" },
  };
  MOCK_ACCOUNTS.push(account);
  return account;
}

export function findAccountByAccessCode(accessCode: string): MockAccount | undefined {
  return MOCK_ACCOUNTS.find((account) => account.accessCode === accessCode);
}

export function findAccountById(id: string): MockAccount | undefined {
  return MOCK_ACCOUNTS.find((account) => account.user.id === id);
}

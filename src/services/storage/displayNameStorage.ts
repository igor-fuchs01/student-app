import { displayNameSchema } from "@models/auth";

const DISPLAY_NAME_KEY = "student-app:display-name";

// The student's name never leaves the browser: it is not sent to the API nor stored in the
// database (LGPD), only kept here to greet the student and show them in the ranking.
export const displayNameStorage = {
  get(): string | null {
    const name = displayNameSchema.safeParse(localStorage.getItem(DISPLAY_NAME_KEY));
    return name.success ? name.data : null;
  },

  save(name: string): void {
    localStorage.setItem(DISPLAY_NAME_KEY, name);
  },

  clear(): void {
    localStorage.removeItem(DISPLAY_NAME_KEY);
  },
};

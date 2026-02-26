import { ZodError } from 'zod';

export interface FormattedError {
  error: string;
  code: string;
  details?: Record<string, string[]>;
}

export function formatZodError(error: ZodError): FormattedError {
  const details: Record<string, string[]> = {};

  for (const issue of error.issues) {
    const path = issue.path.join('.') || '_root';
    if (!details[path]) {
      details[path] = [];
    }
    details[path].push(issue.message);
  }

  return {
    error: 'Validation failed',
    code: 'VALIDATION_ERROR',
    details,
  };
}

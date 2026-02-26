import { NextResponse } from 'next/server';

export function success<T>(data: T, status = 200) {
  return NextResponse.json(data, { status });
}

export function created<T>(data: T) {
  return NextResponse.json(data, { status: 201 });
}

export function noContent() {
  return new NextResponse(null, { status: 204 });
}

export function badRequest(message: string, details?: Record<string, string[]>) {
  return NextResponse.json(
    {
      error: message,
      code: 'BAD_REQUEST',
      ...(details && { details }),
    },
    { status: 400 },
  );
}

export function unauthorized(message = 'Unauthorized') {
  return NextResponse.json(
    {
      error: message,
      code: 'UNAUTHORIZED',
    },
    { status: 401 },
  );
}

export function notFound(message = 'Resource not found') {
  return NextResponse.json(
    {
      error: message,
      code: 'NOT_FOUND',
    },
    { status: 404 },
  );
}

export function conflict(message: string) {
  return NextResponse.json(
    {
      error: message,
      code: 'CONFLICT',
    },
    { status: 409 },
  );
}

export function serverError(message = 'Internal server error') {
  return NextResponse.json(
    {
      error: message,
      code: 'INTERNAL_ERROR',
    },
    { status: 500 },
  );
}

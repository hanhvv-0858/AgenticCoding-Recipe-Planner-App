import { NextRequest, NextResponse } from 'next/server';

/**
 * In-memory rate limiter for auth endpoints.
 * 
 * Limits requests per IP address to prevent brute-force attacks.
 * Uses a sliding window approach.
 * 
 * Note: In production, use Redis or a distributed rate limiter.
 */

interface RateLimitEntry {
  count: number;
  resetAt: number;
}

const rateLimitStore = new Map<string, RateLimitEntry>();

// Clean up expired entries every 5 minutes
const CLEANUP_INTERVAL = 5 * 60 * 1000;
let lastCleanup = Date.now();

function cleanup() {
  const now = Date.now();
  if (now - lastCleanup < CLEANUP_INTERVAL) return;

  lastCleanup = now;
  rateLimitStore.forEach((entry, key) => {
    if (now > entry.resetAt) {
      rateLimitStore.delete(key);
    }
  });
}

export interface RateLimitConfig {
  /** Maximum number of requests allowed in the window */
  maxRequests: number;
  /** Time window in seconds */
  windowSeconds: number;
}

const DEFAULT_CONFIG: RateLimitConfig = {
  maxRequests: 10,
  windowSeconds: 60, // 10 requests per minute
};

const AUTH_CONFIG: RateLimitConfig = {
  maxRequests: 5,
  windowSeconds: 60, // 5 auth attempts per minute
};

/**
 * Check rate limit for a request.
 * Returns null if within limit, or a Response if exceeded.
 */
export function checkRateLimit(
  request: NextRequest,
  config: RateLimitConfig = DEFAULT_CONFIG
): NextResponse | null {
  cleanup();

  const ip = getClientIp(request);
  const key = `${ip}:${request.nextUrl.pathname}`;
  const now = Date.now();

  const entry = rateLimitStore.get(key);

  if (!entry || now > entry.resetAt) {
    // New window
    rateLimitStore.set(key, {
      count: 1,
      resetAt: now + config.windowSeconds * 1000,
    });
    return null;
  }

  entry.count++;

  if (entry.count > config.maxRequests) {
    const retryAfter = Math.ceil((entry.resetAt - now) / 1000);
    return NextResponse.json(
      {
        error: 'Too many requests',
        code: 'RATE_LIMIT_EXCEEDED',
        retryAfter,
      },
      {
        status: 429,
        headers: {
          'Retry-After': String(retryAfter),
          'X-RateLimit-Limit': String(config.maxRequests),
          'X-RateLimit-Remaining': '0',
          'X-RateLimit-Reset': String(Math.ceil(entry.resetAt / 1000)),
        },
      }
    );
  }

  return null;
}

/**
 * Rate limiter specifically for auth endpoints.
 * More restrictive: 5 attempts per minute.
 */
export function checkAuthRateLimit(request: NextRequest): NextResponse | null {
  return checkRateLimit(request, AUTH_CONFIG);
}

/**
 * Extract client IP from request headers.
 */
function getClientIp(request: NextRequest): string {
  // Check forwarded headers (behind proxy/load balancer)
  const forwarded = request.headers.get('x-forwarded-for');
  if (forwarded) {
    return forwarded.split(',')[0].trim();
  }

  const realIp = request.headers.get('x-real-ip');
  if (realIp) {
    return realIp;
  }

  // Fallback
  return '127.0.0.1';
}

/**
 * Rate limit headers to add to successful responses.
 */
export function getRateLimitHeaders(
  request: NextRequest,
  config: RateLimitConfig = DEFAULT_CONFIG
): Record<string, string> {
  const ip = getClientIp(request);
  const key = `${ip}:${request.nextUrl.pathname}`;
  const entry = rateLimitStore.get(key);

  const remaining = entry
    ? Math.max(0, config.maxRequests - entry.count)
    : config.maxRequests;

  const reset = entry
    ? Math.ceil(entry.resetAt / 1000)
    : Math.ceil((Date.now() + config.windowSeconds * 1000) / 1000);

  return {
    'X-RateLimit-Limit': String(config.maxRequests),
    'X-RateLimit-Remaining': String(remaining),
    'X-RateLimit-Reset': String(reset),
  };
}

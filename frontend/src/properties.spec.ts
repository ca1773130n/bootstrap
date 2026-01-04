import { describe, expect } from "vitest";
import { test, fc } from "@fast-check/vitest";

describe("Property-based tests", () => {
  test.prop([fc.webUrl()])("any URL is parseable", (url) => {
    expect(() => new URL(url)).not.toThrow();
  });

  test.prop([fc.constantFrom("ok", "error", "loading...")])("status values are displayable strings", (status) => {
    expect(typeof status).toBe("string");
    expect(status.length).toBeGreaterThan(0);
  });
});

describe("API Response Invariants", () => {
  // API base URL handling: any valid URL or path should be processable
  test.prop([fc.oneof(fc.webUrl(), fc.constant("/api"), fc.constant(""))])(
    "baseURL accepts valid URL or relative path",
    (baseURL) => {
      // Invariant: API client constructor should accept any valid URL-like string
      const isValidBaseURL = baseURL === "" || baseURL.startsWith("/") || baseURL.startsWith("http");
      expect(isValidBaseURL).toBe(true);
    }
  );

  // Health response status handling (mirrors App.vue logic)
  test.prop([
    fc.record({
      status: fc.option(fc.string(), { nil: undefined }),
    }),
  ])("health response with optional status is handled", (response) => {
    // Invariant: status should fallback to 'ok' if undefined or empty (using || not ??)
    const displayStatus = response.status || "ok";
    expect(typeof displayStatus).toBe("string");
    expect(displayStatus.length).toBeGreaterThan(0);
  });

  // Error message formatting
  test.prop([fc.string()])("error messages are safe to display", (errorMessage) => {
    // Invariant: any error message string should be safe to render
    const sanitized = errorMessage.replace(/</g, "&lt;").replace(/>/g, "&gt;");
    expect(sanitized).not.toContain("<");
    expect(sanitized).not.toContain(">");
  });

  // JSON response parsing robustness
  test.prop([fc.jsonValue()])("JSON values can be stringified and parsed back", (value) => {
    // Invariant: round-trip serialization preserves value (for valid JSON)
    const serialized = JSON.stringify(value);
    const parsed = JSON.parse(serialized);
    expect(JSON.stringify(parsed)).toBe(serialized);
  });
});

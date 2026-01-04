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

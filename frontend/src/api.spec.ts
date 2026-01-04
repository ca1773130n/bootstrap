import { describe, it, expect } from "vitest";
import { api } from "./api";

describe("api", () => {
  it("has correct default baseURL", () => {
    expect(api.defaults.baseURL).toBe("/api");
  });
});

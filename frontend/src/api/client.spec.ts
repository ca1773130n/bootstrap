import { describe, it, expect, vi, beforeEach } from "vitest";
import axios from "axios";
import { ApiClient, apiClient } from "./client";

vi.mock("axios");

describe("ApiClient", () => {
  const mockAxiosInstance = {
    get: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(axios.create).mockReturnValue(mockAxiosInstance as ReturnType<typeof axios.create>);
  });

  describe("constructor", () => {
    it("creates axios instance with default baseURL", () => {
      new ApiClient();
      expect(axios.create).toHaveBeenCalledWith({ baseURL: "/api" });
    });

    it("creates axios instance with custom baseURL", () => {
      new ApiClient("https://api.example.com");
      expect(axios.create).toHaveBeenCalledWith({ baseURL: "https://api.example.com" });
    });
  });

  describe("health", () => {
    it("calls GET /health and returns data", async () => {
      const client = new ApiClient();
      mockAxiosInstance.get.mockResolvedValue({ data: { status: "ok" } });

      const result = await client.health();

      expect(mockAxiosInstance.get).toHaveBeenCalledWith("/health");
      expect(result).toEqual({ status: "ok" });
    });

    it("propagates errors", async () => {
      const client = new ApiClient();
      mockAxiosInstance.get.mockRejectedValue(new Error("Network error"));

      await expect(client.health()).rejects.toThrow("Network error");
    });
  });

  describe("ping", () => {
    it("calls GET /api/ping and returns data", async () => {
      const client = new ApiClient();
      mockAxiosInstance.get.mockResolvedValue({ data: { message: "pong" } });

      const result = await client.ping();

      expect(mockAxiosInstance.get).toHaveBeenCalledWith("/api/ping");
      expect(result).toEqual({ message: "pong" });
    });
  });

  describe("instance", () => {
    it("exposes underlying axios instance", () => {
      const client = new ApiClient();
      expect(client.instance).toBe(mockAxiosInstance);
    });
  });
});

describe("apiClient default instance", () => {
  it("is an ApiClient instance", () => {
    expect(apiClient).toBeInstanceOf(ApiClient);
  });
});

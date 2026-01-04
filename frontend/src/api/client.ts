/**
 * Type-safe API client using OpenAPI-generated types.
 *
 * Usage:
 *   const response = await apiClient.health();
 *   response.status // typed as string
 */
import axios, { type AxiosInstance, type AxiosResponse } from "axios";
import type { operations } from "./schema";

// Extract response type from operation
type ResponseOf<T> = T extends { responses: { 200: { content: { "application/json": infer R } } } } ? R : never;

// Response types
export type HealthResponse = ResponseOf<operations["health_health_get"]>;
export type PingResponse = ResponseOf<operations["ping_api_ping_get"]>;

// API client class with typed methods
export class ApiClient {
  private readonly axios: AxiosInstance;

  constructor(baseURL: string = "/api") {
    this.axios = axios.create({ baseURL });
  }

  async health(): Promise<HealthResponse> {
    const response: AxiosResponse<HealthResponse> = await this.axios.get("/health");
    return response.data;
  }

  async ping(): Promise<PingResponse> {
    const response: AxiosResponse<PingResponse> = await this.axios.get("/api/ping");
    return response.data;
  }

  // Expose underlying axios for custom requests
  get instance(): AxiosInstance {
    return this.axios;
  }
}

// Default client instance
export const apiClient = new ApiClient(import.meta.env.VITE_API_URL ?? "/api");

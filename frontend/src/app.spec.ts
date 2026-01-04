import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount, flushPromises } from "@vue/test-utils";
import App from "./App.vue";
import { apiClient } from "./api/client";

vi.mock("./api/client", () => ({
  apiClient: {
    health: vi.fn(),
  },
}));

describe("App", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("displays loading state initially", () => {
    vi.mocked(apiClient.health).mockImplementation(() => new Promise(() => {}));
    const wrapper = mount(App);
    expect(wrapper.text()).toContain("loading...");
  });

  it("displays status on successful API call", async () => {
    vi.mocked(apiClient.health).mockResolvedValue({ status: "ok" });
    const wrapper = mount(App);
    await flushPromises();
    expect(wrapper.text()).toContain("ok");
  });

  it("displays 'ok' when status is undefined", async () => {
    vi.mocked(apiClient.health).mockResolvedValue({});
    const wrapper = mount(App);
    await flushPromises();
    expect(wrapper.text()).toContain("ok");
  });

  it("displays 'ok' when status is empty string", async () => {
    vi.mocked(apiClient.health).mockResolvedValue({ status: "" });
    const wrapper = mount(App);
    await flushPromises();
    expect(wrapper.text()).toContain("ok");
  });

  it("displays error on failed API call", async () => {
    vi.mocked(apiClient.health).mockRejectedValue(new Error("Network error"));
    const wrapper = mount(App);
    await flushPromises();
    expect(wrapper.text()).toContain("error");
  });
});

import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount, flushPromises } from "@vue/test-utils";
import App from "./App.vue";
import { api } from "./api";

vi.mock("./api", () => ({
  api: {
    get: vi.fn(),
  },
}));

describe("App", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("displays loading state initially", () => {
    vi.mocked(api.get).mockImplementation(() => new Promise(() => {}));
    const wrapper = mount(App);
    expect(wrapper.text()).toContain("loading...");
  });

  it("displays status on successful API call", async () => {
    vi.mocked(api.get).mockResolvedValue({ data: { status: "ok" } });
    const wrapper = mount(App);
    await flushPromises();
    expect(wrapper.text()).toContain("ok");
  });

  it("displays error on failed API call", async () => {
    vi.mocked(api.get).mockRejectedValue(new Error("Network error"));
    const wrapper = mount(App);
    await flushPromises();
    expect(wrapper.text()).toContain("error");
  });
});

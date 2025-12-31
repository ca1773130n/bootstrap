from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = ""
    debug: bool = False
    cors_origins: str = "http://localhost:5173"

    class Config:
        env_file = ".env"

    def get_cors_origins(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


settings = Settings()

import os
from importlib import reload
from unittest.mock import patch


class TestSettings:
    def test_default_cors_origins(self) -> None:
        with patch.dict(os.environ, {}, clear=True):
            import app.settings as settings_module

            reload(settings_module)
            s = settings_module.Settings()
            assert s.get_cors_origins() == ["http://localhost:5173"]

    def test_cors_origins_single(self) -> None:
        with patch.dict(os.environ, {"CORS_ORIGINS": "http://example.com"}, clear=True):
            import app.settings as settings_module

            reload(settings_module)
            s = settings_module.Settings()
            assert s.get_cors_origins() == ["http://example.com"]

    def test_cors_origins_multiple(self) -> None:
        with patch.dict(
            os.environ, {"CORS_ORIGINS": "http://a.com,http://b.com"}, clear=True
        ):
            import app.settings as settings_module

            reload(settings_module)
            s = settings_module.Settings()
            assert s.get_cors_origins() == ["http://a.com", "http://b.com"]

    def test_cors_origins_with_whitespace(self) -> None:
        with patch.dict(
            os.environ,
            {"CORS_ORIGINS": "  http://a.com  ,  http://b.com  "},
            clear=True,
        ):
            import app.settings as settings_module

            reload(settings_module)
            s = settings_module.Settings()
            assert s.get_cors_origins() == ["http://a.com", "http://b.com"]

    def test_cors_origins_empty_entries_filtered(self) -> None:
        with patch.dict(os.environ, {"CORS_ORIGINS": "http://a.com,,http://b.com"}):
            import app.settings as settings_module

            reload(settings_module)
            s = settings_module.Settings()
            result = s.get_cors_origins()
            assert "http://a.com" in result
            assert "http://b.com" in result
            assert "" not in result

    def test_cors_origins_whitespace_only_filtered(self) -> None:
        with patch.dict(os.environ, {"CORS_ORIGINS": "http://a.com,   ,http://b.com"}):
            import app.settings as settings_module

            reload(settings_module)
            s = settings_module.Settings()
            result = s.get_cors_origins()
            assert len([x for x in result if x.strip()]) == len(result)

    def test_default_database_url(self) -> None:
        with patch.dict(os.environ, {}, clear=True):
            import app.settings as settings_module

            reload(settings_module)
            s = settings_module.Settings()
            assert s.database_url == ""

    def test_default_debug(self) -> None:
        with patch.dict(os.environ, {}, clear=True):
            import app.settings as settings_module

            reload(settings_module)
            s = settings_module.Settings()
            assert s.debug is False

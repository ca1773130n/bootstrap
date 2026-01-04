import os
from importlib import reload
from unittest.mock import patch


def test_database_url_from_settings() -> None:
    with patch.dict(os.environ, {"DATABASE_URL": "postgresql://test:test@localhost/db"}):
        import app.settings as settings_module

        reload(settings_module)

        import app.db as db_module

        reload(db_module)
        assert db_module.DATABASE_URL == "postgresql://test:test@localhost/db"


def test_database_url_default_empty() -> None:
    with patch.dict(os.environ, {}, clear=True):
        import app.settings as settings_module

        reload(settings_module)

        import app.db as db_module

        reload(db_module)
        assert db_module.DATABASE_URL == ""

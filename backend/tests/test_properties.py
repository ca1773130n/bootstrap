import os
from importlib import reload
from unittest.mock import patch

from hypothesis import given, settings
from hypothesis import strategies as st

PRINTABLE_TEXT = st.text(
    alphabet=st.characters(blacklist_categories=["Cs"], blacklist_characters="\x00"),
    min_size=0,
    max_size=50,
)


class TestCorsParsingProperties:
    @given(origins=st.lists(PRINTABLE_TEXT, min_size=0, max_size=10))
    @settings(max_examples=200)
    def test_cors_parsing_never_crashes(self, origins: list[str]) -> None:
        import app.settings as settings_module

        joined = ",".join(origins)
        with patch.dict(os.environ, {"CORS_ORIGINS": joined}):
            reload(settings_module)
            result = settings_module.Settings().get_cors_origins()
            assert isinstance(result, list)
            for item in result:
                assert isinstance(item, str)
                assert len(item.strip()) > 0

    @given(origin=PRINTABLE_TEXT)
    def test_cors_strips_whitespace(self, origin: str) -> None:
        import app.settings as settings_module

        with patch.dict(os.environ, {"CORS_ORIGINS": origin}):
            reload(settings_module)
            result = settings_module.Settings().get_cors_origins()
            for item in result:
                assert item == item.strip()

    @given(
        origins=st.lists(
            PRINTABLE_TEXT.filter(lambda x: "," not in x and x.strip()),
            min_size=1,
            max_size=5,
        )
    )
    def test_cors_preserves_valid_origins(self, origins: list[str]) -> None:
        import app.settings as settings_module

        valid_origins = [o.strip() for o in origins if o.strip()]
        if not valid_origins:
            return

        with patch.dict(os.environ, {"CORS_ORIGINS": ",".join(origins)}):
            reload(settings_module)
            result = settings_module.Settings().get_cors_origins()
            for origin in valid_origins:
                assert origin in result

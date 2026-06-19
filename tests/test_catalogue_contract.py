import json
import unittest
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
CATALOGUE_PATH = ROOT / "data" / "channels.json"


class CatalogueContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.catalogue = json.loads(CATALOGUE_PATH.read_text(encoding="utf-8"))
        cls.channels = cls.catalogue["channels"]

    def test_catalogue_has_expected_top_level_shape(self):
        self.assertEqual(self.catalogue["schema_version"], 1)
        self.assertEqual(self.catalogue["generated_from"], "App/ChannelCatalog.swift")
        self.assertGreaterEqual(len(self.channels), 40)

    def test_hls_and_youtube_endpoints_are_present(self):
        source_types = {channel["source_type"] for channel in self.channels}
        self.assertIn("direct_hls", source_types)
        self.assertIn("youtube", source_types)

        hls_channels = [c for c in self.channels if c["source_type"] == "direct_hls"]
        youtube_channels = [c for c in self.channels if c["source_type"] == "youtube"]

        self.assertGreaterEqual(len(hls_channels), 36)
        self.assertGreaterEqual(len(youtube_channels), 3)
        for channel in hls_channels:
            self.assertTrue(urlparse(channel["playback_url"]).path.endswith(".m3u8"))
        for channel in youtube_channels:
            self.assertIn("youtube", channel["official_url"].lower())

    def test_each_channel_records_permission_status(self):
        for channel in self.channels:
            with self.subTest(channel=channel["id"]):
                self.assertIn("permission", channel)
                self.assertIn("status", channel["permission"])
                self.assertIn("summary", channel["permission"])
                self.assertIn("evidence", channel["permission"])

    def test_epg_sources_are_declared_with_scraper_ids(self):
        epg_sources = [channel for channel in self.channels if channel.get("epg_sources")]

        self.assertGreaterEqual(len(epg_sources), 5)
        for channel in epg_sources:
            for source in channel["epg_sources"]:
                with self.subTest(channel=channel["id"], scraper=source["scraper"]):
                    self.assertIn("url", source)
                    self.assertIn("scraper", source)
                    self.assertIn("method", source)


if __name__ == "__main__":
    unittest.main()

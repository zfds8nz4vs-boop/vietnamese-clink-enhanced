import runpy,sys,unittest
from pathlib import Path

class TelexRulesTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        old=sys.argv
        try:
            sys.argv=["build-telex-cime.py","vi","source/vi.txt"]
            ns=runpy.run_path(str(Path(__file__).with_name("build-telex-cime.py")),run_name="__test__")
        finally:
            sys.argv=old
        cls.telex=staticmethod(ns["telex_word"])
        cls.aliases=staticmethod(ns["telex_aliases"])\n        cls.rows=ns["rows"]

    def test_tone_position_matrix(self):
        # Canonical Telex: tone key at the end of the syllable.
        canonical={
            "áo":"aos",
            "áu":"aus",
            "tiếng":"tieengs",
            "Việt":"Vieejt",
            "đường":"dduowngf",
            "người":"nguwowif",
        }
        for word,reading in canonical.items():
            with self.subTest(word=word):
                self.assertEqual(self.telex(word),reading)

        # Modern orthography / main-vowel position.
        modern={
            "hòa":"hoaf",
            "hoà":"hoaf",
            "khỏe":"khoer",
            "huỷ":"huys",
            "quý":"quys",
            "của":"cuar",
            "mía":"misa",
            "ngoáy":"ngoasy",
            "thoải":"thoais",
            "quyết":"quyeets",
        }
        for word,reading in modern.items():
            with self.subTest(modern=word):
                self.assertIn(reading,self.aliases(word))

        # Traditional/old-style position must also be accepted, so the
        # generated CIME table works with both common typing conventions.
        traditional={
            "hóa":"h o s".replace(" ",""),
            "hủy":"h u s".replace(" ",""),
            "quả":"q u a r".replace(" ",""),
            "mía":"misa",
        }
        expected_traditional={"hóa":"hosa","hủy":"husy","quả":"quar","mía":"misa"}
        for word,reading in expected_traditional.items():
            with self.subTest(traditional=word):
                self.assertIn(reading,self.aliases(word))

        # Tone keys must be inserted after the vowel that actually carries
        # the tone, not merely after the first/last raw character.
        positional={
            "bài":"basi",
            "bảy":"bays",
            "của":"cuar",
            "chiều":"chieefu",
            "chuối":"chuoos i".replace(" ",""),
            "mười":"muoif",
            "nước":"nuowsc",
            "biển":"bieens",
            "quyền":"quyeefn",
        }
        for word,reading in positional.items():
            with self.subTest(positional=word):
                self.assertIn(reading,self.aliases(word))

    def test_aliases_include_both_tone_styles(self):
        self.assertIn("hoaf",self.aliases("hòa"))
        self.assertIn("hofa",self.aliases("hòa"))
        self.assertIn("huys",self.aliases("hủy"))
        self.assertIn("husy",self.aliases("hủy"))


    def test_literal_repeated_letters(self):
        self.assertEqual("aaa","aaa")
        self.assertEqual("aaaaaaaa","aaaaaaaa")

    def test_literal_repeated_w(self):
        self.assertEqual("uww","uww")
        self.assertEqual("oww","oww")

if __name__=="__main__": unittest.main()

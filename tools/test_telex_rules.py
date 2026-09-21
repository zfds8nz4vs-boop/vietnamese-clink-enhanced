import runpy,sys,unittest
from pathlib import Path

class TelexRulesTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        old=sys.argv
        try:
            sys.argv=["build-telex-cime.py","vi","source/vi.txt"]
            ns=runpy.run_path(
                str(Path(__file__).with_name("build-telex-cime.py")),
                run_name="__test__",
            )
        finally:
            sys.argv=old
        cls.telex=staticmethod(ns["telex_word"])
        cls.aliases=staticmethod(ns["telex_aliases"])
        cls.rows=ns["rows"]

    def test_tone_position_matrix(self):
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

        traditional={
            "hóa":"hosa",
            "hủy":"husy",
            "quả":"quar",
            "mía":"misa",
        }
        for word,reading in traditional.items():
            with self.subTest(traditional=word):
                self.assertIn(reading,self.aliases(word))

        positional={
            "bài":"basi",
            "bảy":"bays",
            "của":"cuar",
            "chiều":"chieefu",
            "chuối":"chuoosi",
            "mười":"muowfi",
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
        for reading in ("aaa","aaaa","aaaaaaaa","eeee","oooooooo"):
            with self.subTest(reading=reading):
                self.assertIn(reading,self.rows[reading])

    def test_literal_repeated_w(self):
        self.assertIn("ưw",self.rows["uww"])
        self.assertIn("ơw",self.rows["oww"])
        self.assertIn("ăw",self.rows["aww"])

    def test_repeated_tone_keys_are_literal(self):
        for reading in ("ss","ff","rr","xx","jj","zz"):
            with self.subTest(reading=reading):
                self.assertIn(reading,self.rows[reading])

if __name__=="__main__":
    unittest.main()

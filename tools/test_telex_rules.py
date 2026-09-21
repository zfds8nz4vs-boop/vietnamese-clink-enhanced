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
        cls.telex=ns["telex_word"]
        cls.aliases=ns["telex_aliases"]

    def test_canonical_tone_at_end(self):
        self.assertEqual(self.telex("áo"),"aos")
        self.assertEqual(self.telex("áu"),"aus")
        self.assertEqual(self.telex("tiếng"),"tieengs")
        self.assertEqual(self.telex("Việt"),"Vieejt")
        self.assertEqual(self.telex("đường"),"dduowngf")

    def test_alternate_tone_position_is_accepted(self):
        self.assertIn("aos",self.aliases("áo"))
        self.assertIn("aus",self.aliases("áu"))
        self.assertIn("dduowngf",self.aliases("đường"))

    def test_literal_repeated_letters(self):
        self.assertEqual("aaa","aaa")
        self.assertEqual("aaaaaaaa","aaaaaaaa")

    def test_literal_repeated_w(self):
        self.assertEqual("uww","uww")
        self.assertEqual("oww","oww")

if __name__=="__main__": unittest.main()

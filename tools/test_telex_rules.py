import unittest,runpy,sys
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
    def test_rules(self):
        self.assertEqual(self.telex("tiếng"),"tieengs")
        self.assertEqual(self.telex("Việt"),"Vieejt")
        self.assertEqual(self.telex("đường"),"dduowngf")
        self.assertEqual(self.telex("TÔI"),"TOOIS")
if __name__=="__main__": unittest.main()

import fitz  # PyMuPDF
import re
from typing import Dict, List, Optional
import json

class CurriculumPDFParser:
    def __init__(self, pdf_stream: bytes):
        self.doc = fitz.open(stream=pdf_stream, filetype="pdf")
        self.text_content = ""
        self.structure = {
            "competences": [],
            "resources": [],
            "activities": [] # SAE
        }

    def extract_text(self):
        """Extracts text preserving some layout logic if needed"""
        full_text = []
        for page in self.doc:
            full_text.append(page.get_text("text"))
        self.text_content = "\n".join(full_text)
        return self.text_content

    def parse(self) -> Dict:
        """
        Main parsing logic.
        This is a heuristic parser based on the standard BUT PN layouts.
        """
        self.extract_text()

        # 1. Extract Competencies & Levels (Niveaux)
        # Patterns often used: "Compétence X", "Niveau X"
        self._parse_competencies()

        # 2. Extract Resources (R1.01, etc.)
        self._parse_resources()

        # 3. Extract Activities (SAE)
        self._parse_activities()

        return self.structure

    def _parse_competencies(self):
        # Regex for Competence title, e.g., "Compétence 1 : Gérer ..."
        # Note: This depends heavily on the specific formatting of the PDF.
        # We look for "COMPÉTENCE" followed by a number or text.

        # Heuristic: Split by "COMPÉTENCE" or "Compétence"
        # This is tricky because it might appear multiple times.

        # Let's try to find blocks starting with Codes like "AC1.01" to identify structure.

        # Finding ACs
        ac_pattern = re.compile(r"(AC\s?\d{1,2}\.\d{2}[\s\S]*?)(?=(AC\s?\d{1,2}\.\d{2}|SAÉ|R\d|COMPÉTENCE|$))")
        matches = ac_pattern.findall(self.text_content)

        # This is too raw. Let's try line-by-line analysis with state machine.
        pass

    def _parse_resources(self):
        # Look for R1.01, R2.15 etc.
        res_pattern = re.compile(r"(R\s?(\d)\.(\d{2}))\s+[–-]\s+(.+)")
        seen_codes = set()

        for line in self.text_content.split('\n'):
            line = line.strip()
            match = res_pattern.match(line)
            if match:
                code_full = match.group(1).replace(" ", "")
                level = match.group(2)
                label = match.group(4)

                if code_full not in seen_codes:
                    self.structure["resources"].append({
                        "code": code_full,
                        "label": label,
                        "level": int(level)
                    })
                    seen_codes.add(code_full)

    def _parse_activities(self):
        # Look for SAÉ 1.01, SAE2.03 etc.
        sae_pattern = re.compile(r"(SA[EÉ]\s?(\d)\.(\d{2}))\s+[–-]\s+(.+)")
        seen_codes = set()

        for line in self.text_content.split('\n'):
            line = line.strip()
            match = sae_pattern.match(line)
            if match:
                code_full = match.group(1).replace(" ", "").replace("É", "E")
                level = match.group(2)
                label = match.group(4)

                if code_full not in seen_codes:
                    self.structure["activities"].append({
                        "code": code_full,
                        "label": label,
                        "level": int(level),
                        "type": "SAE"
                    })
                    seen_codes.add(code_full)

    def compare_with_db(self, db_competencies, db_resources, db_activities) -> Dict:
        """
        Compares extracted structure with DB lists.
        Input lists should be dicts or objects with 'code' and 'label'.
        """
        report = {
            "resources": {"missing_in_db": [], "missing_in_pdf": [], "matches": []},
            "activities": {"missing_in_db": [], "missing_in_pdf": [], "matches": []}
        }

        # Compare Resources
        pdf_res_codes = {r["code"]: r for r in self.structure["resources"]}
        db_res_codes = {r.code: r for r in db_resources}

        for code, data in pdf_res_codes.items():
            if code not in db_res_codes:
                report["resources"]["missing_in_db"].append(data)
            else:
                report["resources"]["matches"].append({
                    "code": code,
                    "pdf_label": data["label"],
                    "db_label": db_res_codes[code].label
                })

        for code, data in db_res_codes.items():
            if code not in pdf_res_codes:
                # Ignore custom resources?
                report["resources"]["missing_in_pdf"].append({"code": code, "label": data.label})

        # Compare Activities
        pdf_act_codes = {a["code"]: a for a in self.structure["activities"]}
        db_act_codes = {a.code: a for a in db_activities}

        for code, data in pdf_act_codes.items():
            if code not in db_act_codes:
                report["activities"]["missing_in_db"].append(data)
            else:
                report["activities"]["matches"].append({
                    "code": code,
                    "pdf_label": data["label"],
                    "db_label": db_act_codes[code].label
                })

        return report

#!/usr/bin/env python3

import argparse
import pathlib
import re
import sqlite3
from bs4 import BeautifulSoup


def generate_index(res_dir: pathlib.Path, doc_dir: pathlib.Path):
    conn = sqlite3.connect(res_dir / "docSet.dsidx")
    cur = conn.cursor()

    cur.execute("DROP TABLE IF EXISTS searchIndex;")

    cur.execute(
        "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, "
        "type TEXT, path TEXT);"
    )
    cur.execute("CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);")

    page = doc_dir.joinpath("index.html").read_text()
    soup = BeautifulSoup(page, "lxml")

    intrinsic = soup.find("a", {"id": re.compile(r"^toc[_\-]Intrinsic-Procedures")})
    intrin_procedures = intrinsic.parent.select("li > a")

    for tag in intrin_procedures:
        if tag.code:
            name = tag.code.text.strip()
            path = tag.attrs["href"].strip()
            cur.execute(
                "INSERT OR IGNORE INTO searchIndex(name, type, path)" " VALUES (?,?,?)",
                (name, "func", path),
            )
            print(f"Adding to index: {name} -> {path}")

    conn.commit()
    conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("res_dir", type=pathlib.Path)
    parser.add_argument("doc_dir", type=pathlib.Path)
    args = parser.parse_args()
    generate_index(args.res_dir, args.doc_dir)

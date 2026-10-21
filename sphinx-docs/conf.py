from pathlib import Path
import sys

DOCS = Path(__file__).resolve().parent

def find_package_root(start: Path) -> Path:
    for candidate in (start, *start.parents):
        if (candidate / 'DESCRIPTION').exists():
            return candidate
    raise RuntimeError(f'No R package DESCRIPTION found above {start}')

ROOT = find_package_root(DOCS)
sys.path.insert(0, str(DOCS / '_ext'))

def read_description(path: Path) -> dict[str, str]:
    fields: dict[str, str] = {}
    current = None
    for raw in path.read_text(encoding='utf-8').splitlines():
        if raw[:1].isspace() and current:
            fields[current] += ' ' + raw.strip()
        elif ':' in raw:
            current, value = raw.split(':', 1)
            fields[current] = value.strip()
    return fields

description = read_description(ROOT / 'DESCRIPTION')
project = description.get('Package', ROOT.name)
author = description.get('Authors@R', '')
release = description.get('Version', '')

extensions = ['rd2sphinx_domain']
source_suffix = {'.rst': 'restructuredtext'}
root_doc = 'index'
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']
nitpicky = True

html_theme = 'furo'
html_static_path = ['_static']
html_css_files = ['custom.css']
html_title = f'{project} {release}' if release else project

# No source_repository/source_branch/source_directory, which is what Furo
# turns into its view-source and edit-this-page buttons. The reference
# pages under reference/ are generated from the package's Rd topics on
# every build and are not in version control, so those buttons would point
# at files that do not exist. The source that matters is the roxygen
# comment in R/, and Furo builds one link per page from a single template
# with no way to reach it.
html_theme_options = {}


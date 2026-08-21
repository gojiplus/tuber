from pathlib import Path
import os
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

def detect_source_branch(root: Path) -> str:
    head = root / '.git' / 'HEAD'
    if head.exists():
        value = head.read_text(encoding='utf-8').strip()
        prefix = 'ref: refs/heads/'
        if value.startswith(prefix):
            return value[len(prefix):]
    github_ref = os.environ.get('GITHUB_HEAD_REF') or os.environ.get('GITHUB_REF_NAME')
    if github_ref and github_ref not in {'merge', 'HEAD'}:
        return github_ref
    return 'main'

description = read_description(ROOT / 'DESCRIPTION')
project = description.get('Package', ROOT.name)
author = description.get('Authors@R', '')
release = description.get('Version', '')
urls = [item.strip() for item in description.get('URL', '').split(',') if item.strip()]
source_repository = next((item for item in urls if 'github.com/' in item), '')
if source_repository and not source_repository.endswith('/'):
    source_repository += '/'
source_branch = 'master' or detect_source_branch(ROOT)

extensions = ['rd2sphinx_domain']
source_suffix = {'.rst': 'restructuredtext'}
root_doc = 'index'
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']
nitpicky = True

html_theme = 'furo'
html_static_path = ['_static']
html_css_files = ['custom.css']
html_title = f'{project} {release}' if release else project
html_theme_options = {}
if source_repository:
    html_theme_options.update({
        'source_repository': source_repository,
        'source_branch': source_branch,
        'source_directory': 'sphinx-docs/',
    })


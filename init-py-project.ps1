$project_name=$args[0]

if ( $project_name -eq "") {
    $project_name = "New Project"
}

poetry new $project_name;
Set-Location ./$project_name
pyenv local 3.9.6
poetry env use python
poetry add --dev pytest-cov pre-commit flake8 mypy isort
poetry add --dev --allow-prereleases black
poetry shell
code .

New-Item pyproject.toml
Set-Content pyproject.toml "
[tool.black]
line-length = 79
target-version = ['py39']
include = '\.pyi?$'
exclude = '''

(
  /(
      \.eggs         # exclude a few common directories in the
    | \.git          # root of the project
    | \.hg
    | \.mypy_cache
    | \.tox
    | \.venv
    | _build
    | buck-out
    | build
    | dist
  )/
  | foo.py           # also separately exclude a file named foo.py in
                     # the root of the project
)
'''


[tool.isort]
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
line_length = 79
"

New-Item setup.cfg
Set-Content setup.cfg "
create setup.cfg

[flake8]
extend-ignore = E203

[mypy]
follow_imports = silent
strict_optional = True
warn_redundant_casts = True
warn_unused_ignores = True
disallow_any_generics = True
check_untyped_defs = True
no_implicit_reexport = True
disallow_untyped_defs = True
ignore_missing_imports = True

[mypy-tests.*]
ignore_errors = True
"

New-Item .pre-commit-config.yaml
Set-Content .pre-commit-config.yaml "
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.1.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-added-large-files
-   repo: https://gitlab.com/pycqa/flake8
    rev: 4.0.1
    hooks:
    -   id: flake8
-   repo: https://github.com/psf/black
    rev: 22.1.0
    hooks:
      - id: black
-   repo: https://github.com/pre-commit/mirrors-mypy
    rev: v0.941
    hooks:
        - id: mypy
-   repo: https://github.com/PyCQA/isort
    rev: 5.10.1
    hooks:
    -   id: isort
"

Write-Output '.coverage' > .gitignore
Write-Output '.vscode/' >> .gitignore
curl -s https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore >> .gitignore
git init -b main
git add .
git commit -m 'Initial commit'
pre-commit install
pre-commit autoupdate
pre-commit autoupdate
pre-commit run --all-files

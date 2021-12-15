---
title:	amsthm—just a naive cookiecutter to boostrap Python project
...

``` {.table}
---
header: false
markdown: true
include: badges.csv
...
```

# Introduction

amsthm is just a naive cookiecutter to boostrap Python project.

# Instruction

```bash
NEW_NAME=amsthm
NEW_VERSION=1.2.3
NEW_YEAR=2016-2016-2021
NEW_NAME_UPPER="$(echo $NEW_NAME | tr '[:lower:]' '[:upper:]')"
find . \! -path '*/.git/*' -type f -exec sed -i "s/amsthm/$NEW_NAME/g" {} +
find . \! -path '*/.git/*' -type f -exec sed -i "s/AMSTHM/$NEW_NAME_UPPER/g" {} +
find . \! -path '*/.git/*' -type f -exec sed -i "s/1.2.3/$NEW_VERSION/g" {} +
find . \! -path '*/.git/*' -type f -exec sed -i "s/2016-2021/$NEW_YEAR/g" {} +
mv src/amsthm "src/$NEW_NAME"
```

- update title in
    - `docs/README.md`
    - `pyproject.toml`

Optionally also sed

- GitHub username `ickc`
- author name `Kolen Cheung`
- author email `christian.kolen@gmail.com`

# Copy

```bash
rsync -av --stats --exclude .git ./ $TARGET_GIT_REPO_DIRECTORY
```

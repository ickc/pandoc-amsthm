# Revision history for `amsthm`

-   v3.0.0 (unreleased): rewritten as a native Pandoc Lua filter
    (single file: `amsthm.lua`). Drops the Python / `panflute` /
    Poetry dependency stack. **Breaking change**: invocation changes
    from `pandoc -F amsthm` to `pandoc -L amsthm.lua`. Minimum Pandoc
    bumped to 2.17 (for `elem:walk` and topdown traversal). Dev
    environment moved to [pixi](https://pixi.sh). Input syntax (the
    YAML `amsthm:` block and `:::`-Divs) is unchanged.
-   v2.0.0: Python / panflute implementation.
-   v1.2.3: first release and proof of concept.

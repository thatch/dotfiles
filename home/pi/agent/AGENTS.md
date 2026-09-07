# User Instructions

- When looking up documentation for a PyPI package, check the PyPI JSON API first for README/project description contents before falling back to installed source inspection. Example: `python - <<'PY'
import json, urllib.request
name = "PACKAGE_NAME"
data = json.load(urllib.request.urlopen(f"https://pypi.org/pypi/{name}/json"))
print(data["info"].get("description") or "")
PY`
- If an ST-LINK device is found using the old pre-SWD protocol, prefer firmware-updating the ST-LINK rather than working around it with OpenOCD shenanigans.

"""Run `tofu validate` on one org unit the way Terragrunt would lay it out, without Terragrunt.

Terragrunt can't run in CI here: its `inputs` decrypt age secrets at parse time. Validation only
needs the generated `versions.tf`/`provider.tf` (static heredocs; an org's block overrides the
root's) plus `locals.tf.json` from terranix, so this writes those next to a copy of the unit and
runs init against the committed lock file.

usage: validate-org.py <repo-root> <org> <locals.tf.json> <workdir>
"""
import re
import shutil
import subprocess
import sys
import textwrap
from pathlib import Path


def heredoc(hcl: str, block: str):
    m = re.search(r'generate "%s" \{.*?contents\s*=\s*<<-EOF\n(.*?)\n\s*EOF' % re.escape(block), hcl, re.S)
    return textwrap.dedent(m.group(1)) + "\n" if m else None


def main(root, org, locals_json, work):
    root, work = Path(root), Path(work)
    shutil.copytree(root / "modules", work / "modules")
    unit = work / "orgs" / org
    shutil.copytree(root / "orgs" / org, unit)
    shutil.copy(locals_json, unit / "locals.tf.json")

    org_hcl = (unit / "terragrunt.hcl").read_text()
    root_hcl = (root / "root.hcl").read_text()
    for block in ("versions", "provider"):
        text = heredoc(org_hcl, block) or heredoc(root_hcl, block)
        if text is None:
            sys.exit(f"{org}: no generate \"{block}\" block in terragrunt.hcl or root.hcl")
        if "${" in text and "${var." not in text:
            sys.exit(f"{org}: generate \"{block}\" interpolates Terragrunt values; extend this script")
        (unit / f"{block}.tf").write_text(text)

    for args in (["init", "-backend=false", "-input=false", "-lockfile=readonly"], ["validate"]):
        result = subprocess.run(["tofu", f"-chdir={unit}", *args, "-no-color"])
        if result.returncode:
            sys.exit(f"{org}: tofu {args[0]} failed")
    print(f"{org}: valid")


if __name__ == "__main__":
    main(*sys.argv[1:])

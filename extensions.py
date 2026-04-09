import re
import subprocess
import unicodedata

from copier_templates_extensions import ContextHook
from jinja2 import Environment
from jinja2.ext import Extension


def _to_package_name(value: str) -> str:
    """Sanitize an arbitrary string into a valid Python package name."""
    s = unicodedata.normalize("NFD", value.lower())
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    s = re.sub(r"[^a-z0-9]+", "_", s)
    s = s.strip("_")
    if s and s[0].isdigit():
        s = "_" + s
    return s or "package"


class PackageNameFilter(Extension):
    """Jinja2 extension that exposes the ``to_package_name`` filter."""

    def __init__(self, environment: Environment) -> None:
        super().__init__(environment)
        environment.filters["to_package_name"] = _to_package_name


class GitContext(ContextHook):
    def hook(self, context):
        try:
            name = subprocess.check_output(
                ["git", "config", "--get", "user.name"], text=True
            ).strip()
        except subprocess.CalledProcessError:
            name = ""
        try:
            email = subprocess.check_output(
                ["git", "config", "--get", "user.email"], text=True
            ).strip()
        except subprocess.CalledProcessError:
            email = ""
        return {"git_user_name": name, "git_user_email": email}

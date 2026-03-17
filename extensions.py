import subprocess

from copier_templates_extensions import ContextHook


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

import json
import time
from datetime import datetime

from ansible.plugins.callback import CallbackBase


class CallbackModule(CallbackBase):
    """
    Environment-aware Custom Ansible audit logger callback plugin.
    - Uses the Ansible inventory variable `env` to determine the environment dynamically.
    - DEV/DEFAULT Environment: Writes human-readable plaintext logs to logs/ansible_dev.log
    - PROD Environment: Writes strictly formatted JSON lines to logs/ansible_audit.log
    """

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = "notification"
    CALLBACK_NAME = "custom_audit_logger"

    def __init__(self):
        super(CallbackModule, self).__init__()
        self.dev_log_file = "logs/ansible_dev.log"
        self.prod_log_file = "logs/ansible_audit.log"
        self.task_start_times = {}
        self.play = None
        self.vm = None

    def v2_playbook_on_play_start(self, play):
        self.play = play
        self.vm = play.get_variable_manager()

    def _get_host_env(self, host, task):
        # Attempt to dynamically resolve the 'env' variable from group_vars/host_vars
        if self.vm and self.play:
            try:
                variables = self.vm.get_vars(play=self.play, host=host, task=task)
                return variables.get("env", "dev").lower()
            except Exception:
                pass
        return "dev"

    def _log_event(self, task_name, host_obj, status, duration=0, msg="", task_obj=None):
        time_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        host_name = host_obj.get_name() if host_obj else "unknown"

        # Dynamically determine the environment per host!
        env = self._get_host_env(host_obj, task_obj)

        if env == "prod":
            # PROD: Strict JSON Line format suitable for Fluentd/ELK/Datadog
            log_entry = {
                "timestamp": datetime.now().isoformat(),
                "environment": env,
                "host": host_name,
                "task": task_name,
                "status": status,
                "duration_seconds": round(duration, 3),
                "message": msg,
            }
            with open(self.prod_log_file, "a") as f:
                f.write(json.dumps(log_entry) + "\n")
        else:
            # DEV / DEFAULT: Human-readable plaintext format
            msg_part = f" | {msg}" if msg else ""
            log_line = (
                f"[{time_str}] [{host_name}] [ENV:{env.upper()}] "
                f"[{status}] ({round(duration, 3)}s) - {task_name}{msg_part}\n"
            )

            with open(self.dev_log_file, "a") as f:
                f.write(log_line)

    def v2_playbook_on_task_start(self, task, is_conditional):
        self.task_start_times[task._uuid] = time.time()

    def v2_runner_on_ok(self, result):
        task_uuid = result._task._uuid
        start_time = self.task_start_times.get(task_uuid, time.time())
        duration = time.time() - start_time

        status = "CHANGED" if result._result.get("changed", False) else "OK"

        self._log_event(
            task_name=result._task.get_name(),
            host_obj=result._host,
            status=status,
            duration=duration,
            task_obj=result._task,
        )

    def v2_runner_on_failed(self, result, ignore_errors=False):
        task_uuid = result._task._uuid
        start_time = self.task_start_times.get(task_uuid, time.time())
        duration = time.time() - start_time

        error_msg = result._result.get("msg", "Unknown Error")
        status = "IGNORED" if ignore_errors else "FAILED"

        self._log_event(
            task_name=result._task.get_name(),
            host_obj=result._host,
            status=status,
            duration=duration,
            msg=error_msg,
            task_obj=result._task,
        )

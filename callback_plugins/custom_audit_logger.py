import json
import time
from datetime import datetime
from ansible.plugins.callback import CallbackBase

class CallbackModule(CallbackBase):
    """
    Custom Ansible audit logger callback plugin.
    Silently records the duration and result of each task into a unified log file.
    """

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'custom_audit_logger'

    def __init__(self):
        super(CallbackModule, self).__init__()
        self.log_file = "logs/ansible_audit.log"
        self.task_start_times = {}

    def _log_event(self, task_name, host, status, duration=0, msg=""):
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "host": host,
            "task": task_name,
            "status": status,
            "duration_seconds": round(duration, 3),
            "message": msg
        }
        with open(self.log_file, "a") as f:
            f.write(json.dumps(log_entry) + "\n")

    def v2_playbook_on_task_start(self, task, is_conditional):
        self.task_start_times[task._uuid] = time.time()

    def v2_runner_on_ok(self, result):
        task_uuid = result._task._uuid
        start_time = self.task_start_times.get(task_uuid, time.time())
        duration = time.time() - start_time

        status = "CHANGED" if result._result.get('changed', False) else "OK"

        self._log_event(
            task_name=result._task.get_name(),
            host=result._host.get_name(),
            status=status,
            duration=duration
        )

    def v2_runner_on_failed(self, result, ignore_errors=False):
        task_uuid = result._task._uuid
        start_time = self.task_start_times.get(task_uuid, time.time())
        duration = time.time() - start_time

        error_msg = result._result.get('msg', 'Unknown Error')
        status = "IGNORED" if ignore_errors else "FAILED"

        self._log_event(
            task_name=result._task.get_name(),
            host=result._host.get_name(),
            status=status,
            duration=duration,
            msg=error_msg
        )

#!/usr/bin/env bash
set -ex

PID=`pgrep $EXECUTABLE`

# HACK: make sure the debugger runs with the same UID and GID of the target executable
#
# Delve uses ptrace(PTRACE_SEIZE) to attach, which results in an EPERM otherwise
# Full details of the algorithm are described under PTRACE_MODE_ATTACH_REALCREDS in man 2 ptrace:
# https://man7.org/linux/man-pages/man2/ptrace.2.html (point 3. in particular)
#
# HACK can be removed when kubectl debug will the SYS_PTRACE capability
# Currently being implemented per:
# https://github.com/kubernetes/enhancements/blob/cfbe9a3471db50ae4c6ec89a9ddfc8801cc6976d/keps/sig-cli/1441-kubectl-debug/README.md#debugging-profiles
USER_ID=`stat -c "%u" /proc/${PID}`
GROUP_ID=`stat -c "%g" /proc/${PID}`
if (( ${USER_ID} != 0 )); then
    useradd -u ${USER_ID} debugger
fi

if (( ${GROUP_ID} != 0 )); then
    groupadd -g ${GROUP_ID} debugger
fi

echo 'root    ALL=(ALL:ALL) ALL' >> /etc/sudoers

exec sudo -u#${USER_ID} -g#${GROUP_ID} dlv attach ${PID} --continue --accept-multiclient --api-version 2 --headless --log --listen :4000

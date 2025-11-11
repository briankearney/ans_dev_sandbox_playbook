FROM fedora:latest

# Install OpenSSH server and necessary utilities
RUN dnf update -y && \
 dnf install -y git openssh-server openssh-clients python3 && \
 dnf clean all && \
 ssh-keygen -A

# Expose the SSH port
EXPOSE 22

# Command to start SSH server when the container runs
CMD ["/usr/sbin/sshd", "-dD"]

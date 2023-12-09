FROM archlinux:base

COPY entrypoint.sh /entrypoint.sh

# Fix script permissions
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
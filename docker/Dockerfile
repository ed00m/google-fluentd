FROM debian:stretch-20180426

# TODO: This may be a moving target, figure out how to pin.
RUN apt-get update \
    && apt-get install -y \
        curl \
        gnupg2 \
        lsb-release \
        build-essential \
        procps \
        systemd \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get autoremove

# Install google-fluentd at version 1.5.35-1.
RUN curl -sS https://dl.google.com/cloudagents/install-logging-agent.sh | REPO_SUFFIX=20180810-1 DO_NOT_INSTALL_CATCH_ALL_CONFIG=true bash \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get autoremove \
    && find /var/log -name "*.log" -type f -delete

ENV LD_PRELOAD=/opt/google-fluentd/embedded/lib/libjemalloc.so

ADD entrypoint.sh /entrypoint.sh
COPY fluent-plugin-buffer-output-stub-0.0.1.gem /fluent-plugin-buffer-output-stub-0.0.1.gem

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/google-fluentd"]

RUN /opt/google-fluentd/embedded/bin/gem uninstall fluent-plugin-google-cloud -ax --force && \
    /opt/google-fluentd/embedded/bin/gem install /fluent-plugin-buffer-output-stub-0.0.1.gem

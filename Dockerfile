# base image
ARG VCS_REF
ARG BUILD_DATE
ARG ARCH=amd64
FROM archlinux:latest

# environment
ENV CUPS_USER_ADMIN="admin"
ENV CUPS_USER_PASSWORD="admin"
ENV DEBIAN_FRONTEND="noninteractive"
ENV PREFIX="/usr/local/bin"
ENV LANG="en_US.UTF-8"
ENV PRINTER_DRIVERS=""
# printer drivers (seperate by "," e.g. foomatic-db,footmatic-db-engine,footmatic-db-nonfree):
# foomatic-db foomatic-db-engine foomatic-db-gutenprint-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds foomatic-db-ppds gutenprint hplip splix

# labels
LABEL maintainer="realizelol" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="realizelol/cups-oki" \
  org.label-schema.description="CUPS docker with printer drivers" \
  org.label-schema.version="2.4.2" \
  org.label-schema.url="https://hub.docker.com/r/realizelol/cups-oki" \
  org.label-schema.vcs-url="https://github.com/realizelol/docker-cups-oki" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.build-date="${BUILD_DATE}"

# Prepare ENV
RUN locale-gen && \
    pacman-key --init && \
    pacman-key --populate archlinux

# Install cups
RUN pacman --noconfirm --needed -Sy \
 && pacman --noconfirm --needed -S cups libcups cups-filters cups-pdf ghostscript gsfonts samba expect sudo wget \
    $(for PDRV in $(echo "${PRINTER_DRIVERS}" | sed 's/,/ /g'); do echo "${PDRV}"; done) \
 && pacman --noconfirm -Sc \
 && rm /var/lib/pacman/sync/*

# Add OKI PostScript printer queue
ADD drivers/okijobaccounting /usr/lib/cups/filter/okijobaccounting
RUN chmod 755 /usr/lib/cups/filter/okijobaccounting

# Add OKI printer drivers "OKI MC361 / MC561 / CX2731"
ADD drivers/ok361u1.ppd /usr/share/ppd/ok361u1.ppd
RUN chmod 644 /usr/share/ppd/ok361u1.ppd

# copy scripts
COPY docker-entrypoint.sh "${PREFIX}/docker-entrypoint.sh"
COPY docker-healthcheck.sh "${PREFIX}/docker-healthcheck.sh"
RUN  chmod +x "${PREFIX}"/docker-*.sh

# copy /etc/cups for skeleton usage
RUN cp -rp /etc/cups /etc/cups-skel
RUN mkdir -p /etc/cups/ssl

# create user
RUN useradd "${CUPS_USER_ADMIN}" --system -G wheel --no-create-home --password $(openssl passwd -1 "${CUPS_USER_PASSWORD}")
RUN groupadd lpadmin && usermod -aG lpadmin "${CUPS_USER_ADMIN}" && usermod -aG lp "${CUPS_USER_ADMIN}"
RUN sed -i '/%wheel[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers
RUN sed -i '/%wheel.*/s/^# *//' /etc/sudoers
ADD etc-pam.d-cups /etc/pam.d/cups

# volumes
VOLUME ["/etc/cups"]

# ports
EXPOSE 631/tcp 631/udp

# healthcheck every 60mins (default=30s)
HEALTHCHECK --interval=60m --timeout=10s --start-period=30s --retries=1 CMD "${PREFIX}/docker-healthcheck.sh"

# entrypoint
ENTRYPOINT "${PREFIX}/docker-entrypoint.sh" /usr/sbin/cupsd -f

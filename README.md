# CUPS Docker Image

- BASE: archlinux

## Architectures

- amd64

## Usage

### Start the container

```bash
docker run -d --restart always -p 631:631 -v /mnt/user/appdata/cups-oki:/etc/cups:rw -v /var/run/dbus:/var/run/dbus:ro --device /dev/bus realizelol/cups-oki:latest
```

### Configuration

Login in to CUPS web interface on port 631 (e.g. https://localhost:631) and configure CUPS to your needs.
Default credentials: admin / admin

To change the admin username change __CUPS_USER_ADMIN__ to set the password change __CUPS_USER_PASSWORD__:

```bash
docker run -d --restart always -p 631:631 -v /mnt/user/appdata/cups-oki:/etc/cups:rw -v /var/run/dbus:/var/run/dbus:ro --device /dev/bus -e CUPS_USER_ADMIN=admin -e CUPS_USER_PASSWORD=mySecretPassword realizelol/cups-oki:latest
```

### Creditz and thank you to ydkn
https://github.com/ydkn


#### Picture print.png by flaticon.com
https://www.flaticon.com/free-icon/print_4305624

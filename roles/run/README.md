# Ansible role: `foundata.nginx.run`

The `foundata.nginx.run` Ansible role (part of the `foundata.nginx` Ansible collection). It provides automated installation, configuration management, and hardening of [NGINX](https://nginx.org/) across major Linux distributions.



## Table of contents<a id="toc"></a>

- [Features](#features)
- [Example playbooks, using this role](#examples)
- [Supported tags](#tags)<!-- ANSIBLE DOCSMITH TOC START -->
- [Role variables](#variables)
<!-- ANSIBLE DOCSMITH TOC END -->
- [Dependencies](#dependencies)
- [Compatibility](#compatibility)
- [External requirements](#requirements)



## Features<a id="features"></a>

Main features:

* Site management via `sites-available/` and `sites-enabled/` with optional cleanup of unmanaged files.
* Dynamic module management: enable modules by name, the role installs packages and creates `load_module` configs automatically with cross-platform support.
* Layered configuration merge: production-ready internal defaults and user settings are combined automatically. User-provided values always take highest priority.
* Hardened TLS baseline following the [Mozilla "Intermediate" TLS profile (Guideline v6.0)](https://ssl-config.mozilla.org/#server=nginx&config=intermediate&hsts=1&ocsp=1&guideline=6.0):
  * Post-quantum key exchange (`X25519MLKEM768`) on platforms with OpenSSL >= 3.5, automatic fallback to classical curves on older platforms.
  * Ships [RFC 7919](https://www.rfc-editor.org/rfc/rfc7919) ffdhe3072 DH parameters; no manual `openssl dhparam` step needed.
  * OCSP stapling, session resumption, and ECDHE-only cipher suites out of the box.
* Reusable, curated config snippets for common tasks, ready to `include` in your site configs:
  * `http/tls-baseline.conf` -- TLS/SSL hardening (see above).
  * `server/headers-security.conf` -- security headers (`X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`).
  * `server/headers-hsts.conf` -- [HTTP Strict Transport Security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security) with configurable `max-age`, `includeSubDomains`, and `preload`.
  * `location/cache-static.conf` -- long-lived caching for static assets (`Cache-Control: public, immutable`).
  * `location/php-fpm.conf` -- FastCGI proxy for PHP-FPM (Unix socket or TCP).
* Sane defaults for gzip compression, `server_tokens off`, log format, and more (see `__run_nginx_http_directives_defaults` in [`vars/main.yml`](./vars/main.yml) for the complete list).
* Hardened catch-all `default_server` that returns HTTP 444 / rejects unknown TLS handshakes, preventing unintended content exposure for unknown hostnames.



## Example playbooks, using this role<a id="examples"></a>

Installation with automatic upgrade:

```yaml
---

- name: "Initialize the foundata.nginx.run role"
  hosts: localhost
  gather_facts: false
  tasks:

    - name: "Trigger invocation of the foundata.nginx.run role"
      ansible.builtin.include_role:
        name: "foundata.nginx.run"
      vars:
        run_nginx_autoupgrade: true
```

Installation with a TLS-enabled site, security headers, HSTS, and custom snippet settings:

```yaml
---

- name: "Initialize the foundata.nginx.run role"
  hosts: localhost
  gather_facts: false
  tasks:

    - name: "Trigger invocation of the foundata.nginx.run role"
      ansible.builtin.include_role:
        name: "foundata.nginx.run"
      vars:
        run_nginx_autoupgrade: true
        run_nginx_snippet_settings:
          hsts:
            max_age: 63072000 # 2 years
            include_subdomains: true
            preload: true
          tls-baseline:
            resolvers:
              - "127.0.0.1" # local resolver (e.g. unbound, systemd-resolved)
        run_nginx_sites_config:
          - name: "example.com"
            enabled: true
            content: |
              server {
                  listen 80;
                  listen [::]:80;
                  server_name example.com;
                  return 301 https://$host$request_uri;
              }
              server {
                  listen 443 ssl;
                  listen [::]:443 ssl;
                  server_name example.com;

                  ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
                  ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

                  include /etc/nginx/snippets/http/tls-baseline.conf;
                  include /etc/nginx/snippets/server/headers-security.conf;
                  include /etc/nginx/snippets/server/headers-hsts.conf;

                  root /var/www/example.com;
                  index index.html;

                  location / {
                      try_files $uri $uri/ =404;
                  }

                  location ~* \.(css|js|svg|png|jpg|gif|ico|woff2?)$ {
                      include /etc/nginx/snippets/location/cache-static.conf;
                  }
              }
        run_nginx_modules_enabled:
          - "http_headers_more_filter"
```

Installation with PHP-FPM (TCP backend) and a custom events config:

```yaml
---

- name: "Initialize the foundata.nginx.run role"
  hosts: localhost
  gather_facts: false
  tasks:

    - name: "Trigger invocation of the foundata.nginx.run role"
      ansible.builtin.include_role:
        name: "foundata.nginx.run"
      vars:
        run_nginx_snippet_settings:
          php-fpm:
            type: "tcp"
            tcp_host: "127.0.0.1"
            tcp_port: 9000
        run_nginx_events_config_block: |
          worker_connections 4096;
        run_nginx_sites_config:
          - name: "app.example.com"
            enabled: true
            content: |
              server {
                  listen 443 ssl;
                  listen [::]:443 ssl;
                  server_name app.example.com;

                  ssl_certificate /etc/letsencrypt/live/app.example.com/fullchain.pem;
                  ssl_certificate_key /etc/letsencrypt/live/app.example.com/privkey.pem;

                  include /etc/nginx/snippets/http/tls-baseline.conf;
                  include /etc/nginx/snippets/server/headers-security.conf;

                  root /var/www/app;
                  index index.php index.html;

                  location / {
                      try_files $uri $uri/ /index.php?$query_string;
                  }

                  location ~ \.php$ {
                      include /etc/nginx/snippets/location/php-fpm.conf;
                  }
              }
```

Uninstall:

```yaml
---

- name: "Initialize the foundata.nginx.run role"
  hosts: localhost
  gather_facts: false
  tasks:

    - name: "Trigger invocation of the foundata.nginx.run role"
      ansible.builtin.include_role:
        name: "foundata.nginx.run"
      vars:
        run_nginx_state: "absent"
```

On SELinux-enabled systems (RHEL, Fedora, AlmaLinux, CentOS Stream), NGINX may need additional permissions for network connections (e.g. reverse proxying to upstream backends). Add this to your playbook before including the role:

```yaml
- name: "Allow NGINX to make network connections (SELinux)"
  ansible.posix.seboolean:
    name: "httpd_can_network_connect"
    state: true
    persistent: true
  when:
    - ansible_facts['selinux']['status'] | default('disabled') == 'enabled'
```


## Supported tags<a id="tags"></a>

It might be useful and faster to only call parts of the role by using tags:

- `run_nginx_setup`: Manage basic resources, such as packages or service users.
- `run_nginx_config`: Manage settings, such as adapting or creating configuration files.
- `run_nginx_service`: Manage services and daemons, such as running states and service boot configurations.

There are also tags usually not meant to be called directly but listed for the sake of completeness** and edge cases:

- `run_nginx_always`, `always`: Tasks needed by the role itself for internal role setup and the Ansible environment.


<!-- ANSIBLE DOCSMITH MAIN START -->

## Role variables<a id="variables"></a>

See [`defaults/main.yml`](./defaults/main.yml) for all available role parameters and their description. [`vars/main.yml`](./vars/main.yml) contains internal variables you should not override (but their description might be interesting).

Additionally, there are variables read from other roles and/or the global scope (for example, host or group vars) as follows:

- None right now.

<!-- ANSIBLE DOCSMITH MAIN END -->

## Dependencies<a id="dependencies"></a>

See `dependencies` in [`meta/main.yml`](./meta/main.yml).



## Compatibility<a id="compatibility"></a>

See `min_ansible_version` in [`meta/main.yml`](./meta/main.yml) and `__run_nginx_supported_platforms` in [`vars/main.yml`](./vars/main.yml).



## External requirements<a id="requirements"></a>

There are no special requirements not covered by Ansible itself.

# Ansible role: `foundata.nginx.run`

<!--
SPDX-FileCopyrightText: foundata GmbH <https://foundata.com>
SPDX-License-Identifier: GPL-3.0-or-later
-->

The `foundata.nginx.run` Ansible role (part of the `foundata.nginx` Ansible
collection). It provides automated installation, configuration management, and
hardening of [NGINX](https://nginx.org/) across major Linux distributions.



## Table of contents<a id="toc"></a>

- [Features](#features)
- [Example playbooks, using this role](#examples)
- [Supported tags](#tags)<!-- ANSIBLE DOCSMITH TOC START -->
- [Role variables](#variables)
  - [`run_nginx_state`](#variable-run_nginx_state)
  - [`run_nginx_autoupgrade`](#variable-run_nginx_autoupgrade)
  - [`run_nginx_service_state`](#variable-run_nginx_service_state)
  - [`run_nginx_service_restart`](#variable-run_nginx_service_restart)
  - [`run_nginx_service_restart_sec`](#variable-run_nginx_service_restart_sec)
  - [`run_nginx_main_config_change_action`](#variable-run_nginx_main_config_change_action)
  - [`run_nginx_main_config_block`](#variable-run_nginx_main_config_block)
  - [`run_nginx_events_config_block`](#variable-run_nginx_events_config_block)
  - [`run_nginx_http_config_block`](#variable-run_nginx_http_config_block)
  - [`run_nginx_main_config_baseline_manage`](#variable-run_nginx_main_config_baseline_manage)
  - [`run_nginx_events_config_baseline_manage`](#variable-run_nginx_events_config_baseline_manage)
  - [`run_nginx_http_config_baseline_manage`](#variable-run_nginx_http_config_baseline_manage)
  - [`run_nginx_sites_config`](#variable-run_nginx_sites_config)
    - [`run_nginx_sites_config['name']`](#variable-run_nginx_sites_config-sub-name)
    - [`run_nginx_sites_config['enabled']`](#variable-run_nginx_sites_config-sub-enabled)
    - [`run_nginx_sites_config['content']`](#variable-run_nginx_sites_config-sub-content)
  - [`run_nginx_sites_delete_unmanaged`](#variable-run_nginx_sites_delete_unmanaged)
  - [`run_nginx_sites_defaultserver_manage`](#variable-run_nginx_sites_defaultserver_manage)
  - [`run_nginx_modules_enabled`](#variable-run_nginx_modules_enabled)
  - [`run_nginx_modules_disable_unmanaged`](#variable-run_nginx_modules_disable_unmanaged)
  - [`run_nginx_snippets_manage`](#variable-run_nginx_snippets_manage)
  - [`run_nginx_snippet_settings`](#variable-run_nginx_snippet_settings)
    - [`run_nginx_snippet_settings['hsts']`](#variable-run_nginx_snippet_settings-sub-hsts)
      - [`run_nginx_snippet_settings['hsts']['max_age']`](#variable-run_nginx_snippet_settings-sub-hsts-sub-max_age)
      - [`run_nginx_snippet_settings['hsts']['include_subdomains']`](#variable-run_nginx_snippet_settings-sub-hsts-sub-include_subdomains)
      - [`run_nginx_snippet_settings['hsts']['preload']`](#variable-run_nginx_snippet_settings-sub-hsts-sub-preload)
    - [`run_nginx_snippet_settings['php-fpm']`](#variable-run_nginx_snippet_settings-sub-php-fpm)
      - [`run_nginx_snippet_settings['php-fpm']['type']`](#variable-run_nginx_snippet_settings-sub-php-fpm-sub-type)
      - [`run_nginx_snippet_settings['php-fpm']['socket']`](#variable-run_nginx_snippet_settings-sub-php-fpm-sub-socket)
      - [`run_nginx_snippet_settings['php-fpm']['tcp_host']`](#variable-run_nginx_snippet_settings-sub-php-fpm-sub-tcp_host)
      - [`run_nginx_snippet_settings['php-fpm']['tcp_port']`](#variable-run_nginx_snippet_settings-sub-php-fpm-sub-tcp_port)
    - [`run_nginx_snippet_settings['tls-baseline']`](#variable-run_nginx_snippet_settings-sub-tls-baseline)
      - [`run_nginx_snippet_settings['tls-baseline']['stapling']`](#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-stapling)
      - [`run_nginx_snippet_settings['tls-baseline']['stapling_verify']`](#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-stapling_verify)
      - [`run_nginx_snippet_settings['tls-baseline']['dhparam_path']`](#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-dhparam_path)
      - [`run_nginx_snippet_settings['tls-baseline']['ecdh_curves']`](#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-ecdh_curves)
      - [`run_nginx_snippet_settings['tls-baseline']['resolvers']`](#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-resolvers)
      - [`run_nginx_snippet_settings['tls-baseline']['resolver_timeout']`](#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-resolver_timeout)
  - [`run_nginx_snippets_delete_unmanaged`](#variable-run_nginx_snippets_delete_unmanaged)
  - [`run_nginx_access_log_default_file_owner`](#variable-run_nginx_access_log_default_file_owner)
  - [`run_nginx_access_log_default_file_group`](#variable-run_nginx_access_log_default_file_group)
  - [`run_nginx_access_log_default_file_mode`](#variable-run_nginx_access_log_default_file_mode)
  - [`run_nginx_error_log_default_file_owner`](#variable-run_nginx_error_log_default_file_owner)
  - [`run_nginx_error_log_default_file_group`](#variable-run_nginx_error_log_default_file_group)
  - [`run_nginx_error_log_default_file_mode`](#variable-run_nginx_error_log_default_file_mode)
<!-- ANSIBLE DOCSMITH TOC END -->
- [Dependencies](#dependencies)
- [Compatibility](#compatibility)
- [External requirements](#requirements)



## Features<a id="features"></a>

Main features:

- **Site management** via `sites-available/` and `sites-enabled/` with optional
  cleanup of unmanaged files.
- **Dynamic module management:** enable modules by name, the role installs
  packages and creates `load_module` configs automatically with cross-platform
  support.
- Layered configuration merge: production-ready internal defaults (see
  [`__run_nginx_http_directives_defaults`](./vars/main.yml) for the complete
  list) and user settings are combined automatically. User-provided values
  always take precedence.
- **Hardened TLS baseline** following the
  [Mozilla "Intermediate" TLS profile (Guideline v6.0)](https://ssl-config.mozilla.org/#server=nginx&config=intermediate&hsts=1&ocsp=1&guideline=6.0):
  - Post-quantum key exchange (`X25519MLKEM768`) on platforms with OpenSSL >=
    3.5, automatic fallback to classical curves on older platforms.
  - Ships [RFC 7919](https://www.rfc-editor.org/rfc/rfc7919) ffdhe3072 DH
    parameters; no manual `openssl dhparam` step needed.
  - OCSP stapling, session resumption, and ECDHE-only cipher suites out of the
    box.
- **Reusable, curated config snippets** for common tasks, ready to `include` in
  your site configs:
  - `http/tls-baseline.conf` -- TLS/SSL hardening (see above).
  - `server/headers-security.conf` -- security headers
    (`X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`).
  - `server/headers-hsts.conf` --
    [HTTP Strict Transport Security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)
    with configurable `max-age`, `includeSubDomains`, and `preload`.
  - `location/cache-static.conf` -- long-lived caching for static assets
    (`Cache-Control: public, immutable`).
  - `location/php-fpm.conf` -- FastCGI proxy for PHP-FPM (Unix socket or TCP).
- **Hardened catch-all `default_server`** that returns HTTP 444 / rejects
  unknown TLS handshakes, preventing unintended content exposure for unknown
  hostnames.



## Example playbooks, using this role<a id="examples"></a>

Install referenced files such as TLS certificates and private keys before
calling the role. On every configuration run the role checks the installed
configuration with `nginx -t` before managing service state. It checks again
before a requested reload or restart. Correct any invalid files on disk before
restarting the service.

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

Installation with a TLS-enabled site, security headers, HSTS, and custom snippet
settings:

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

                  include snippets/http/tls-baseline.conf;
                  include snippets/server/headers-security.conf;
                  include snippets/server/headers-hsts.conf;

                  # Cert paths (all other TLS settings inherited from tls-baseline.conf)
                  ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
                  ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

                  root /var/www/example.com;
                  index index.html;

                  location / {
                      try_files $uri $uri/ =404;
                  }

                  location ~* \.(css|js|svg|png|jpg|gif|ico|woff2?)$ {
                      # With default inheritance, repeat all selected parent headers here.
                      include snippets/server/headers-security.conf;
                      include snippets/server/headers-hsts.conf;
                      include snippets/location/cache-static.conf;
                  }
              }
        run_nginx_modules_enabled:
          - "http_headers_more_filter"
```

If you explicitly set `add_header_inherit merge` (NGINX 1.29.3 or later), omit
the repeated security and HSTS includes in the static location to avoid
duplicate headers.

To log request and upstream timings as JSON for one site, define a named format
in the HTTP block and select it in that site's `server` block:

```yaml
run_nginx_http_config_block: |
  log_format ops escape=json
    '{"time":"$time_iso8601","host":"$host","method":"$request_method",'
    '"status":"$status","request_time":"$request_time","upstream_status":"$upstream_status",'
    '"upstream_response_time":"$upstream_response_time","request_id":"$request_id"}';
run_nginx_sites_config:
  - name: "shop"
    enabled: true
    content: |
      server {
          listen 80;
          server_name shop.example.com;
          access_log /var/log/nginx/shop-ops.log ops;
          location / { return 200 "shop"; }
      }
```

Provision the site's log with appropriate permissions and rotation before
running the role. The role's log-file options manage only the default access
and error logs. Sites that inherit the HTTP baseline keep its `main` format.
The example omits request paths, query strings and Referer values, which may
contain tokens. Keep upstream status and timing as strings: requests served
locally have no upstream values, and retried requests can record multiple
attempts. To correlate requests with application logs, set
`proxy_set_header X-Request-ID $request_id;` in the site's proxy location.

For certificates without an OCSP responder URL, disable stapling through the
snippet settings and keep the TLS baseline included in the site's `server`
block:

```yaml
run_nginx_snippet_settings:
  tls-baseline:
    stapling: false
    stapling_verify: false
```

This preserves the remaining TLS hardening. Remove any HTTP-scope include added
solely to work around stapling, and replace server-level `ssl_stapling off` and
`ssl_stapling_verify off` directives with
`include snippets/http/tls-baseline.conf;`. Include the baseline only once per
context to avoid duplicate directives. See the
[NGINX stapling documentation](https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_stapling)
for certificate-chain and resolver requirements when stapling is enabled.

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

                  include snippets/http/tls-baseline.conf;
                  include snippets/server/headers-security.conf;

                  # Cert paths (all other TLS settings inherited from tls-baseline.conf)
                  ssl_certificate /etc/letsencrypt/live/app.example.com/fullchain.pem;
                  ssl_certificate_key /etc/letsencrypt/live/app.example.com/privkey.pem;

                  root /var/www/app;
                  index index.php index.html;

                  location / {
                      try_files $uri $uri/ /index.php?$query_string;
                  }

                  location ~ \.php$ {
                      include snippets/location/php-fpm.conf;
                  }
              }
```

To recover automatically from service failures, including OOM failures reported
by systemd:

```yaml
run_nginx_service_restart: "on-failure"
run_nginx_service_restart_sec: 5
```

The default empty policy preserves the distribution's behavior. Returning to an
empty policy removes only the role's drop-in. Setting `"no"` explicitly disables
automatic restarts. Policy changes use daemon-reload and do not restart a
healthy service. `run_nginx_service_state: "unmanaged"` leaves the policy alone;
`"disabled"` applies the policy but keeps NGINX stopped and disabled at boot.

When replacing an application-specific override, remove its `Restart` and
`RestartSec` settings after configuring the role, then reload systemd and check
`systemctl show nginx -p Restart -p RestartUSec -p OOMPolicy`. The role
preserves other drop-ins, which can override its settings. An explicit
`systemctl stop` still stops the service. Package `OOMPolicy` and systemd start
rate limits are unchanged; repeated failures may exhaust the start limit. With
`OOMPolicy=stop` (as on Debian 13) or `kill`, systemd can restart the service
after a worker OOM; with `continue`, NGINX replaces failed workers itself. See
[systemd's service policy](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Restart=).
Automatic recovery complements application fixes and capacity monitoring; it
does not fix resource exhaustion.

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

On SELinux-enabled systems (RHEL, Fedora, AlmaLinux, CentOS Stream), NGINX may
need additional permissions for network connections (e.g. reverse proxying to
upstream backends). Add this to your playbook before including the role:

```yaml
- name: "Allow NGINX to make network connections (SELinux)"
  ansible.posix.seboolean:
    name: "httpd_can_network_connect"
    state: true
    persistent: true
  when:
    - ansible_facts['selinux']['status'] | ansible.builtin.default('disabled') == 'enabled'
```


## Supported tags<a id="tags"></a>

Run parts of the role with `--tags`:

- `run_nginx_setup`: Manage basic resources, such as packages or service users.
- `run_nginx_config`: Manage settings, such as adapting or creating
  configuration files.
- `run_nginx_service`: Manage services and daemons, such as running states and
  service boot configurations.

The init tasks check the environment and prepare the role. They carry the tags
`run_nginx_always` and `always`, so they run with any `--tags` selection; do
not skip them.


<!-- ANSIBLE DOCSMITH MAIN START -->

## Role variables<a id="variables"></a>

Main entry point for the foundata.nginx.run role.

Manage NGINX (a HTTP web server, reverse proxy, cache, load balancer)

The following variables can be configured for this role:

|                 Variable                  |  Type  | Required |                       Default                       | Description (abstract) |
| ----------------------------------------- | ------ | -------- | --------------------------------------------------- | ---------------------- |
| `run_nginx_state`                         | `str`  | No       | `"present"`                                         | Determines whether the managed resources should be `present` or `absent`.<br><br>`present` ensures that required components, such as software packages, are installed and configured.<br><br>`absent` reverts changes as much as possible, such as […](#variable-run_nginx_state) |
| `run_nginx_autoupgrade`                   | `bool` | No       | `false`                                             | If set to `true`, each Ansible run upgrades the managed packages to the newest version the package provider offers. |
| `run_nginx_service_state`                 | `str`  | No       | `"enabled"`                                         | Defines the status of the service(s). Possible values:<br><br>- `enabled`: Service is running and will start automatically at boot. - `disabled`: Service is stopped and will not start automatically at boot. - `running`: Service is running but will […](#variable-run_nginx_service_state) |
| `run_nginx_service_restart`               | `str`  | No       | `""`                                                | Optional systemd `Restart` policy. An empty string (the default) removes the role's drop-in and uses the distribution's policy and any administrator overrides. `on-failure` recovers from unsuccessful exits, signals, timeouts and OOM failures. An […](#variable-run_nginx_service_restart) |
| `run_nginx_service_restart_sec`           | `int`  | No       | `5`                                                 | Non-negative delay in seconds before systemd automatically restarts NGINX. Written as `RestartSec` only when `run_nginx_service_restart` is non-empty. The default delay is five seconds. Systemd's existing start rate limits can still stop repeated […](#variable-run_nginx_service_restart_sec) |
| `run_nginx_main_config_change_action`     | `str`  | No       | `"restart"`                                         | Service action when the role changes `nginx.conf`, including its events and HTTP blocks. The default `restart` supports configurations that require a new master process. Select `reload` for configurations that NGINX can apply gracefully.<br><br>Site […](#variable-run_nginx_main_config_change_action) |
| `run_nginx_main_config_block`             | `str`  | No       | `""`                                                | Additional NGINX configuration directives for the main (top-level) context of `nginx.conf`, placed outside of any block such as `events {}` or `http {}`.<br><br>The value is inserted verbatim into the rendered configuration file. Only directives […](#variable-run_nginx_main_config_block) |
| `run_nginx_events_config_block`           | `str`  | No       | `""`                                                | Additional NGINX configuration directives for the `events {}` block in the main configuration file (`nginx.conf`).<br><br>The value is inserted verbatim inside the `events {}` block. Do not include the `events {` and `}` delimiters themselves - only […](#variable-run_nginx_events_config_block) |
| `run_nginx_http_config_block`             | `str`  | No       | `""`                                                | Additional NGINX configuration directives for the `http {}` block in the main configuration file (`nginx.conf`).<br><br>The value is inserted verbatim inside the `http {}` block. Do not include the `http {` and `}` delimiters themselves - only the […](#variable-run_nginx_http_config_block) |
| `run_nginx_main_config_baseline_manage`   | `bool` | No       | `true`                                              | Controls whether the role injects curated baseline directives into the main (top-level) context of the main configuration file (`nginx.conf`).<br><br>When set to `true`, the role provides sane defaults for the main context (e.g., `worker_processes`, […](#variable-run_nginx_main_config_baseline_manage) |
| `run_nginx_events_config_baseline_manage` | `bool` | No       | `true`                                              | Controls whether the role injects curated baseline directives into the `events {}` block of the main configuration file (`nginx.conf`).<br><br>When set to `true`, the role provides sane defaults for the events context (e.g., `worker_connections`). […](#variable-run_nginx_events_config_baseline_manage) |
| `run_nginx_http_config_baseline_manage`   | `bool` | No       | `true`                                              | Controls whether the role injects curated baseline directives into the `http {}` block of the main configuration file (`nginx.conf`).<br><br>When set to `true`, the role provides sane defaults for the HTTP context (e.g., `sendfile`, `tcp_nopush`, […](#variable-run_nginx_http_config_baseline_manage) |
| `run_nginx_sites_config`                  | `list` | No       | `[]`                                                | List of site definitions (sometimes called vHosts) to manage. Each entry describes a site as a dictionary holding its name, enablement state, and raw NGINX configuration content.<br><br>For each entry, the role renders a config file at […](#variable-run_nginx_sites_config) |
| `run_nginx_sites_delete_unmanaged`        | `bool` | No       | `true`                                              | Controls whether the role removes stale site files that are not declared in `run_nginx_sites_config`.<br><br>When set to `true`, any `*.conf` file or symlink found in `/etc/nginx/sites-available/` or `/etc/nginx/sites-enabled/` whose name does not […](#variable-run_nginx_sites_delete_unmanaged) |
| `run_nginx_sites_defaultserver_manage`    | `bool` | No       | `true`                                              | Controls whether the role includes a hardened catch-all `server {}` block in the `http {}` section of the main configuration file (`nginx.conf`).<br><br>When set to `true`, a default server is rendered that listens on ports 80 and 443 with […](#variable-run_nginx_sites_defaultserver_manage) |
| `run_nginx_modules_enabled`               | `list` | No       | `[]`                                                | List of dynamic NGINX module names to enable at runtime.<br><br>Module names follow the canonical `.so` filename with the `ngx_` prefix and `_module` suffix stripped. The general pattern is `_` (e.g. `http_perl` from `ngx_http_perl_module.so`). See […](#variable-run_nginx_modules_enabled) |
| `run_nginx_modules_disable_unmanaged`     | `bool` | No       | `true`                                              | Controls whether the role removes dynamic module symlinks that are not declared in `run_nginx_modules_enabled`.<br><br>When set to `true`, any `*.conf` file or symlink found in `/etc/nginx/modules-enabled/` whose name does not match an entry in […](#variable-run_nginx_modules_disable_unmanaged) |
| `run_nginx_snippets_manage`               | `bool` | No       | `true`                                              | Controls whether the role ships and manages its curated NGINX config snippets (reusable, centrally maintained config blocks meant to be pulled into `server {}` / `location {}` blocks via `include snippets/.conf;`).<br><br>When set to `true`, the role […](#variable-run_nginx_snippets_manage) |
| `run_nginx_snippet_settings`              | `dict` | No       | `{}`                                                | User-level overrides for the configuration snippets shipped by this role.<br><br>Each top-level key corresponds to a snippet name (e.g. `hsts`, `php-fpm`, `tls-baseline`). Values are dictionaries whose keys map to template variables used when […](#variable-run_nginx_snippet_settings) |
| `run_nginx_snippets_delete_unmanaged`     | `bool` | No       | `false`                                             | Controls whether the role removes snippet files below `/etc/nginx/snippets/` that are not managed by this role.<br><br>When set to `true`, any files in the snippet subdirectories (`http/`, `server/`, `location/`) that were not rendered by the role's […](#variable-run_nginx_snippets_delete_unmanaged) |
| `run_nginx_access_log_default_file_owner` | `str`  | No       | `"{{ __run_nginx_access_log_default_file_owner }}"` | Owner of `/var/log/nginx/access.log`. Defaults to `www-data` on Debian and Ubuntu, and `nginx` on RHEL-family and SUSE systems.<br><br>The role creates the file if missing and preserves existing contents and timestamps. Attribute changes do not […](#variable-run_nginx_access_log_default_file_owner) |
| `run_nginx_access_log_default_file_group` | `str`  | No       | `"{{ __run_nginx_access_log_default_file_group }}"` | Group of `/var/log/nginx/access.log`. Defaults to `adm` on Debian and Ubuntu, `root` on RHEL-family systems, and `nginx` on SUSE.<br><br>The role creates the file if missing and preserves existing contents and timestamps. Attribute changes do not […](#variable-run_nginx_access_log_default_file_group) |
| `run_nginx_access_log_default_file_mode`  | `str`  | No       | `"{{ __run_nginx_access_log_default_file_mode }}"`  | Permissions of `/var/log/nginx/access.log`, as a quoted octal or symbolic mode. Defaults to `u=rw,g=r,o=` (`0640`) on all supported platforms.<br><br>The role creates the file if missing and preserves existing contents and timestamps. Attribute […](#variable-run_nginx_access_log_default_file_mode) |
| `run_nginx_error_log_default_file_owner`  | `str`  | No       | `"{{ __run_nginx_error_log_default_file_owner }}"`  | Owner of `/var/log/nginx/error.log`. Defaults to `www-data` on Debian and Ubuntu, and `nginx` on RHEL-family and SUSE systems.<br><br>The role creates the file if missing and preserves existing contents and timestamps. Attribute changes do not […](#variable-run_nginx_error_log_default_file_owner) |
| `run_nginx_error_log_default_file_group`  | `str`  | No       | `"{{ __run_nginx_error_log_default_file_group }}"`  | Group of `/var/log/nginx/error.log`. Defaults to `adm` on Debian and Ubuntu, `root` on RHEL-family systems, and `nginx` on SUSE.<br><br>The role creates the file if missing and preserves existing contents and timestamps. Attribute changes do not […](#variable-run_nginx_error_log_default_file_group) |
| `run_nginx_error_log_default_file_mode`   | `str`  | No       | `"{{ __run_nginx_error_log_default_file_mode }}"`   | Permissions of `/var/log/nginx/error.log`, as a quoted octal or symbolic mode. Defaults to `u=rw,g=r,o=` (`0640`) on all supported platforms.<br><br>The role creates the file if missing and preserves existing contents and timestamps. Attribute […](#variable-run_nginx_error_log_default_file_mode) |

### `run_nginx_state`<a id="variable-run_nginx_state"></a>

[*⇑ Back to ToC ⇑*](#toc)

Determines whether the managed resources should be `present` or `absent`.

`present` ensures that required components, such as software packages, are
installed and configured.

`absent` reverts changes as much as possible, such as removing packages,
deleting created users, stopping services and restoring modified settings.

- **Type**: `str`
- **Required**: No
- **Default**: `"present"`
- **Choices**: `present`, `absent`



### `run_nginx_autoupgrade`<a id="variable-run_nginx_autoupgrade"></a>

[*⇑ Back to ToC ⇑*](#toc)

If set to `true`, each Ansible run upgrades the managed packages to the
newest version the package provider offers.

- **Type**: `bool`
- **Required**: No
- **Default**: `false`



### `run_nginx_service_state`<a id="variable-run_nginx_service_state"></a>

[*⇑ Back to ToC ⇑*](#toc)

Defines the status of the service(s). Possible values:

- `enabled`: Service is running and will start automatically at boot.
- `disabled`: Service is stopped and will not start automatically at boot.
- `running`: Service is running but will not start automatically at boot.
  This can be used to start a service on the first Ansible run without
  enabling it for boot.
- `unmanaged`: Ansible does not manage the service at all: both the
  running state and the boot (enablement) state are left exactly as they
  are. This is primarily useful when services are monitored and managed
  by systems other than Ansible.

The defined status applies to all services if the role manages several.

- **Type**: `str`
- **Required**: No
- **Default**: `"enabled"`
- **Choices**: `enabled`, `disabled`, `running`, `unmanaged`



### `run_nginx_service_restart`<a id="variable-run_nginx_service_restart"></a>

[*⇑ Back to ToC ⇑*](#toc)

Optional systemd `Restart` policy. An empty string (the default)
removes the role's drop-in and uses the distribution's policy and
any administrator overrides. `on-failure` recovers from unsuccessful
exits, signals, timeouts and OOM failures. An explicit service stop
does not trigger automatic recovery.

The role manages only
`/etc/systemd/system/nginx.service.d/50-foundata-nginx-restart.conf`.
Changes take effect through daemon-reload without restarting NGINX.
Other drop-ins are preserved; remove conflicting application overrides
when migrating. No policy changes are made while
`run_nginx_service_state` is `unmanaged`.

The package's `OOMPolicy` and systemd start rate limits remain in
effect. Worker OOM recovery through systemd requires `OOMPolicy=stop`
or `kill`; with `continue`, NGINX handles worker replacement itself.
Recovery does not resolve memory exhaustion or replace resource
limits, capacity monitoring and application fixes.

- **Type**: `str`
- **Required**: No
- **Default**: `""`
- **Choices**: ``, `no`, `on-success`, `on-failure`, `on-abnormal`,
  `on-watchdog`, `on-abort`, `always`



### `run_nginx_service_restart_sec`<a id="variable-run_nginx_service_restart_sec"></a>

[*⇑ Back to ToC ⇑*](#toc)

Non-negative delay in seconds before systemd automatically restarts
NGINX. Written as `RestartSec` only when `run_nginx_service_restart`
is non-empty. The default delay is five seconds. Systemd's existing
start rate limits can still stop repeated restart attempts.

- **Type**: `int`
- **Required**: No
- **Default**: `5`



### `run_nginx_main_config_change_action`<a id="variable-run_nginx_main_config_change_action"></a>

[*⇑ Back to ToC ⇑*](#toc)

Service action when the role changes `nginx.conf`, including its
events and HTTP blocks. The default `restart` supports configurations
that require a new master process. Select `reload` for configurations
that NGINX can apply gracefully.

Site and snippet changes request a reload. Module configuration
changes request a restart, which takes precedence in the same handler
flush. The role acts on running or enabled services.

- **Type**: `str`
- **Required**: No
- **Default**: `"restart"`
- **Choices**: `restart`, `reload`



### `run_nginx_main_config_block`<a id="variable-run_nginx_main_config_block"></a>

[*⇑ Back to ToC ⇑*](#toc)

Additional NGINX configuration directives for the main (top-level) context
of `nginx.conf`, placed outside of any block such as `events {}` or `http {}`.

The value is inserted verbatim into the rendered configuration file. Only
directives valid in the NGINX main context should be used here (e.g.,
`worker_processes`, `error_log`, `pid`).

For block-specific configuration, use the dedicated variables instead:

- `run_nginx_events_config_block` (for the `events {}` block)
- `run_nginx_http_config_block` (for the `http {}` block)
- `run_nginx_sites_config` (for `server {}` blocks)
- **Type**: `str`
- **Required**: No
- **Default**: `""`



### `run_nginx_events_config_block`<a id="variable-run_nginx_events_config_block"></a>

[*⇑ Back to ToC ⇑*](#toc)

Additional NGINX configuration directives for the `events {}` block in the
main configuration file (`nginx.conf`).

The value is inserted verbatim inside the `events {}` block. Do not include
the `events {` and `}` delimiters themselves - only the directives that belong
inside the block (e.g., `worker_connections`, `use`).

`events {}` is a top-level context block in NGINX. Only one instance is
allowed, so this variable provides a way to inject custom directives there.

- **Type**: `str`
- **Required**: No
- **Default**: `""`



### `run_nginx_http_config_block`<a id="variable-run_nginx_http_config_block"></a>

[*⇑ Back to ToC ⇑*](#toc)

Additional NGINX configuration directives for the `http {}` block in the
main configuration file (`nginx.conf`).

The value is inserted verbatim inside the `http {}` block. Do not include
the `http {` and `}` delimiters themselves - only the directives that belong
inside the block (e.g., `include`, `default_type`, `log_format`).

`http {}` is a top-level context block that initializes the entire HTTP
subsystem. Only one instance is allowed, so this variable provides a way
to inject custom directives there. For `server {}` block definitions, use
`run_nginx_sites_config` instead.

- **Type**: `str`
- **Required**: No
- **Default**: `""`



### `run_nginx_main_config_baseline_manage`<a id="variable-run_nginx_main_config_baseline_manage"></a>

[*⇑ Back to ToC ⇑*](#toc)

Controls whether the role injects curated baseline directives into the main
(top-level) context of the main configuration file (`nginx.conf`).

When set to `true`, the role provides sane defaults for the main context
(e.g., `worker_processes`, `error_log`, `pid`). These baseline directives
are merged from internal defaults and platform-specific overrides.

Custom directives supplied via `run_nginx_main_config_block` are rendered
alongside the baseline. If set to `false`, no baseline directives are
injected and you will likely need to provide essential main-context
directives yourself via `run_nginx_main_config_block` to get a working
service.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`



### `run_nginx_events_config_baseline_manage`<a id="variable-run_nginx_events_config_baseline_manage"></a>

[*⇑ Back to ToC ⇑*](#toc)

Controls whether the role injects curated baseline directives into the
`events {}` block of the main configuration file (`nginx.conf`).

When set to `true`, the role provides sane defaults for the events context
(e.g., `worker_connections`). These baseline directives are merged from
internal defaults and platform-specific overrides.

Custom directives supplied via `run_nginx_events_config_block` are rendered
alongside the baseline.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`



### `run_nginx_http_config_baseline_manage`<a id="variable-run_nginx_http_config_baseline_manage"></a>

[*⇑ Back to ToC ⇑*](#toc)

Controls whether the role injects curated baseline directives into the
`http {}` block of the main configuration file (`nginx.conf`).

When set to `true`, the role provides sane defaults for the HTTP context
(e.g., `sendfile`, `tcp_nopush`, `types_hash_max_size`, MIME type includes).
These baseline directives are merged from internal defaults and
platform-specific overrides.

Custom directives supplied via `run_nginx_http_config_block` are rendered
alongside the baseline.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`



### `run_nginx_sites_config`<a id="variable-run_nginx_sites_config"></a>

[*⇑ Back to ToC ⇑*](#toc)

List of site definitions (sometimes called vHosts) to manage. Each entry
describes a site as a dictionary holding its name, enablement state, and
raw NGINX configuration content.

For each entry, the role renders a config file at
`/etc/nginx/sites-available/<name>.conf`. If `enabled: true`, a symlink
is created in `/etc/nginx/sites-enabled/` pointing to the file in
`sites-available/`. The `sites-enabled/` directory is included by the
main `http {}` block via the role's managed `nginx.conf`, so only
symlinked sites become active. Setting `enabled: false` keeps the
`sites-available/` file in place but removes the symlink, making it easy
to temporarily disable a site without losing its configuration.

Stale `sites-available/` and `sites-enabled/` files no longer listed
here are removed when `run_nginx_sites_delete_unmanaged` is `true`
(the default).

On SUSE-like platforms the directories `hosts.d-available/` (instead of
`sites-available/`) and `/etc/nginx/vhosts.d` (instead of`sites-available/`)
are used as SUSE uses theses dirs and the "vHost" terminology by default.

Example:

```yaml
run_nginx_sites_config:
  - name: "example.com"
    enabled: true
    content: |
      server {
          listen 443 ssl;
          server_name example.com;
          root /var/www/example.com;

          ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
          ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

          include /etc/nginx/snippets/http/tls-baseline.conf;
          include /etc/nginx/snippets/server/headers-security.conf;
          include /etc/nginx/snippets/server/headers-hsts.conf;

          location / {
              try_files $uri $uri/ =404;
          }
      }
  - name: "foo_bar"
    enabled: true
    content: |
      upstream {
          [...]
      }
      server {
          [...]
      }
```

- **Type**: `list`
- **Required**: No
- **Default**: `[]`

#### `run_nginx_sites_config['name']`<a id="variable-run_nginx_sites_config-sub-name"></a>

[*⇑ Back to ToC ⇑*](#toc)

Identifier used to build the config filename (`<name>.conf`) below
`sites-available/` and `sites-enabled/`. Must be unique within
`run_nginx_sites_config`; duplicate names cause the role to fail
with a validation error.

Allowed characters: `a-z`, `A-Z`, `0-9`, dot (`.`), underscore
(`_`), and hyphen (`-`). Any other character causes the role to
fail with a validation error.

- **Type**: `str`
- **Required**: No

#### `run_nginx_sites_config['enabled']`<a id="variable-run_nginx_sites_config-sub-enabled"></a>

[*⇑ Back to ToC ⇑*](#toc)

Controls whether the site is active.

When `true`, a symlink is created in `sites-enabled/` pointing to
the corresponding file in `sites-available/`, so NGINX includes
it. When `false`, the symlink is removed while the file in
`sites-available/` is kept in place, allowing the site to be
disabled without losing its configuration.

- **Type**: `bool`
- **Required**: No
- **Default**: `false`

#### `run_nginx_sites_config['content']`<a id="variable-run_nginx_sites_config-sub-content"></a>

[*⇑ Back to ToC ⇑*](#toc)

Raw NGINX configuration for the site, inserted verbatim into the
rendered file. Any valid NGINX configuration at the `http {}`
child-context level is accepted, typically at least one `server {}`
block, and optionally `upstream {}` or other supporting blocks.

Do not wrap the content in an `http {}` block: it is already
placed inside the main `http {}` context via the include from
`sites-enabled/`. Snippets provided by this role can be pulled in
with `include snippets/<name>.conf;` as needed.

- **Type**: `str`
- **Required**: No



### `run_nginx_sites_delete_unmanaged`<a id="variable-run_nginx_sites_delete_unmanaged"></a>

[*⇑ Back to ToC ⇑*](#toc)

Controls whether the role removes stale site files that are not
declared in `run_nginx_sites_config`.

When set to `true`, any `*.conf` file or symlink found in
`/etc/nginx/sites-available/` or `/etc/nginx/sites-enabled/` whose
name does not match an entry in `run_nginx_sites_config` is deleted.
This keeps the managed directories in sync with the declared list,
treating `run_nginx_sites_config` as the single source of truth.

When set to `false`, unknown files are left untouched. Use this if
you manage additional sites outside of this role and want to prevent
accidental removal.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`



### `run_nginx_sites_defaultserver_manage`<a id="variable-run_nginx_sites_defaultserver_manage"></a>

[*⇑ Back to ToC ⇑*](#toc)

Controls whether the role includes a hardened catch-all `server {}` block
in the `http {}` section of the main configuration file (`nginx.conf`).

When set to `true`, a default server is rendered that listens on ports 80
and 443 with `default_server`.

This acts as a security fallback preventing unintended content exposure
when requests arrive for unknown hostnames or manipulated SNI values.
Set to `false` if you prefer to define your own catch-all server via
`run_nginx_sites_config`.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`



### `run_nginx_modules_enabled`<a id="variable-run_nginx_modules_enabled"></a>

[*⇑ Back to ToC ⇑*](#toc)

List of dynamic NGINX module names to enable at runtime.

Module names follow the canonical `.so` filename with the `ngx_` prefix
and `_module` suffix stripped. The general pattern is `<context>_<name>`
(e.g. `http_perl` from `ngx_http_perl_module.so`). See the naming
convention comment in `vars/main.yml` for the full specification.

Module availability varies between distributions and releases (for
example, `http_auth_spnego` and `http_push_stream` are not packaged
for Debian 12 and Ubuntu 24.04). Enabling a module that is not
packaged for the target platform fails at the package installation.

Example:

```yaml
run_nginx_modules_enabled:
  - "http_echo"
  - "http_headers_more_filter"
  - "http_image_filter"
  - "http_brotli_filter"
  - "http_brotli_static"
```

There are two types of modules in NGINX: built-in and dynamic. Only
dynamic modules can be toggled this way; modules compiled into the NGINX
binary are always active and cannot be managed via this list
(`nginx -V 2>&1 | xargs -n1 | grep module` shows the compiled-in set).

Only modules known to the platform-specific
`__run_nginx_modules_map_resources` mapping (see `vars/main.yml`
and the platform overrides in `vars/debian.yml`, `vars/redhat.yml`,
`vars/suse.yml`) are managed by this role. Modules not present in
that mapping are silently skipped; if you need to enable such a
module, add the necessary `load_module` configuration via your own
tasks on top of this role.

For each listed and known module, the role installs required
distribution packages automatically and places the appropriate
config file in `/etc/nginx/modules-enabled/`. On platforms where
packages ship their own `.conf` files (Debian, RedHat, Fedora),
the role creates a symlink to the package-provided file. On
platforms without package-provided configs (SUSE), the role
generates a `load_module` config file directly.

- **Type**: `list`
- **Required**: No
- **Default**: `[]`



### `run_nginx_modules_disable_unmanaged`<a id="variable-run_nginx_modules_disable_unmanaged"></a>

[*⇑ Back to ToC ⇑*](#toc)

Controls whether the role removes dynamic module symlinks that are not
declared in `run_nginx_modules_enabled`.

When set to `true`, any `*.conf` file or symlink found in
`/etc/nginx/modules-enabled/` whose name does not match an entry in
`run_nginx_modules_enabled` is removed. This keeps the managed directory
in sync with the declared list, treating `run_nginx_modules_enabled` as
the single source of truth.

When set to `false`, unknown files are left untouched. Use this if you
manage additional modules outside of this role and want to prevent
accidental unavailability of dynamic modules loaded by default on your
platform.

Stale cleanup is only performed when the platform-specific module
mapping provides `conf_files` data. On platforms where `conf_files`
is empty for all modules (package postinst handles everything),
stale cleanup is automatically skipped.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`



### `run_nginx_snippets_manage`<a id="variable-run_nginx_snippets_manage"></a>

[*⇑ Back to ToC ⇑*](#toc)

Controls whether the role ships and manages its curated NGINX
config snippets (reusable, centrally maintained config blocks
meant to be pulled into `server {}` / `location {}` blocks via
`include snippets/<name>.conf;`).

When set to `true`, the role ensures the
`/etc/nginx/snippets/{http,location,server}/` directories exist
and renders all snippet templates shipped with the role into
them. Snippet content can be influenced via
`run_nginx_snippet_settings`.

When set to `false`, the role skips creating the snippet
directories and does not render any snippet templates. Use this
if you want to maintain your own snippet library entirely
outside of this role. Cleanup of stale files is also gated by
this variable: `run_nginx_snippets_delete_unmanaged` only takes
effect while snippets are managed.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`



### `run_nginx_snippet_settings`<a id="variable-run_nginx_snippet_settings"></a>

[*⇑ Back to ToC ⇑*](#toc)

User-level overrides for the configuration snippets shipped by this role.

Each top-level key corresponds to a snippet name (e.g. `hsts`, `php-fpm`,
`tls-baseline`). Values are dictionaries whose keys map to template
variables used when rendering the snippet.

Settings provided here take highest priority, overriding both the internal
defaults (see `__run_nginx_snippet_settings_defaults` in `vars/main.yml`)
and any platform-specific overrides. Only the keys you specify are
overridden; all other settings keep their default values.

Example:

```yaml
run_nginx_snippet_settings:
  hsts:
    max_age: 63072000
    preload: true
  tls-baseline:
    resolvers:
      - "127.0.0.1"
```

- **Type**: `dict`
- **Required**: No
- **Default**: `{}`

#### `run_nginx_snippet_settings['hsts']`<a id="variable-run_nginx_snippet_settings-sub-hsts"></a>

[*⇑ Back to ToC ⇑*](#toc)

Settings for the `server/headers-hsts.conf` snippet that renders
the `Strict-Transport-Security` HTTP response header.

- **Type**: `dict`
- **Required**: No

##### `run_nginx_snippet_settings['hsts']['max_age']`<a id="variable-run_nginx_snippet_settings-sub-hsts-sub-max_age"></a>

[*⇑ Back to ToC ⇑*](#toc)

Duration in seconds that the browser should remember to only
access the site via HTTPS. The default of 31536000 corresponds
to one year, which is the minimum recommended by
<https://hstspreload.org/>.

- **Type**: `int`
- **Required**: No
- **Default**: `31536000`

<a id="variable-run_nginx_snippet_settings-sub-hsts-sub-include_subdomains"></a>

##### `run_nginx_snippet_settings['hsts']['include_subdomains']`

[*⇑ Back to ToC ⇑*](#toc)

Whether to extend the HSTS policy to all subdomains of the
current domain. Required for HSTS preload list submission.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`

##### `run_nginx_snippet_settings['hsts']['preload']`<a id="variable-run_nginx_snippet_settings-sub-hsts-sub-preload"></a>

[*⇑ Back to ToC ⇑*](#toc)

Whether to add the `preload` directive, signalling to browser
vendors that the domain should be included in the HSTS Preload
List (hardcoded into browsers). This is practically irreversible;
removal takes months.

- **Type**: `bool`
- **Required**: No
- **Default**: `false`


#### `run_nginx_snippet_settings['php-fpm']`<a id="variable-run_nginx_snippet_settings-sub-php-fpm"></a>

[*⇑ Back to ToC ⇑*](#toc)

Settings for the `location/php-fpm.conf` snippet that configures
FastCGI proxying to a PHP-FPM backend. The snippet renders a
`location ~ \.php$` block with the appropriate `fastcgi_pass`
directive.

- **Type**: `dict`
- **Required**: No

##### `run_nginx_snippet_settings['php-fpm']['type']`<a id="variable-run_nginx_snippet_settings-sub-php-fpm-sub-type"></a>

[*⇑ Back to ToC ⇑*](#toc)

Connection method to the PHP-FPM backend. `socket` connects
via a Unix domain socket (lower overhead, same-host only).
`tcp` connects via TCP (allows remote backends).

- **Type**: `str`
- **Required**: No
- **Default**: `"socket"`
- **Choices**: `socket`, `tcp`

##### `run_nginx_snippet_settings['php-fpm']['socket']`<a id="variable-run_nginx_snippet_settings-sub-php-fpm-sub-socket"></a>

[*⇑ Back to ToC ⇑*](#toc)

Absolute path to the PHP-FPM Unix socket. Only used when
`type` is set to `socket`.

- **Type**: `str`
- **Required**: No
- **Default**: `"/run/php/php-fpm.sock"`

##### `run_nginx_snippet_settings['php-fpm']['tcp_host']`<a id="variable-run_nginx_snippet_settings-sub-php-fpm-sub-tcp_host"></a>

[*⇑ Back to ToC ⇑*](#toc)

Hostname or IP address of the PHP-FPM backend. Only used
when `type` is set to `tcp`.

- **Type**: `str`
- **Required**: No
- **Default**: `"127.0.0.1"`

##### `run_nginx_snippet_settings['php-fpm']['tcp_port']`<a id="variable-run_nginx_snippet_settings-sub-php-fpm-sub-tcp_port"></a>

[*⇑ Back to ToC ⇑*](#toc)

TCP port of the PHP-FPM backend. Only used when `type` is
set to `tcp`.

- **Type**: `int`
- **Required**: No
- **Default**: `9000`


#### `run_nginx_snippet_settings['tls-baseline']`<a id="variable-run_nginx_snippet_settings-sub-tls-baseline"></a>

[*⇑ Back to ToC ⇑*](#toc)

Settings for the `http/tls-baseline.conf` snippet that provides
TLS hardening following the Mozilla "Intermediate" profile
(Guideline v6.0).

- **Type**: `dict`
- **Required**: No

<a id="variable-run_nginx_snippet_settings-sub-tls-baseline-sub-stapling"></a>

##### `run_nginx_snippet_settings['tls-baseline']['stapling']`

[*⇑ Back to ToC ⇑*](#toc)

Enable OCSP stapling via `ssl_stapling`. Set to `false` for
certificates without an OCSP responder URL to avoid NGINX
configuration warnings. All other TLS baseline settings remain
active. The default preserves the existing stapling behavior.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`

<a id="variable-run_nginx_snippet_settings-sub-tls-baseline-sub-stapling_verify"></a>

##### `run_nginx_snippet_settings['tls-baseline']['stapling_verify']`

[*⇑ Back to ToC ⇑*](#toc)

Verify stapled OCSP responses via `ssl_stapling_verify`.
Verification requires the issuer, root and intermediate
certificates in `ssl_trusted_certificate`. This setting has
no effect while stapling is disabled.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`

<a id="variable-run_nginx_snippet_settings-sub-tls-baseline-sub-dhparam_path"></a>

##### `run_nginx_snippet_settings['tls-baseline']['dhparam_path']`

[*⇑ Back to ToC ⇑*](#toc)

Absolute path where the DH parameters file is deployed. The
role ships RFC 7919 ffdhe3072 parameters and deploys them to
this path automatically. Platform-specific vars files override
this to match each distribution's conventional TLS directory
(e.g. `/etc/pki/tls/certs/` on Red Hat).

- **Type**: `str`
- **Required**: No
- **Default**: `"/etc/ssl/certs/dhparam_ffdhe3072.pem"`

<a id="variable-run_nginx_snippet_settings-sub-tls-baseline-sub-ecdh_curves"></a>

##### `run_nginx_snippet_settings['tls-baseline']['ecdh_curves']`

[*⇑ Back to ToC ⇑*](#toc)

Colon-separated list of elliptic curves for ECDHE key exchange,
passed to the `ssl_ecdh_curve` directive. The default includes
the post-quantum hybrid `X25519MLKEM768` (requires OpenSSL >= 3.5);
platforms with older OpenSSL automatically fall back to a
classical-only list via version-specific vars files.

- **Type**: `str`
- **Required**: No
- **Default**: `"X25519MLKEM768:X25519:prime256v1:secp384r1"`

<a id="variable-run_nginx_snippet_settings-sub-tls-baseline-sub-resolvers"></a>

##### `run_nginx_snippet_settings['tls-baseline']['resolvers']`

[*⇑ Back to ToC ⇑*](#toc)

List of DNS resolver IP addresses used by NGINX for OCSP
stapling lookups. Using a local resolver (e.g. unbound,
systemd-resolved at `127.0.0.1`) is recommended for privacy
and latency.

- **Type**: `list`
- **Required**: No
- **List Elements**: `str`

<a id="variable-run_nginx_snippet_settings-sub-tls-baseline-sub-resolver_timeout"></a>

##### `run_nginx_snippet_settings['tls-baseline']['resolver_timeout']`

[*⇑ Back to ToC ⇑*](#toc)

Timeout for DNS resolver queries used by OCSP stapling.

- **Type**: `str`
- **Required**: No
- **Default**: `"3s"`



### `run_nginx_snippets_delete_unmanaged`<a id="variable-run_nginx_snippets_delete_unmanaged"></a>

[*⇑ Back to ToC ⇑*](#toc)

Controls whether the role removes snippet files below
`/etc/nginx/snippets/` that are not managed by this role.

When set to `true`, any files in the snippet subdirectories
(`http/`, `server/`, `location/`) that were not rendered by the
role's snippet templates are deleted. This keeps the snippet
directories clean and prevents stale or conflicting snippets.

When set to `false`, unknown files are left untouched. Use this
if you maintain additional custom snippets outside of this role.

Only takes effect when `run_nginx_snippets_manage` is `true`.

- **Type**: `bool`
- **Required**: No
- **Default**: `false`



### `run_nginx_access_log_default_file_owner`<a id="variable-run_nginx_access_log_default_file_owner"></a>

[*⇑ Back to ToC ⇑*](#toc)

Owner of `/var/log/nginx/access.log`. Defaults to `www-data` on Debian and
Ubuntu, and `nginx` on RHEL-family and SUSE systems.

The role creates the file if missing and preserves existing contents and
timestamps. Attribute changes do not restart NGINX. This option does not
manage per-site logs or logrotate configuration. Align custom values with
any explicit logrotate `create` directive; SUSE's bare global `create`
preserves existing attributes.

- **Type**: `str`
- **Required**: No
- **Default**: `"{{ __run_nginx_access_log_default_file_owner }}"`



### `run_nginx_access_log_default_file_group`<a id="variable-run_nginx_access_log_default_file_group"></a>

[*⇑ Back to ToC ⇑*](#toc)

Group of `/var/log/nginx/access.log`. Defaults to `adm` on Debian and
Ubuntu, `root` on RHEL-family systems, and `nginx` on SUSE.

The role creates the file if missing and preserves existing contents and
timestamps. Attribute changes do not restart NGINX. This option does not
manage per-site logs or logrotate configuration. Align custom values with
any explicit logrotate `create` directive; SUSE's bare global `create`
preserves existing attributes.

- **Type**: `str`
- **Required**: No
- **Default**: `"{{ __run_nginx_access_log_default_file_group }}"`



### `run_nginx_access_log_default_file_mode`<a id="variable-run_nginx_access_log_default_file_mode"></a>

[*⇑ Back to ToC ⇑*](#toc)

Permissions of `/var/log/nginx/access.log`, as a quoted octal or symbolic
mode. Defaults to `u=rw,g=r,o=` (`0640`) on all supported platforms.

The role creates the file if missing and preserves existing contents and
timestamps. Attribute changes do not restart NGINX. This option does not
manage per-site logs or logrotate configuration. Align custom values with
any explicit logrotate `create` directive; SUSE's bare global `create`
preserves existing attributes.

- **Type**: `str`
- **Required**: No
- **Default**: `"{{ __run_nginx_access_log_default_file_mode }}"`



### `run_nginx_error_log_default_file_owner`<a id="variable-run_nginx_error_log_default_file_owner"></a>

[*⇑ Back to ToC ⇑*](#toc)

Owner of `/var/log/nginx/error.log`. Defaults to `www-data` on Debian and
Ubuntu, and `nginx` on RHEL-family and SUSE systems.

The role creates the file if missing and preserves existing contents and
timestamps. Attribute changes do not restart NGINX. This option does not
manage per-site logs or logrotate configuration. Align custom values with
any explicit logrotate `create` directive; SUSE's bare global `create`
preserves existing attributes.

- **Type**: `str`
- **Required**: No
- **Default**: `"{{ __run_nginx_error_log_default_file_owner }}"`



### `run_nginx_error_log_default_file_group`<a id="variable-run_nginx_error_log_default_file_group"></a>

[*⇑ Back to ToC ⇑*](#toc)

Group of `/var/log/nginx/error.log`. Defaults to `adm` on Debian and
Ubuntu, `root` on RHEL-family systems, and `nginx` on SUSE.

The role creates the file if missing and preserves existing contents and
timestamps. Attribute changes do not restart NGINX. This option does not
manage per-site logs or logrotate configuration. Align custom values with
any explicit logrotate `create` directive; SUSE's bare global `create`
preserves existing attributes.

- **Type**: `str`
- **Required**: No
- **Default**: `"{{ __run_nginx_error_log_default_file_group }}"`



### `run_nginx_error_log_default_file_mode`<a id="variable-run_nginx_error_log_default_file_mode"></a>

[*⇑ Back to ToC ⇑*](#toc)

Permissions of `/var/log/nginx/error.log`, as a quoted octal or symbolic
mode. Defaults to `u=rw,g=r,o=` (`0640`) on all supported platforms.

The role creates the file if missing and preserves existing contents and
timestamps. Attribute changes do not restart NGINX. This option does not
manage per-site logs or logrotate configuration. Align custom values with
any explicit logrotate `create` directive; SUSE's bare global `create`
preserves existing attributes.

- **Type**: `str`
- **Required**: No
- **Default**: `"{{ __run_nginx_error_log_default_file_mode }}"`



<!-- ANSIBLE DOCSMITH MAIN END -->

## Dependencies<a id="dependencies"></a>

See `dependencies` in [`meta/main.yml`](./meta/main.yml).



## Compatibility<a id="compatibility"></a>

See `min_ansible_version` in [`meta/main.yml`](./meta/main.yml) and
`__run_nginx_supported_platforms` in [`vars/main.yml`](./vars/main.yml).



## External requirements<a id="requirements"></a>

There are no special requirements not covered by Ansible itself.

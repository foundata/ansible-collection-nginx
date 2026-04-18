# Ansible role: `foundata.nginx.run`

The `foundata.nginx.run` Ansible role (part of the `foundata.nginx` Ansible collection). It provides automated installation, configuration management, and hardening of [NGINX](https://nginx.org/) across major Linux distributions.



## Table of contents<a id="toc"></a>

- [Features](#features)
- [Example playbooks, using this role](#examples)
- [Supported tags](#tags)<!-- ANSIBLE DOCSMITH TOC START -->
- [Role variables](#variables)
  - [`run_nginx_state`](#variable-run_nginx_state)
  - [`run_nginx_autoupgrade`](#variable-run_nginx_autoupgrade)
  - [`run_nginx_service_state`](#variable-run_nginx_service_state)
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
      - [`run_nginx_snippet_settings['tls-baseline']['dhparam_path']`](#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-dhparam_path)
      - [`run_nginx_snippet_settings['tls-baseline']['ecdh_curves']`](#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-ecdh_curves)
      - [`run_nginx_snippet_settings['tls-baseline']['resolvers']`](#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-resolvers)
      - [`run_nginx_snippet_settings['tls-baseline']['resolver_timeout']`](#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-resolver_timeout)
  - [`run_nginx_snippets_delete_unmanaged`](#variable-run_nginx_snippets_delete_unmanaged)
<!-- ANSIBLE DOCSMITH TOC END -->
- [Dependencies](#dependencies)
- [Compatibility](#compatibility)
- [External requirements](#requirements)



## Features<a id="features"></a>

Main features:

* **Site management** via `sites-available/` and `sites-enabled/` with optional cleanup of unmanaged files.
* **Dynamic module management:** enable modules by name, the role installs packages and creates `load_module` configs automatically with cross-platform support.
* Layered configuration merge: production-ready internal defaults (see [`__run_nginx_http_directives_defaults`](./vars/main.yml) for the complete list) and user settings are combined automatically. User-provided values always take precedence.
* **Hardened TLS baseline** following the [Mozilla "Intermediate" TLS profile (Guideline v6.0)](https://ssl-config.mozilla.org/#server=nginx&config=intermediate&hsts=1&ocsp=1&guideline=6.0):
  * Post-quantum key exchange (`X25519MLKEM768`) on platforms with OpenSSL >= 3.5, automatic fallback to classical curves on older platforms.
  * Ships [RFC 7919](https://www.rfc-editor.org/rfc/rfc7919) ffdhe3072 DH parameters; no manual `openssl dhparam` step needed.
  * OCSP stapling, session resumption, and ECDHE-only cipher suites out of the box.
* **Reusable, curated config snippets** for common tasks, ready to `include` in your site configs:
  * `http/tls-baseline.conf` -- TLS/SSL hardening (see above).
  * `server/headers-security.conf` -- security headers (`X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`).
  * `server/headers-hsts.conf` -- [HTTP Strict Transport Security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security) with configurable `max-age`, `includeSubDomains`, and `preload`.
  * `location/cache-static.conf` -- long-lived caching for static assets (`Cache-Control: public, immutable`).
  * `location/php-fpm.conf` -- FastCGI proxy for PHP-FPM (Unix socket or TCP).
* **Hardened catch-all `default_server`** that returns HTTP 444 / rejects unknown TLS handshakes, preventing unintended content exposure for unknown hostnames.



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
                      include snippets/location/cache-static.conf;
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

The following variables can be configured for this role:

| Variable | Type | Required | Default | Description (abstract) |
|----------|------|----------|---------|------------------------|
| `run_nginx_state` | `str` | No | `"present"` | Determines whether the managed resources should be `present` or `absent`.<br><br>`present` ensures that required components, such as software packages, are installed and configured.<br><br>`absent` reverts changes as much as possible, such as […](#variable-run_nginx_state) |
| `run_nginx_autoupgrade` | `bool` | No | `false` | If set to `true`, all managed packages will be upgraded during each Ansible run (e.g., when the package provider detects a newer version than the currently installed one). |
| `run_nginx_service_state` | `str` | No | `"enabled"` | Defines the status of the service(s).<br><br>`enabled`: Service is running and will start automatically at boot.<br><br>`disabled`: Service is stopped and will not start automatically at boot.<br><br>`running` Service is running but will not start […](#variable-run_nginx_service_state) |
| `run_nginx_main_config_block` | `str` | No | `""` | Additional NGINX configuration directives for the main (top-level) context of `nginx.conf`, placed outside of any block such as `events {}` or `http {}`.<br><br>The value is inserted verbatim into the rendered configuration file. Only directives […](#variable-run_nginx_main_config_block) |
| `run_nginx_events_config_block` | `str` | No | `""` | Additional NGINX configuration directives for the `events {}` block in the main configuration file (`nginx.conf`).<br><br>The value is inserted verbatim inside the `events {}` block. Do not include the `events {` and `}` delimiters themselves - only […](#variable-run_nginx_events_config_block) |
| `run_nginx_http_config_block` | `str` | No | `""` | Additional NGINX configuration directives for the `http {}` block in the main configuration file (`nginx.conf`).<br><br>The value is inserted verbatim inside the `http {}` block. Do not include the `http {` and `}` delimiters themselves - only the […](#variable-run_nginx_http_config_block) |
| `run_nginx_main_config_baseline_manage` | `bool` | No | `true` | Controls whether the role injects curated baseline directives into the main (top-level) context of the main configuration file (`nginx.conf`).<br><br>When set to `true`, the role provides sane defaults for the main context (e.g., `worker_processes`, […](#variable-run_nginx_main_config_baseline_manage) |
| `run_nginx_events_config_baseline_manage` | `bool` | No | `true` | Controls whether the role injects curated baseline directives into the `events {}` block of the main configuration file (`nginx.conf`).<br><br>When set to `true`, the role provides sane defaults for the events context (e.g., `worker_connections`). […](#variable-run_nginx_events_config_baseline_manage) |
| `run_nginx_http_config_baseline_manage` | `bool` | No | `true` | Controls whether the role injects curated baseline directives into the `http {}` block of the main configuration file (`nginx.conf`).<br><br>When set to `true`, the role provides sane defaults for the HTTP context (e.g., `sendfile`, `tcp_nopush`, […](#variable-run_nginx_http_config_baseline_manage) |
| `run_nginx_sites_config` | `list` | No | `[]` | List of site definitions (sometimes called vHosts) to manage. Each entry describes a site as a dictionary holding its name, enablement state, and raw NGINX configuration content.<br><br>For each entry, the role renders a config file at […](#variable-run_nginx_sites_config) |
| `run_nginx_sites_delete_unmanaged` | `bool` | No | `true` | Controls whether the role removes stale site files that are not declared in `run_nginx_sites_config`.<br><br>When set to `true`, any `*.conf` file or symlink found in `/etc/nginx/sites-available/` or `/etc/nginx/sites-enabled/` whose name does not […](#variable-run_nginx_sites_delete_unmanaged) |
| `run_nginx_sites_defaultserver_manage` | `bool` | No | `true` | Controls whether the role includes a hardened catch-all `server {}` block in the `http {}` section of the main configuration file (`nginx.conf`).<br><br>When set to `true`, a default server is rendered that listens on ports 80 and 443 with […](#variable-run_nginx_sites_defaultserver_manage) |
| `run_nginx_modules_enabled` | `list` | No | `[]` | List of dynamic NGINX module names to enable at runtime.<br><br>Module names follow the canonical `.so` filename with the `ngx_` prefix and `_module` suffix stripped. The general pattern is `_` (e.g. `http_perl` from `ngx_http_perl_module.so`). See […](#variable-run_nginx_modules_enabled) |
| `run_nginx_modules_disable_unmanaged` | `bool` | No | `true` | Controls whether the role removes dynamic module symlinks that are not declared in `run_nginx_modules_enabled`.<br><br>When set to `true`, any `*.conf` file or symlink found in `/etc/nginx/modules-enabled/` whose name does not match an entry in […](#variable-run_nginx_modules_disable_unmanaged) |
| `run_nginx_snippets_manage` | `bool` | No | `true` | Controls whether the role ships and manages its curated NGINX config snippets (reusable, centrally maintained config blocks meant to be pulled into `server {}` / `location {}` blocks via `include snippets/.conf;`).<br><br>When set to `true`, the role […](#variable-run_nginx_snippets_manage) |
| `run_nginx_snippet_settings` | `dict` | No | `{}` | User-level overrides for the configuration snippets shipped by this role.<br><br>Each top-level key corresponds to a snippet name (e.g. `hsts`, `php-fpm`, `tls-baseline`). Values are dictionaries whose keys map to template variables used when […](#variable-run_nginx_snippet_settings) |
| `run_nginx_snippets_delete_unmanaged` | `bool` | No | `false` | Controls whether the role removes snippet files below `/etc/nginx/snippets/` that are not managed by this role.<br><br>When set to `true`, any files in the snippet subdirectories (`http/`, `server/`, `location/`) that were not rendered by the role's […](#variable-run_nginx_snippets_delete_unmanaged) |

### `run_nginx_state`<a id="variable-run_nginx_state"></a>

[*⇑ Back to ToC ⇑*](#toc)

Determines whether the managed resources should be `present` or `absent`.

`present` ensures that required components, such as software packages, are
installed and configured.

`absent` reverts changes as much as possible, such as removing packages,
deleting created users, stopping services, restoring modified settings, …

- **Type**: `str`
- **Required**: No
- **Default**: `"present"`
- **Choices**: `present`, `absent`



### `run_nginx_autoupgrade`<a id="variable-run_nginx_autoupgrade"></a>

[*⇑ Back to ToC ⇑*](#toc)

If set to `true`, all managed packages will be upgraded during each Ansible
run (e.g., when the package provider detects a newer version than the
currently installed one).

- **Type**: `bool`
- **Required**: No
- **Default**: `false`



### `run_nginx_service_state`<a id="variable-run_nginx_service_state"></a>

[*⇑ Back to ToC ⇑*](#toc)

Defines the status of the service(s).

`enabled`: Service is running and will start automatically at boot.

`disabled`: Service is stopped and will not start automatically at boot.

`running` Service is running but will not start automatically at boot.
This can be used to start a service on the first Ansible run without
enabling it for boot.

`unmanaged`: Service will not start at boot, and Ansible will not manage
its running state. This is primarily useful when services are monitored
and managed by systems other than Ansible.

The singular form (`service`) is used for simplicity. However, the defined
status applies to all services if multiple are being managed by this role.

- **Type**: `str`
- **Required**: No
- **Default**: `"enabled"`
- **Choices**: `enabled`, `disabled`, `running`, `unmanaged`



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
`run_nginx_sites_config`.

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
https://hstspreload.org/.

- **Type**: `int`
- **Required**: No
- **Default**: `31536000`

##### `run_nginx_snippet_settings['hsts']['include_subdomains']`<a id="variable-run_nginx_snippet_settings-sub-hsts-sub-include_subdomains"></a>

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

##### `run_nginx_snippet_settings['tls-baseline']['dhparam_path']`<a id="variable-run_nginx_snippet_settings-sub-tls-baseline-sub-dhparam_path"></a>

[*⇑ Back to ToC ⇑*](#toc)

Absolute path where the DH parameters file is deployed. The
role ships RFC 7919 ffdhe3072 parameters and deploys them to
this path automatically. Platform-specific vars files override
this to match each distribution's conventional TLS directory
(e.g. `/etc/pki/tls/certs/` on Red Hat).

- **Type**: `str`
- **Required**: No
- **Default**: `"/etc/ssl/certs/dhparam_ffdhe3072.pem"`

##### `run_nginx_snippet_settings['tls-baseline']['ecdh_curves']`<a id="variable-run_nginx_snippet_settings-sub-tls-baseline-sub-ecdh_curves"></a>

[*⇑ Back to ToC ⇑*](#toc)

Colon-separated list of elliptic curves for ECDHE key exchange,
passed to the `ssl_ecdh_curve` directive. The default includes
the post-quantum hybrid `X25519MLKEM768` (requires OpenSSL >= 3.5);
platforms with older OpenSSL automatically fall back to a
classical-only list via version-specific vars files.

- **Type**: `str`
- **Required**: No
- **Default**: `"X25519MLKEM768:X25519:prime256v1:secp384r1"`

##### `run_nginx_snippet_settings['tls-baseline']['resolvers']`<a id="variable-run_nginx_snippet_settings-sub-tls-baseline-sub-resolvers"></a>

[*⇑ Back to ToC ⇑*](#toc)

List of DNS resolver IP addresses used by NGINX for OCSP
stapling lookups. Using a local resolver (e.g. unbound,
systemd-resolved at `127.0.0.1`) is recommended for privacy
and latency.

- **Type**: `list`
- **Required**: No
- **List Elements**: `str`

##### `run_nginx_snippet_settings['tls-baseline']['resolver_timeout']`<a id="variable-run_nginx_snippet_settings-sub-tls-baseline-sub-resolver_timeout"></a>

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




<!-- ANSIBLE DOCSMITH MAIN END -->

## Dependencies<a id="dependencies"></a>

See `dependencies` in [`meta/main.yml`](./meta/main.yml).



## Compatibility<a id="compatibility"></a>

See `min_ansible_version` in [`meta/main.yml`](./meta/main.yml) and `__run_nginx_supported_platforms` in [`vars/main.yml`](./vars/main.yml).



## External requirements<a id="requirements"></a>

There are no special requirements not covered by Ansible itself.

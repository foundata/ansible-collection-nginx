# Ansible collection: `foundata.nginx`

This repository contains the `foundata.nginx` Ansible Collection.

It provides resources to manage and use [NGINX](https://nginx.org/), a HTTP web server, reverse proxy, cache, and load balancer.


<div align="center" id="project-readme-header">
<br>
<br>

**⭐ Found this useful? Support open-source and star this project:**

[![GitHub repository](https://img.shields.io/github/stars/foundata/ansible-collection-nginx.svg)](https://github.com/foundata/ansible-collection-nginx)

<br>
</div>



## Table of contents<a id="toc"></a>

- [Included content](#content)
- [Dependencies](#dependencies)
- [Licensing, copyright](#licensing-copyright)
- [Author information](#author-information)



## Included content<a id="content"></a>

### Role: `foundata.nginx.run`

The primary role in this collection to configure and maintain NGINX, including sites / virtual hosts (`server {}`) and related configuration. [Its `README.md`](./roles/run/README.md) covers configuration, usage examples, and more:

<!-- ANSIBLE DOCSMITH TOC-FULL run START -->
- [Ansible role: `foundata.nginx.run`](roles/run/README.md#ansible-role-foundatanginxrun)
  - [Table of contents](roles/run/README.md#toc)
  - [Features](roles/run/README.md#features)
  - [Example playbooks, using this role](roles/run/README.md#examples)
  - [Supported tags](roles/run/README.md#tags)
  - [Role variables](roles/run/README.md#variables)
    - [`run_nginx_state`](roles/run/README.md#variable-run_nginx_state)
    - [`run_nginx_autoupgrade`](roles/run/README.md#variable-run_nginx_autoupgrade)
    - [`run_nginx_service_state`](roles/run/README.md#variable-run_nginx_service_state)
    - [`run_nginx_main_config_block`](roles/run/README.md#variable-run_nginx_main_config_block)
    - [`run_nginx_events_config_block`](roles/run/README.md#variable-run_nginx_events_config_block)
    - [`run_nginx_http_config_block`](roles/run/README.md#variable-run_nginx_http_config_block)
    - [`run_nginx_main_config_baseline_manage`](roles/run/README.md#variable-run_nginx_main_config_baseline_manage)
    - [`run_nginx_events_config_baseline_manage`](roles/run/README.md#variable-run_nginx_events_config_baseline_manage)
    - [`run_nginx_http_config_baseline_manage`](roles/run/README.md#variable-run_nginx_http_config_baseline_manage)
    - [`run_nginx_sites_config`](roles/run/README.md#variable-run_nginx_sites_config)
      - [`run_nginx_sites_config['name']`](roles/run/README.md#variable-run_nginx_sites_config-sub-name)
      - [`run_nginx_sites_config['enabled']`](roles/run/README.md#variable-run_nginx_sites_config-sub-enabled)
      - [`run_nginx_sites_config['content']`](roles/run/README.md#variable-run_nginx_sites_config-sub-content)
    - [`run_nginx_sites_delete_unmanaged`](roles/run/README.md#variable-run_nginx_sites_delete_unmanaged)
    - [`run_nginx_sites_defaultserver_manage`](roles/run/README.md#variable-run_nginx_sites_defaultserver_manage)
    - [`run_nginx_modules_enabled`](roles/run/README.md#variable-run_nginx_modules_enabled)
    - [`run_nginx_modules_disable_unmanaged`](roles/run/README.md#variable-run_nginx_modules_disable_unmanaged)
    - [`run_nginx_snippets_manage`](roles/run/README.md#variable-run_nginx_snippets_manage)
    - [`run_nginx_snippet_settings`](roles/run/README.md#variable-run_nginx_snippet_settings)
      - [`run_nginx_snippet_settings['hsts']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-hsts)
        - [`run_nginx_snippet_settings['hsts']['max_age']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-hsts-sub-max_age)
        - [`run_nginx_snippet_settings['hsts']['include_subdomains']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-hsts-sub-include_subdomains)
        - [`run_nginx_snippet_settings['hsts']['preload']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-hsts-sub-preload)
      - [`run_nginx_snippet_settings['php-fpm']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-php-fpm)
        - [`run_nginx_snippet_settings['php-fpm']['type']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-php-fpm-sub-type)
        - [`run_nginx_snippet_settings['php-fpm']['socket']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-php-fpm-sub-socket)
        - [`run_nginx_snippet_settings['php-fpm']['tcp_host']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-php-fpm-sub-tcp_host)
        - [`run_nginx_snippet_settings['php-fpm']['tcp_port']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-php-fpm-sub-tcp_port)
      - [`run_nginx_snippet_settings['tls-baseline']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-tls-baseline)
        - [`run_nginx_snippet_settings['tls-baseline']['dhparam_path']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-dhparam_path)
        - [`run_nginx_snippet_settings['tls-baseline']['ecdh_curves']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-ecdh_curves)
        - [`run_nginx_snippet_settings['tls-baseline']['resolvers']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-resolvers)
        - [`run_nginx_snippet_settings['tls-baseline']['resolver_timeout']`](roles/run/README.md#variable-run_nginx_snippet_settings-sub-tls-baseline-sub-resolver_timeout)
    - [`run_nginx_snippets_delete_unmanaged`](roles/run/README.md#variable-run_nginx_snippets_delete_unmanaged)
  - [Dependencies](roles/run/README.md#dependencies)
  - [Compatibility](roles/run/README.md#compatibility)
  - [External requirements](roles/run/README.md#requirements)
<!-- ANSIBLE DOCSMITH TOC-FULL run END -->



## Dependencies<a id="dependencies"></a>

See `dependencies` in [`galaxy.yml`](./galaxy.yml).



## Licensing, copyright<a id="licensing-copyright"></a>

<!--REUSE-IgnoreStart-->
Copyright (c) 2026 foundata GmbH

This project is licensed under the GNU General Public License v3.0 or later (SPDX-License-Identifier: `GPL-3.0-or-later`), see [`LICENSES/GPL-3.0-or-later.txt`](LICENSES/GPL-3.0-or-later.txt) for the full text.

The [`REUSE.toml`](REUSE.toml) file provides detailed licensing and copyright information in a human- and machine-readable format. This includes parts that may be subject to different licensing or usage terms, such as third-party components. The repository conforms to the [REUSE specification](https://reuse.software/spec/). You can use [`reuse spdx`](https://reuse.readthedocs.io/en/latest/readme.html#cli) to create a [SPDX software bill of materials (SBOM)](https://en.wikipedia.org/wiki/Software_Package_Data_Exchange).
<!--REUSE-IgnoreEnd-->

[![REUSE status](https://api.reuse.software/badge/github.com/foundata/ansible-collection-nginx)](https://api.reuse.software/info/github.com/foundata/ansible-collection-nginx)



## Author information<a id="author-information"></a>

This project was created and is maintained by foundata GmbH.

Initially based on an [Ansible skeleton](https://foundata.com/en/projects/ansible-skeletons/) developed by [foundata](https://foundata.com/).

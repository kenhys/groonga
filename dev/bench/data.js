window.BENCHMARK_DATA = {
  "lastUpdate": 1777720594013,
  "repoUrl": "https://github.com/kenhys/groonga",
  "entries": {
    "Benchmark": [
      {
        "commit": {
          "author": {
            "email": "kenhys@gmail.com",
            "name": "Kentaro Hayashi",
            "username": "kenhys"
          },
          "committer": {
            "email": "kenhys@gmail.com",
            "name": "Kentaro Hayashi",
            "username": "kenhys"
          },
          "distinct": true,
          "id": "4a1f719edd70d0761d9ffb7bad6945fac83a7897",
          "message": "tools: do not install under tools/tools/\n\ntools directory was copied into tools, so\nscripts were placed under tools/tools/.\n\nBefore: /usr/share/groonga/tools/tools/*.rb\nAfter: /usr/share/groonga/tools/*.rb\nSigned-off-by: Kentaro Hayashi <kenhys@gmail.com>",
          "timestamp": "2026-05-02T19:40:36+09:00",
          "tree_id": "89519d05cdfd65d56c3aaa9ebb2cbca89a16c58f",
          "url": "https://github.com/kenhys/groonga/commit/4a1f719edd70d0761d9ffb7bad6945fac83a7897"
        },
        "date": 1777720593103,
        "tool": "googlecpp",
        "benches": [
          {
            "name": "stdio: json|json: load/data/multiple",
            "value": 0.3727879730001291,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.014419999999999877 s\nthreads: undefined"
          },
          {
            "name": "stdio: json|json: load/data/short_text",
            "value": 0.2888473680000061,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.012717999999999813 s\nthreads: undefined"
          },
          {
            "name": "stdio: json|json: select/olap/multiple",
            "value": 0.015577287999974487,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.0003619999999997514 s\nthreads: undefined"
          },
          {
            "name": "stdio: json|json: select/olap/n_workers/multiple",
            "value": 0.015350729999966006,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.00034899999999996045 s\nthreads: undefined"
          },
          {
            "name": "stdio: json|json: wal_recover/db/auto_recovery/column/index",
            "value": 1.554054487999963,
            "unit": "s/iter",
            "extra": "iterations: 1\ncpu: 0.00034999999999996145 s\nthreads: undefined"
          },
          {
            "name": "http: json|json: load/data/multiple",
            "value": 0.22937625299994124,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.006681999999999841 s\nthreads: undefined"
          },
          {
            "name": "http: json|json: load/data/short_text",
            "value": 0.14997950499997614,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.007098999999999481 s\nthreads: undefined"
          },
          {
            "name": "http: json|json: select/olap/multiple",
            "value": 0.01612180500001159,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.0015340000000002296 s\nthreads: undefined"
          },
          {
            "name": "http: json|json: select/olap/n_workers/multiple",
            "value": 0.01698522999998886,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.0016699999999996162 s\nthreads: undefined"
          },
          {
            "name": "http: apache-arrow|apache-arrow: load/data/multiple",
            "value": 0.062016684000070654,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.007137000000000032 s\nthreads: undefined"
          },
          {
            "name": "http: apache-arrow|apache-arrow: load/data/short_text",
            "value": 0.06598302099996545,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.007871999999999768 s\nthreads: undefined"
          },
          {
            "name": "http: apache-arrow|apache-arrow: select/olap/multiple",
            "value": 0.02054592799999,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.005597999999999409 s\nthreads: undefined"
          },
          {
            "name": "http: apache-arrow|apache-arrow: select/olap/n_workers/multiple",
            "value": 0.01699562500010643,
            "unit": "s/iter",
            "extra": "iterations: 5\ncpu: 0.0016419999999994772 s\nthreads: undefined"
          }
        ]
      }
    ]
  }
}
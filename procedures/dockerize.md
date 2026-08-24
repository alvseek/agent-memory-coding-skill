# Dockerize

Decide a project's containerization, place the files where they belong, and emit ready-to-use artifacts — a `Dockerfile` per deployable unit, a `.dockerignore` beside each, and one Compose file at the units' common ancestor.

Scope is **judgment, placement, and emission** — not template lookup. Generators already exist (`docker init`, Nixpacks, Cloud Native Buildpacks) and all of them assume *one stateless web app at the repo root*. This skill exists for the three cases they assume away: **multi-unit repositories**, **services that hold state in a file**, and **services with no port at all**. Everything downstream of those decisions is mechanical.

> **The output is consumed by `/setup-ci-cd`**, which reads the emitted artifacts to build the release pipeline. This skill stops at "the image builds and runs and its data survives recreation." It does not deploy.

> **Stack-agnostic and runner-agnostic by construction.** Detection reads *lockfiles and entrypoints*, never file extensions or a hardcoded language table — a table would need Python, Node, Go, Rust, Java and .NET on day one and would rot by day thirty. Nothing here depends on which assistant executes it.

## Arguments

`$ARGUMENTS`

- `/dockerize` → **Default.** Survey the repository, report the units found and the decisions each needs, then emit for all of them.
- `/dockerize [unit]` → Target one deployable unit by path or name (e.g. `application/bridge`).
- `/dockerize --survey` → Phases 0–1 only. Report the survey and the decision table; write nothing.
- `/dockerize --verify` → Phase 4 only, against artifacts that already exist.

If the repository contains more than one unit and no argument is given, list them and confirm the set before writing anything.

---

## Procedure

*Five stages, in order: **SURVEY → DECIDE → PLACE → EMIT → VERIFY**. Each phase ends at a gate. A gate that cannot be answered from evidence is a STOP, not a default — the failure this skill exists to prevent is a container that builds cleanly, starts cleanly, and silently loses data on its second deploy.*

---

## Phase 0: SURVEY

*Goal: learn what is actually in this repository. Every finding must cite the file that produced it. An unevidenced answer is a question for the user, never a guess.*

### Step 1: Find the deployable units

A **unit** is one thing that becomes one image. Do not assume the repository is one unit.

Evidence to gather, in order of authority:

| Signal | What it means |
|---|---|
| Multiple dependency manifests in different directories | One unit per manifest |
| `.gitmodules` | A submodule is a **separate repository** — see the placement rule in Phase 2 |
| Workspace configs (`pnpm-workspace.yaml`, `[tool.uv.workspace]`, `go.work`, Cargo workspace) | Members may be units or libraries — only those with an entrypoint are units |
| Existing `deploy/*.service` or similar unit files | **Authoritative.** One service unit ≈ one deployable unit |

> **Existing service definitions outrank inference.** If the project already ships systemd units, their `ExecStart`, `WorkingDirectory` and `Environment` lines are a *statement* of how this software starts in production. Read them before deducing anything.

### Step 2: Identify each unit's stack

Read the **lockfile**, not the source. The lockfile names the package manager, and the package manager determines the build stage:

`uv.lock` → uv · `poetry.lock` → Poetry · `requirements.txt` → pip · `pnpm-lock.yaml` → pnpm · `package-lock.json` → npm · `yarn.lock` → Yarn · `go.mod` → Go modules · `Cargo.lock` → Cargo · `pom.xml` / `build.gradle` → Maven / Gradle · `*.csproj` → .NET

Record the runtime version from the manifest's own constraint (`requires-python`, `engines`, `go` directive, `rust-version`, `<TargetFramework>`), never from what happens to be installed.

### Step 3: Determine each unit's shape

Three shapes, and they need different Dockerfiles:

- **Inbound-serving** — binds a port and accepts connections. Evidence: `uvicorn` / `gunicorn` / `.listen(` / `http.Server` / `app.Run(`.
- **Outbound-worker** — runs continuously, never accepts a connection. Evidence: polling loops, queue consumers, schedulers. **No port. No HTTP health check.**
- **One-shot** — runs to completion and exits. Evidence: migration runners, importers, batch jobs.

> Shape is where every generic tool fails. All of them emit `EXPOSE` and an HTTP `HEALTHCHECK` unconditionally. An outbound-worker given both is a container that reports unhealthy forever.

### Step 4: Determine each unit's state

Ask one question per unit: **what does this write that must survive the container being replaced?**

Evidence: database file paths in config, data or upload directories, cache directories that are expensive to rebuild, anything the project's own `.gitignore` excludes as runtime data.

Classify each as **stateless**, **file-state** (a database file or data directory on local disk), or **service-state** (a networked database, which is its own unit or an external dependency).

### Step 5: Determine each unit's configuration surface

Enumerate every environment variable the unit reads (`os.getenv`, `process.env`, `os.Getenv`, config loaders) and split them into **settings** (safe to bake as defaults) and **secrets** (must never enter an image layer). An existing `.env.example` is a strong starting point but is often stale — confirm against the code.

### ⛔ END OF PHASE 0

Emit the survey table before deciding anything:

```
| Unit | Path | Stack | Shape | State | Secrets |
|------|------|-------|-------|-------|---------|
```

Any cell you could not fill from evidence is a question for the user. Do not proceed with a guess in the table.

---

## Phase 1: DECIDE

*Goal: turn the survey into decisions. Three of these are gates.*

### Step 6: Choose the base image per unit

Decide runtime image and build strategy from the stack and shape. Prefer a multi-stage build in every case: a build stage carrying toolchains, a runtime stage carrying only what runs.

Pin to a specific minor version and a specific distribution — never a floating `latest`. Compiled languages that produce a static binary should target `scratch` or `alpine`; interpreted languages should target the slim variant of their official image unless a native dependency forbids it.

### Step 7: ⛔ THE STATE GATE

**For every unit classified `file-state`, all four of these must hold, or STOP:**

1. The state lives on a **named volume**, never inside the container filesystem and never an anonymous volume.
2. The volume mounts the **containing directory**, never the individual file. A file database keeps sidecars beside it — SQLite's WAL mode writes `-wal` and `-shm` next to the `.db`, and mounting only the `.db` strands them in the container, where they are destroyed on recreation along with whatever they had not yet checkpointed.
3. The volume is **local**. POSIX advisory locking is not reliable over NFS or CIFS, so a network volume driver under a file database is a corruption path, not a portability win.
4. Exactly **one writer**. Two containers sharing one file database is corruption, not scaling — regardless of one being mounted read-only.

> This gate exists because it is the only failure on the list that is invisible. Every other mistake produces a build error or a container that will not start. This one produces a container that runs perfectly and loses the data on the next deploy.

### Step 8: ⛔ THE SECRET GATE

No secret may enter the image. `ENV` and `ARG` both persist into image layers and are readable by anyone who pulls it. Secrets arrive at **runtime** — via the orchestrator's environment, a mounted file, or `--mount=type=secret` for build-time credentials.

If a survey step found a secret already committed to the repository, say so plainly and stop. Containerizing around a leaked credential propagates it.

### Step 9: ⛔ THE NON-ROOT GATE

Every unit runs as a non-root user created in the Dockerfile. If a unit appears to require root, name the specific capability it needs and grant that instead.

### Step 10: Decide the health check per shape

**Inbound-serving** → `HEALTHCHECK` against the unit's own health endpoint, using a tool present in the runtime image. **Outbound-worker** → a liveness check on the process's own signal of progress, or no `HEALTHCHECK` at all — an honest absence beats a check that always fails. **One-shot** → none; exit status is the result.

### ⛔ END OF PHASE 1

Emit the decision table and confirm it before writing files. Every gate must read `PASS` with its evidence, or the run stops here.

---

## Phase 2: PLACE

*Goal: decide where each artifact belongs. This is the step no existing tool performs, and getting it wrong is what makes multi-unit repositories unmanageable.*

### Step 11: Apply the placement rules

1. **A `Dockerfile` sits beside the manifest it builds.** One unit at the repository root means a root `Dockerfile`; three units in three directories means three Dockerfiles, each next to its own lockfile.
2. **A `.dockerignore` sits beside each `Dockerfile`.** Docker resolves it relative to the build context, so one at the root does not cover a nested context. Every one of them excludes `.git`, `.env`, the state directory, local virtual environments, and build caches.
3. **The Compose file sits at the lowest common ancestor of the units it orchestrates.** A file that interconnects units belongs at the nearest existing ancestor of everything it touches — the same rule the documentation placement contract applies to cross-cutting docs, for the same reason.
4. **⛔ Never write inside a git submodule.** A submodule is a different repository with a different owner and a different lifecycle. Its Dockerfile belongs to it. From the parent, reference the built image or build with the submodule as context — and if the submodule needs a Dockerfile it does not have, that is a hand-off to whoever owns it, not an edit.

### ⛔ END OF PHASE 2

List every path to be written or modified, and confirm before the first write.

---

## Phase 3: EMIT

*Goal: write artifacts a person can read and a machine can build. Generated output nobody understands is worse than no output.*

### Step 12: Write the Dockerfiles

One per unit, following its decisions and satisfying every invariant in [The invariants](#the-invariants) below. If the unit's stack has no worked example here, derive the build stage with the four questions in [Deriving a build stage for an unseen stack](#deriving-a-build-stage-for-an-unseen-stack) — never by copying a template for a different package manager.

### Step 13: Write the `.dockerignore` files

### Step 14: Write the Compose file

Declare every named volume explicitly. Bind published ports to loopback where a reverse proxy fronts the service, so a development port is not silently exposed on every interface. Set resource limits and log rotation for anything intended to run unattended.

### Step 15: Write `.env.example`

Every variable found in Step 5, with placeholder values only, and a comment naming which are secrets.

### ⛔ END OF PHASE 3

---

## Phase 4: VERIFY

*Goal: prove it, rather than declare it. A build that succeeds proves the syntax and nothing about the decisions.*

### Step 16: Build each image

### Step 17: Run each unit and confirm its shape

Inbound-serving: reach the health endpoint from outside the container. Outbound-worker: confirm from its own logs that it is doing its work — not merely that the container is `running`. A container status is the supervisor's opinion; the log is the evidence.

### Step 18: ⛔ PROVE THE STATE SURVIVES

For every `file-state` unit, in this order:

1. Write a recognisable record through the running service.
2. `docker compose down` — remove the container, keeping volumes.
3. `docker compose up` — recreate it.
4. Read the record back.

**If the record is gone, the state gate was answered wrongly and the artifacts are not fit to deploy.** This is the only step that distinguishes a correct volume decision from a plausible one, and it takes under a minute.

### Step 19: Completion report

```
DOCKERIZE COMPLETE — {project}

Units:        {n} ({names})
Written:      {paths}
Gates:        state PASS/N-A · secrets PASS · non-root PASS
Verified:     build PASS · run PASS · state-survives PASS/N-A
Deferred:     {anything not done, and why}
```

Never report a gate as passed without the command output that proved it. A gate reported from intention rather than evidence is the failure this whole procedure is built to prevent.

---

## Templates

*This section holds **rules first, examples second**, and deliberately contains no per-language catalogue. A catalogue would need Python, Node, Go, Rust, Java and .NET on day one and would be wrong about one of them within a year — the same reason detection reads lockfiles instead of a language table. What follows is the set of properties every emitted Dockerfile must have, a recipe for deriving a build stage for a stack nobody has written down yet, and full examples only for the three shapes that public prior art does not cover.*

### The invariants

Every Dockerfile this skill emits satisfies all ten, whatever the stack:

1. `# syntax=docker/dockerfile:1` as the first line.
2. **Multi-stage**: the build stage carries toolchains, the runtime stage carries only what runs.
3. **Dependencies installed before source is copied**, so the dependency layer survives code edits.
4. **A cache mount on the install step**, targeting the package manager's own cache directory.
5. **Base images pinned** to a specific minor version and distribution. Never `latest`.
6. **A non-root user created in the Dockerfile**, with `USER` set before the entrypoint.
7. **An explicit `WORKDIR`** — never inherit the base image's default.
8. **Exec-form `ENTRYPOINT`** (JSON array), so signals reach the process instead of a shell.
9. **No secret** in `ENV`, in `ARG`, or in any copied file. Build-time credentials use `--mount=type=secret`.
10. **`EXPOSE` and `HEALTHCHECK` appear only if the unit's shape warrants them** — see Step 3.

### Deriving a build stage for an unseen stack

Four questions. They hold for a stack released next year as well as for one released twenty years ago:

1. **What command installs this lockfile's dependencies reproducibly?** The locked variant, not the loose one — `uv sync --locked`, `npm ci`, `poetry install --sync`, `cargo build --locked`. A build that resolves versions at build time is not reproducible, whatever the lockfile says.
2. **Where does that tool cache?** That path is the cache mount's target. Getting it wrong costs a full re-download on every build and produces no error.
3. **What must exist at runtime — an interpreter plus source, or a self-contained binary?** This decides whether the runtime stage needs any toolchain at all. Compiled languages usually need none, which is why they can target `scratch`.
4. **What is the smallest official image that can run that?** Slim variants first; drop to `alpine` or `scratch` only when nothing needs glibc or a shell.

If any of the four cannot be answered from the project's own files, it is a question for the user — not a default.

### The skeleton

Slots, not a stack. Every Dockerfile this skill emits is this shape with the angle brackets filled in from the four questions:

```dockerfile
# syntax=docker/dockerfile:1

# ---- Build Stage ----
FROM <build-base>:<pinned-version> AS build
WORKDIR /src

# Dependencies before source, so this layer survives code edits.
COPY <lockfile> <manifest> ./
RUN --mount=type=cache,target=<package-manager-cache-dir> \
    <reproducible-install-command>

COPY . .
RUN <build-command-if-the-stack-has-one>

# ---- Runtime Stage ----
FROM <runtime-base>:<pinned-version> AS runtime
WORKDIR /app
RUN <create-non-root-user>
COPY --from=build --chown=<user> <what-must-exist-at-runtime> .
USER <user>

# ---- Shape-specific ending follows. Do not assume a port. ----
```

### The four questions, answered for three unlike stacks

*Three rather than one, and deliberately unlike each other — one worked example teaches the example, three unlike ones teach the recipe. If the pattern holds across an interpreted stack that installs into an environment, an interpreted stack that vendors its modules, and a compiled stack that produces a standalone binary, it will hold for the next stack too.*

| | interpreted, env-installed | interpreted, vendored modules | compiled, static |
|---|---|---|---|
| **Q3** · needed at runtime | interpreter + installed environment + source | runtime + vendored modules + source | the binary, nothing else |
| **Q4** · smallest runtime base | official slim image | official slim image | `scratch` |
| resulting runtime stage | copy the environment *and* the source | copy the modules *and* the source | copy one file |

**Only Q3 changes the Dockerfile's shape**, which is why the table shows it and not the rest. A stack whose answer is "the binary, nothing else" needs no toolchain in the runtime stage at all — that is what lets it target `scratch`, and what makes its runtime stage a single `COPY`. Q1 and Q2 vary too, but they only change which strings land in the slots, and the recipe above already defines them.

> **Stack-specific detail belongs in the project's own knowledge, not here.** When a package manager needs a particular flag to avoid nesting an environment inside the image, or an image needs a system library for a native dependency, that is a fact about *that project* — recording it in this procedure would rebuild, one entry at a time, the language table this section exists to avoid.

### Outbound-worker ending — no port, no HTTP health check

```dockerfile
# No EXPOSE: this unit never accepts an inbound connection.
# No HEALTHCHECK: an HTTP probe against a process that serves nothing
# reports unhealthy forever. An honest absence beats a check that always fails.
ENTRYPOINT ["<executable>", "<arg>", "..."]
```

### Inbound-serving ending

```dockerfile
EXPOSE <port>
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD <probe-command> || exit 1
ENTRYPOINT ["<executable>", "<arg>", "..."]
```

> The probe must use a tool that exists in the **runtime** image, not the build image. `curl` is absent from most slim images and from all distroless ones, and a `HEALTHCHECK` invoking a missing binary reports unhealthy forever — the same failure as giving a worker an HTTP check, reached from the other direction.

### File-state Compose fragment — the directory, not the file

```yaml
services:
  <unit>:
    build: <unit-context>
    # Loopback only, where a reverse proxy on the host is the public face.
    # Omit entirely for an outbound-worker.
    ports:
      - "127.0.0.1:<port>:<port>"
    volumes:
      # The DIRECTORY, never the file. A file database keeps sidecars beside
      # it — mounting only the database strands them in the container, where
      # they die on recreation along with anything not yet checkpointed.
      - type: volume
        source: <unit>-data
        target: <state-directory>
    environment:
      <STATE_PATH_VAR>: <state-directory>/<database-file>
    restart: unless-stopped
    logging:
      driver: json-file
      options: { max-size: "10m", max-file: "3" }

volumes:
  <unit>-data:       # named, never anonymous — anonymous dies with the container
    driver: local    # local only — POSIX locking is unreliable over NFS/CIFS
```

### Backing up a file-state volume

A file database must be backed up through its own online-backup API, never by copying or archiving the volume while the service is running. An archive of a live write-ahead-logged database is a torn snapshot that restores without complaint and fails later — the same defect as copying the file, at a different layer.

---

## Attribution

*This procedure is self-contained. It carries no runtime dependency on any external repository, and nothing here requires fetching content at execution time.*

Several invariants were confirmed against [Impertio-Studio/Docker-Claude-Skill-Package](https://github.com/Impertio-Studio/Docker-Claude-Skill-Package) (MIT) during design — its anti-pattern catalogue and storage warnings are good, and reading them is worthwhile if you are extending this skill. That package is **design influence, not a dependency**: no step above instructs anyone to fetch it, and this procedure works unchanged if it disappears.

The multi-unit placement rules, the shape taxonomy, the file-state gate, and the state-survives verification are original — the prior art surveyed covered none of them, and none of it mentions file databases, `uv`, or services without a port.

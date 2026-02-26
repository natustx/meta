#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

# Pull latest if this is an update
if [ -d .git ]; then
    if git remote get-url upstream &>/dev/null; then
        _BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
        [ -z "$_BRANCH" ] && _BRANCH="main"
        git fetch origin && git reset --hard "origin/$_BRANCH"
    else
        git pull --ff-only 2>/dev/null || true
    fi
fi

# Clean stale build artifacts
rm -f ~/prj/util/bin/meta ~/prj/util/bin/meta-git ~/prj/util/bin/meta-project ~/prj/util/bin/meta-rust ~/prj/util/bin/meta-mcp ~/prj/util/bin/loop
cargo clean

# Build all workspace binaries in release mode
cargo build --release

# Install binaries
mkdir -p ~/prj/util/bin
cp target/release/meta ~/prj/util/bin/meta
cp target/release/meta-git ~/prj/util/bin/meta-git
cp target/release/meta-project ~/prj/util/bin/meta-project
cp target/release/meta-rust ~/prj/util/bin/meta-rust
cp target/release/meta-mcp ~/prj/util/bin/meta-mcp
cp target/release/loop ~/prj/util/bin/loop
chmod +x ~/prj/util/bin/meta ~/prj/util/bin/meta-git ~/prj/util/bin/meta-project ~/prj/util/bin/meta-rust ~/prj/util/bin/meta-mcp ~/prj/util/bin/loop

# Also install plugins to ~/.meta/plugins/ for meta's plugin discovery
mkdir -p ~/.meta/plugins
cp target/release/meta-git ~/.meta/plugins/meta-git
cp target/release/meta-project ~/.meta/plugins/meta-project
cp target/release/meta-rust ~/.meta/plugins/meta-rust

echo "Installed: $(~/prj/util/bin/meta --version 2>/dev/null || echo 'meta')"

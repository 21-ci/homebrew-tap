# 21-ci Homebrew tap

Homebrew formulae for the [21 Cloud Functions Runtime](https://github.com/21-ci/runtime):

| Formula | Installs |
|---|---|
| `rt` | the runtime node, with a `brew services` definition (launchd on macOS, systemd on Linux) |
| `twentyone-ci` (alias `21ci`) | the `21ci` command line client |

```bash
brew install 21-ci/tap/rt 21-ci/tap/21ci
```

```bash
brew services start rt
```

`rt` listens on loopback only. Its config, root token and master key are in `$(brew --prefix)/etc/rt/`:

```bash
export RT_ROOT_TOKEN=$(cat "$(brew --prefix)/etc/rt/root-token")
```

Upgrade with `brew update && brew upgrade rt 21ci`.

## How this repository is updated

Do not edit the formulae here: every stable release of
[21-ci/runtime](https://github.com/21-ci/runtime/releases) renders `Formula/rt.rb`, `Formula/twentyone-ci.rb` and
`Aliases/21ci` from the templates in
[`packaging/homebrew/`](https://github.com/21-ci/runtime/tree/main/packaging/homebrew) with that release's checksums,
and pushes them here ([RELEASING.md](https://github.com/21-ci/runtime/blob/main/RELEASING.md)). A change goes into
those templates and ships with the next release.

Report problems at [21-ci/runtime/issues](https://github.com/21-ci/runtime/issues).

The formula of `21ci` is named `twentyone-ci` because Homebrew formula names cannot start with a digit; the
`Aliases/21ci` link makes `brew install 21-ci/tap/21ci` work.

## License

The formulae are Apache-2.0, like the runtime.

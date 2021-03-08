# uiprompt

Object-oriented library for UI prompts in RedM.

## installing

1. Create a folder called `uiprompts` in your resources directory.
2. Copy `fxmanifest.lua` and `uiprompt.lua` to this folder.
3. Add `start uiprompt` to `server.cfg`.

## using

In any resources where you want to use this library, add `@uiprompt/uiprompt.lua` as a client script in `fxmanifest.lua`:

```lua
fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

client_scripts {
  "@uiprompt/uiprompt.lua",
  "client.lua"
}
```

Documentation and code examples are provided here: https://kibook.github.io/redm-uiprompt

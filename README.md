# LibXistWOW

## Bootstrapping for use by other Addons

To use LibXistWOW in other addons, you just need to list it in your TOC as a dependency.

**YourAddon.toc**
```toc
## Dependencies: LibXistWOW
```

Then just make sure you have the LibXistWOW addon installed on your machine and other
addons will be able to use the public API.

## Dev environment setup

To set up your dev environment and publish this addon either to your local WOW client
or to CurseForge, you need the submodules.

### LibStub

```bash
git submodule add https://github.com/x1s7/LibStub Libs/LibStub
```

### StdUi

```bash
git submodule add https://github.com/x1s7/StdUi Libs/StdUi
```

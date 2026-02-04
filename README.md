# autonix

Automatically set up a system using Nix.

1. Sign into the App Store
2. Install [Xcode](https://apps.apple.com/en/app/xcode/id497799835) from the App Store
3. Run:

   ```sh
   /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/epiccoolguy/autonix/HEAD/install.sh)"
   ```

   In case you are behind a corporate VPN that intercepts all TLS traffic with a man-in-the-middle attack:

   ```sh
   /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/epiccoolguy/autonix/HEAD/install.sh)" --ca-bundle
   ```

Update using the following command:

```sh
nix flake update
switch
```

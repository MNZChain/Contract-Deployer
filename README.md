## Getting Started

Deploy and interact with various utility contracts for Mainnetz using Thirdweb Deploy.

```bash
npx thirdweb create --contract --template hardhat-javascript-starter
```

To add functionality to your contracts, you can use the `@thirdweb-dev/contracts` package which provides base contracts and extensions to inherit. The package is already installed with this project, or the similar `@openzeppelin/contracts` package.

## Building the project

After any changes to the contracts, run:

```bash
npm run build
# or
yarn build
```

to compile your contracts. This will also detect the [Contracts Extensions Docs](https://portal.thirdweb.com/contractkit) detected on your contract.

## Deploying Contracts

When you're ready to deploy your contracts, just run one of the following command to deploy you're contracts:

```bash
node deploy
# or
yarn deploy
```

> [!IMPORTANT]
> This requires a secret key to make it work. Get your secret key [here](https://thirdweb.com/dashboard/settings/api-keys).
> Pass your secret key as a value after `-k` flag.
>
> ```bash
> npm run deploy -- -k <your-secret-key>
> # or
> yarn deploy -k <your-secret-key>
> ```

## Deploying WNETZ

When you're ready to deploy WNETZ on a chosen chain, just run one of the following command to deploy the instance:

```bash
node wnetz
# or
yarn wnetz
```

> [!IMPORTANT]
> This requires a secret key to make it work. Get your secret key [here](https://thirdweb.com/dashboard/settings/api-keys).
> Pass your secret key as a value after `-k` flag.
>
> ```bash
> npm run deploy -- -k <your-secret-key>
> # or
> yarn deploy -k <your-secret-key>
> ```

## Releasing Contracts

If you want to release a version of your contracts publicly, you can use one of the followings command:

```bash
npm run release
# or
yarn release
```

## Join our Discord!

For any questions, suggestions, join our discord at [https://discord.gg/thirdweb](https://discord.gg/thirdweb).

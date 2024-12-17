require("dotenv").config();
const { execSync } = require("child_process");

if (!process.env.TW_SECRET_KEY) {
  console.error("PRIVATE_KEY is not set in the .env file");
  process.exit(1);
}

execSync(
  `npx thirdweb@latest deploy -cn WNETZBridge -k ${process.env.TW_SECRET_KEY}`,
  {
    stdio: "inherit",
  },
);

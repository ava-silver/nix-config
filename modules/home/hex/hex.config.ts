import { defineHexConfig } from "@hex/commands"

export default defineHexConfig({
  transformations: {
    "lowercase-first": {
      name: "Lowercase first letter",
      description: "Lowercase a leading capitalized word; keep \"I\", acronyms, and mixed-case words",
      transform: (text) => text.replace(/^[A-Z](?=[a-z]+\b)/, (c) => c.toLowerCase()),
    },
  },
})

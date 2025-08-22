import globals from "globals";
import tseslint from "typescript-eslint";
import pluginReactConfig from "eslint-plugin-react/configs/recommended.js";
import reactHooks from "eslint-plugin-react-hooks";

export default [
  { ignores: ["dist/**", "build/**", "coverage/**", ".vite/**"] },
  { languageOptions: { globals: globals.browser } },
  ...tseslint.configs.recommended,
  pluginReactConfig,
  {
    plugins: { "react-hooks": reactHooks },
    settings: {
      react: {
        version: "detect"
      }
    },
    rules: {
        "react-hooks/rules-of-hooks": "error",
        "react-hooks/exhaustive-deps": "warn",
        "react/react-in-jsx-scope": "off",
        "react/jsx-uses-react": "off"
    }
  }
];
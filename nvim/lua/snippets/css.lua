local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node

local function mirror_arg(args)
  return args[1][1]
end

ls.add_snippets("css", {
  -- Property Default
  s("td-property-default", {
    t("--"),
    i(1, "color"),
    t("-default: "),
    i(3, "var(--black)"),
    t(";"),
    t({ "", "--_" }),
    f(mirror_arg, { 1 }),
    t(": var(--"),
    f(mirror_arg, { 1 }),
    t(", var(--"),
    f(mirror_arg, { 1 }),
    t("-default));"),
    t({ "", "" }),
    i(2, "color"),
    t(": var(--_"),
    f(mirror_arg, { 1 }),
    t(");"),
  }),

  -- Full Background Section
  s("td-fullbg-section", {
    t("--"),
    i(1, "bg"),
    t(": #fafafa;"),
    t({ "", "box-shadow: 0 0 0 100vmax var(--" }),
    f(mirror_arg, { 1 }),
    t(");"),
    t({ "", "clip-path: inset(0 -100vmax);" }),
    t({ "", "background-color: var(--" }),
    f(mirror_arg, { 1 }),
    t(");"),
  }),

  -- CSS Media Query
  s("css-media", {
    t("@media (max-width: "),
    i(1, "991"),
    t("px) {"),
    t({ "", "    " }),
    i(2),
    t({ "", "}" }),
  }),

  -- Size
  s("td-size", {
    t("--_size: var(--size, "),
    i(1, "180"),
    t("px);"),
    t({ "", "height: var(--_size);" }),
    t({ "", "width: var(--_size);" }),
  }),

  -- Before Pseudo-element
  s("td-before", {
    t(""),
    i(1),
    t("::before {"),
    t({ "", "    --_size: var(--size, " }),
    i(2, "24"),
    t("px);"),
    t({ "", "", "    content: '';" }),
    t({ "", "    position: relative;" }),
    t({ "", "    display: block;" }),
    t({ "", "    height: var(--_size);" }),
    t({ "", "    width: var(--_size);" }),
    t({ "", '    background-image: url("' }),
    i(3),
    t('");'),
    t({ "", "    background-size: calc(var(--_size) * 0.9);" }),
    t({ "", "    background-position: center;" }),
    t({ "", "    background-repeat: no-repeat;" }),
    t({ "", "}" }),
  }),

  -- Clamp with Transitions
  s("td-clamp-trans", {
    t(""),
    t("--max: "),
    i(1, "32"),
    t(";"),
    t({ "", "--min: " }),
    i(2, "16"),
    t(";"),
    t({ "", "--maxt: " }),
    i(4, "1700"),
    t(";"),
    t({ "", "--mint: " }),
    i(5, "992"),
    t(";"),
    t({ "", "" }),
    i(3, "font-size"),
    t(
      ": clamp(var(--min) * 1px, calc((var(--max) - var(--min)) * ((100vw - var(--_mint)* 1px) / (var(--_maxt) - var(--_mint))) + var(--min) * 1px), var(--max) * 1px);"
    ),
  }),

  -- Basic Clamp
  s("td-clamp", {
    t(""),
    t("--"),
    i(1, "max"),
    t(": "),
    i(3, "32"),
    t(";"),
    t({ "", "--" }),
    i(2, "min"),
    t(": "),
    i(4, "16"),
    t(";"),
    t({ "", "" }),
    i(5, "font-size"),
    t(": clamp(var(--"),
    f(mirror_arg, { 2 }),
    t(") * 1px, calc((var(--"),
    f(mirror_arg, { 1 }),
    t(") - var(--"),
    f(mirror_arg, { 2 }),
    t(")) * ((100vw - var(--_mint)* 1px) / (var(--_maxt) - var(--_mint))) + var(--"),
    f(mirror_arg, { 2 }),
    t(") * 1px), var(--"),
    f(mirror_arg, { 1 }),
    t(") * 1px);"),
  }),

  -- Stacked Layout
  s("td-stacked", {
    t(""),
    f(mirror_arg, { 1 }),
    t(" {"),
    t({ "", "    display: grid;" }),
    t({ "", "    height: 100%;" }),
    t({ "", "    width: 100%;" }),
    t({ "", "    isolation: isolate;" }),
    t({ "", "}" }),
    t({ "", "" }),
    f(mirror_arg, { 1 }),
    t(" > * {"),
    t({ "", "    grid-row: 1 / -1;" }),
    t({ "", "    grid-column: 1 / -1;" }),
    t({ "", "    z-index: 1;" }),
    t({ "", "    min-height: 0;" }),
    t({ "", "    min-width: 0;" }),
    t({ "", "}" }),
  }),

  -- Mint (Breakpoint) Snippet
  s("td-mint", {
    t("--maxt-d: "),
    i(1, "1600"),
    t(";"),
    t({ "", "--mint-d: " }),
    i(2, "768"),
    t(";"),
    t({ "", "--_maxt: var(--maxt, var(--maxt-d));" }),
    t({ "", "--_mint: var(--mint, var(--mint-d));" }),
  }),
})

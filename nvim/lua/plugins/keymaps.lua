-- Delete/change/substitute go to the black hole register, so yanked text
-- is never clobbered by a delete. Paste over a selection keeps the yank too.
---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["d"] = { '"_d', desc = "Delete without yank" },
        ["dd"] = { '"_dd', desc = "Delete line without yank" },
        ["D"] = { '"_D', desc = "Delete to end without yank" },
        ["x"] = { '"_x', desc = "Delete char without yank" },
        ["X"] = { '"_X', desc = "Delete char back without yank" },
        ["c"] = { '"_c', desc = "Change without yank" },
        ["cc"] = { '"_cc', desc = "Change line without yank" },
        ["C"] = { '"_C', desc = "Change to end without yank" },
        ["s"] = { '"_s', desc = "Substitute without yank" },
        ["S"] = { '"_S', desc = "Substitute line without yank" },
      },
      v = {
        ["d"] = { '"_d', desc = "Delete without yank" },
        ["D"] = { '"_D', desc = "Delete without yank" },
        ["c"] = { '"_c', desc = "Change without yank" },
        ["C"] = { '"_C', desc = "Change without yank" },
        ["s"] = { '"_s', desc = "Substitute without yank" },
        ["S"] = { '"_S', desc = "Substitute without yank" },
        ["p"] = { '"_dP', desc = "Paste without yank" },
      },
    },
  },
}

# Neovim Configuration

This directory is a placeholder for Neovim configuration.

## Current Setup

My Neovim config is located at `~/.config/nvim/` and uses a modern setup.

## To Add Your Config

If you want to include your Neovim config in this dotfiles repo:

```bash
# Copy your current config
cp -r ~/.config/nvim/* ~/dotfiles/nvim/

# Update install.sh to symlink it
# Add this line to the symlinks section:
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
```

## Recommended Distributions

See the main README or [Mac Setup Guide](../docs/Mac-Setup.md) for recommended Neovim distributions:
- **AstroNvim** - Batteries-included, great for beginners
- **LazyVim** - Minimal, highly customizable

## Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [AstroNvim](https://astronvim.com/)
- [LazyVim](https://www.lazyvim.org/)

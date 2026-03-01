#!/usr/bin/env python3
"""
Codemod: Convert enableableModule NixOS modules to dendritic flake-parts pattern.

Pattern being converted:
  params@{ <args> }:
  with lib.aiden;
  [optional let ... in]
  enableableModule "<name>" params {
    <config body>
  }

Output:
  { ... }:
  {
    flake.modules.nixos.<name> =
      { <args> }:
      [optional with lib;]
      [optional with pkgs;]
      [optional let ... in]
      {
        <config body>
      };
  }
"""

import re
import os
import shutil
import sys

REPO = os.path.dirname(os.path.abspath(__file__))
OLD_MODULES = os.path.join(REPO, "_old-modules", "nixos")
NEW_MODULES = os.path.join(REPO, "modules")

# Modules to convert (steam excluded - references inputs, handled in Wave 3)
MODULES = [
    "adguard",
    "android",
    "barrier",
    "cli-base",
    "coreboot",
    "emacs",
    "gc",
    "ios",
    "php-docker",
    "printer",
    "redshift",
    "scala",
    "ssh",
    "thunar",
    "traefik",
    "transmission",
]


def extract_args(content):
    """Extract the args from params@{ ... }: line."""
    m = re.search(r'params@\{([^}]*)\}:', content, re.DOTALL)
    if not m:
        return "pkgs, lib, config, ..."
    args_raw = m.group(1).strip()
    # Normalize: split by comma/newline, strip whitespace, rejoin
    parts = [p.strip() for p in re.split(r'[,\n]+', args_raw) if p.strip()]
    return ", ".join(parts)


def has_with_lib(content):
    """Check if old module has 'with lib;' (bare, not lib.aiden)."""
    # Look for standalone 'with lib;' lines
    return bool(re.search(r'\bwith\s+lib\s*;', content))


def has_with_pkgs(content):
    """Check if old module has 'with pkgs;'."""
    return bool(re.search(r'\bwith\s+pkgs\s*;', content))


def extract_body(content, module_name):
    """
    Extract everything between:
      enableableModule "<name>" params {
        ...
      }

    Returns (let_block, config_body) where let_block may be empty string.
    """
    # Find the enableableModule call - it starts after 'with lib.aiden;'
    # and possibly after a let ... in block
    # The pattern is: enableableModule "<name>" params { ... }

    # First, strip the header (params@{...}: with lib.aiden;)
    # Find position after 'with lib.aiden;'
    after_header = re.search(r'with\s+lib\.aiden\s*;', content)
    if not after_header:
        raise ValueError(f"Could not find 'with lib.aiden;' in {module_name}")

    rest = content[after_header.end():]

    # Remove 'with lib;' if present (standalone - we'll add it back in wrapper)
    rest = re.sub(r'\bwith\s+lib\s*;', '', rest)
    # Remove 'with pkgs;' if present
    rest = re.sub(r'\bwith\s+pkgs\s*;', '', rest)

    # Find enableableModule "<name>" params {
    em_pattern = rf'enableableModule\s+"({re.escape(module_name)})"\s+params\s+\{{'
    em_match = re.search(em_pattern, rest)
    if not em_match:
        raise ValueError(f"Could not find enableableModule call for {module_name}")

    # Extract let block (between 'with lib.aiden;' and 'enableableModule')
    let_block = rest[:em_match.start()].strip()

    # Now extract the body - everything between the opening { and the matching }
    body_start = em_match.end()
    body_content = rest[body_start:]

    # Find matching closing brace
    depth = 1
    i = 0
    while i < len(body_content) and depth > 0:
        if body_content[i] == '{':
            depth += 1
        elif body_content[i] == '}':
            depth -= 1
        i += 1

    config_body = body_content[:i-1]

    # Remove leading/trailing blank lines from config body
    config_body = config_body.strip('\n')

    return let_block, config_body


def indent(text, spaces):
    """Indent each line of text by spaces."""
    prefix = " " * spaces
    lines = text.split('\n')
    return '\n'.join(prefix + line if line.strip() else line for line in lines)


def build_output(module_name, args_str, old_has_with_lib, old_has_with_pkgs, let_block, config_body):
    """Build the dendritic module file content."""
    lines = []
    lines.append("{ ... }:")
    lines.append("{")
    lines.append(f"  flake.modules.nixos.{module_name} =")
    lines.append(f"    {{ {args_str} }}:")

    # with lib; / with pkgs; after args
    if old_has_with_lib:
        lines.append("    with lib;")
    if old_has_with_pkgs:
        lines.append("    with pkgs;")

    if let_block:
        # Indent let block by 4 spaces
        indented_let = indent(let_block, 4)
        lines.append(indented_let)
    
    lines.append("    {")
    # Indent config body by 6 spaces
    indented_body = indent(config_body, 6)
    lines.append(indented_body)
    lines.append("    };")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def convert_module(module_name):
    src_dir = os.path.join(OLD_MODULES, module_name)
    src_file = os.path.join(src_dir, "default.nix")

    if not os.path.exists(src_file):
        print(f"  SKIP: {src_file} not found")
        return

    with open(src_file) as f:
        content = f.read()

    args_str = extract_args(content)
    old_has_lib = has_with_lib(content)
    old_has_pkgs = has_with_pkgs(content)

    try:
        let_block, config_body = extract_body(content, module_name)
    except ValueError as e:
        print(f"  ERROR: {e}")
        return

    output = build_output(module_name, args_str, old_has_lib, old_has_pkgs, let_block, config_body)

    # Write output - single file (no companion files for these 16)
    out_file = os.path.join(NEW_MODULES, f"{module_name}.nix")
    with open(out_file, "w") as f:
        f.write(output)

    print(f"  OK: modules/{module_name}.nix")

    # Copy companion files (non-default.nix) if any
    companions = [f for f in os.listdir(src_dir) if f != "default.nix"]
    if companions:
        out_dir = os.path.join(NEW_MODULES, module_name)
        os.makedirs(out_dir, exist_ok=True)
        # Move the .nix file into the dir as default.nix
        os.rename(out_file, os.path.join(out_dir, "default.nix"))
        for comp in companions:
            shutil.copy2(os.path.join(src_dir, comp), os.path.join(out_dir, comp))
            print(f"  OK: modules/{module_name}/{comp} (companion)")


if __name__ == "__main__":
    print("Converting enableableModule modules to dendritic format...")
    for name in MODULES:
        print(f"\n[{name}]")
        convert_module(name)
    print("\nDone.")

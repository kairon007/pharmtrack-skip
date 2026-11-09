import re
with open("Sources/SharedUI/Medical/DashboardView.swift", "r") as f:
    text = f.read()

# Make sure all usages of these modifiers are valid.
# E.g. .ignoreAllSafeAreas() etc.

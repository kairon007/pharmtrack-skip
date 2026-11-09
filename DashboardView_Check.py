import os
import re

dir_path = "Sources/SharedUI/Medical/"

for filename in os.listdir(dir_path):
    if filename.endswith(".swift"):
        file_path = os.path.join(dir_path, filename)
        with open(file_path, "r") as f:
            content = f.read()

        # check if there are unbalanced braces in all swift files
        brace_count = 0
        for char in content:
            if char == '{': brace_count += 1
            elif char == '}': brace_count -= 1

        if brace_count != 0:
            print(f"Error in {filename}: Unbalanced braces {brace_count}")

print("Checked all swift files")

import json
import subprocess

# Run your existing bash script to get total line count
result = subprocess.run(["bash", "./count_line.sh", "shlomoPearl"], capture_output=True, text=True)

# Extract the total line count from the final line of output
lines = result.stdout.splitlines()
print(f"Total lines:\n {lines} ")
total_line_line = next((line for line in lines if "TOTAL" in line), None)

# Default fallback if not found
total_count = "unknown"

if total_line_line:
    try:
        total_count = total_line_line.split()[-1]  # last value should be the line count
    except:
        pass

badge = {
    "schemaVersion": 1,
    "label": "Lines of Code",
    "message": total_count,
    "color": "blue"
}

with open("linecount.json", "w") as f:
    json.dump(badge, f)


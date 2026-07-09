# =========================================================
# Merge assembly lists and remove duplicates
# Prefer unique assemblies before download
# =========================================================

cat \
data/processed/meropenem_assembly_list.txt \
data/processed/imipenem_assembly_list.txt \
| sort -u \
> data/processed/all_assemblies.txt

echo "=================================="
echo "Merged assembly list created"
echo "Total unique assemblies:"
wc -l data/processed/all_assemblies.txt
echo "=================================="

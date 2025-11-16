set -euo pipefail

TEST_DIR=${1:-tests/otimizacao}
OUT_DIR=${2:-ir_outputs}

mkdir -p "$OUT_DIR"

if [ ! -d "$TEST_DIR" ]; then
  echo "Diretório de testes não existe: $TEST_DIR" >&2
  exit 1
fi

while IFS= read -r -d '' f; do
  rel="${f#$TEST_DIR/}"
  outpath="$OUT_DIR/${rel%.txt}.ir"
  outdir=$(dirname "$outpath")
  mkdir -p "$outdir"

  echo "==> Gerando IR para: $f -> $outpath"
  if ! ./c_parser "$f"; then
    status=$?
    echo "Aviso: compilador retornou exit code $status para $f" >&2
  fi

  if [ -f output.ir ]; then
    mv -f output.ir "$outpath"
  else
    echo "Aviso: nenhum output.ir gerado para $f" >&2
  fi
done < <(find "$TEST_DIR" -type f -name '*.txt' -print0)

echo "Concluído. IRs salvos em: $OUT_DIR"
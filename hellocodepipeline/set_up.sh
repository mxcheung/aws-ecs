#---------- Main loop --------------------------------------------------------
for comp in "${components[@]}"; do
  echo
  echo "▶ Starting component: ${comp}"
  echo "────────────────────────────────────────────────────────────"
  (
    cd "${MY_ENV_ROOT_DIR}/${comp}"
    ./set_up.sh
  )
  echo "✅ Finished component: ${comp}"
done

echo
echo "🎉 All components initialised successfully"

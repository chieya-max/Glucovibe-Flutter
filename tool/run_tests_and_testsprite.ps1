# Run this script locally to execute Flutter tests and optionally call TestSprite.
#
# Usage:
#   # Run tests only
#   .\tool\run_tests_and_testsprite.ps1
#
#   # Run tests and call TestSprite (set TESTSPRITE_API_KEY env var to the command to run)
#   $env:TESTSPRITE_API_KEY = 'your_api_key_here'
#   .\tool\run_tests_and_testsprite.ps1

Write-Host "Running flutter test..."
flutter test --coverage

if ($LASTEXITCODE -ne 0) {
  Write-Host "flutter test failed with exit code $LASTEXITCODE" -ForegroundColor Red
  exit $LASTEXITCODE
}

if ($env:TESTSPRITE_API_KEY) {
  Write-Host "TESTSPRITE_API_KEY detected — running TestSprite..."
  Write-Host "Command: testsprite upload --api-key `$env:TESTSPRITE_API_KEY --artifact coverage/lcov.info"
  testsprite upload --api-key $env:TESTSPRITE_API_KEY --artifact coverage/lcov.info
  if ($LASTEXITCODE -ne 0) {
    Write-Host "TestSprite command failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
  }
} else {
  Write-Host "No TESTSPRITE_API_KEY set — skipping TestSprite step."
}

Write-Host "All done."
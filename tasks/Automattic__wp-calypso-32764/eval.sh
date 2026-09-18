#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff f6bd966b656c4c84ea0aebcdd341f601cd8cc292
git checkout f6bd966b656c4c84ea0aebcdd341f601cd8cc292 client/me/pending-payments/test/index.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/me/pending-payments/test/index.js b/client/me/pending-payments/test/index.js
index 54ab098378f16..9fa744a59f2fe 100644
--- a/client/me/pending-payments/test/index.js
+++ b/client/me/pending-payments/test/index.js
@@ -41,7 +41,7 @@ describe( 'PendingPayments', () => {
 
 		const rules = [
 			'Main.pending-payments Localized(MeSidebarNavigation)',
-			'Main.pending-payments PurchasesHeader[section="pending"]',
+			'Main.pending-payments Connect(Localized(PurchasesHeader))[section="pending"]',
 			'Connect(PurchasesSite)[isPlaceholder=true]',
 		];
 
@@ -59,7 +59,7 @@ describe( 'PendingPayments', () => {
 
 		const rules = [
 			'Main.pending-payments Localized(MeSidebarNavigation)',
-			'Main.pending-payments PurchasesHeader[section="pending"]',
+			'Main.pending-payments Connect(Localized(PurchasesHeader))[section="pending"]',
 			'.pending-payments .pending-payments__no-content EmptyContent',
 		];
 
@@ -84,7 +84,7 @@ describe( 'PendingPayments', () => {
 
 		const rules = [
 			'Main.pending-payments Localized(MeSidebarNavigation)',
-			'Main.pending-payments PurchasesHeader[section="pending"]',
+			'Main.pending-payments Connect(Localized(PurchasesHeader))[section="pending"]',
 			'Main.pending-payments Connect(Localized(PendingListItem))',
 		];
 

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/me/pending-payments/test/index.js
: '>>>>> End Test Output'
git checkout f6bd966b656c4c84ea0aebcdd341f601cd8cc292 client/me/pending-payments/test/index.js

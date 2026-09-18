#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 24f0f91bbd36dc626fac11714a900d5b4d9b5cf9
git checkout 24f0f91bbd36dc626fac11714a900d5b4d9b5cf9 client/extensions/woocommerce/state/data-layer/product-categories/test/index.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/extensions/woocommerce/state/data-layer/product-categories/test/index.js b/client/extensions/woocommerce/state/data-layer/product-categories/test/index.js
index 85456fd620297..96e5ae43b719e 100644
--- a/client/extensions/woocommerce/state/data-layer/product-categories/test/index.js
+++ b/client/extensions/woocommerce/state/data-layer/product-categories/test/index.js
@@ -15,9 +15,9 @@ import {
 	handleProductCategoryDelete,
 	handleProductCategoryDeleteSuccess,
 	handleProductCategoryUpdate,
-	handleProductCategoriesRequest,
-	handleProductCategoriesSuccess,
-	handleProductCategoriesError,
+	fetch,
+	onFetchSuccess,
+	onFetchError,
 } from '../';
 import {
 	WOOCOMMERCE_API_REQUEST,
@@ -32,40 +32,37 @@ import {
 	updateProductCategory,
 	deleteProductCategory,
 } from 'woocommerce/state/sites/product-categories/actions';
-import { WPCOM_HTTP_REQUEST } from 'state/action-types';
+import { http } from 'state/data-layer/wpcom-http/actions';
 
 describe( 'handlers', () => {
-	describe( '#handleProductCategoriesRequest()', () => {
+	describe( '#fetch()', () => {
 		test( 'should dispatch a get action', () => {
 			const siteId = '123';
-			const dispatch = spy();
 			const action = {
 				type: WOOCOMMERCE_PRODUCT_CATEGORIES_REQUEST,
 				siteId,
 				query: {},
 			};
-			handleProductCategoriesRequest( { dispatch }, action );
-			expect( dispatch ).to.have.been.calledWith(
-				match( {
-					type: WPCOM_HTTP_REQUEST,
+			const result = fetch( action );
+			expect( result ).to.eql(
+				http( {
 					method: 'GET',
-					path: `/jetpack-blogs/${ siteId }/rest-api/`,
+					path: '/jetpack-blogs/123/rest-api/',
+					apiVersion: '1.1',
+					body: null,
 					query: {
-						path: '/wc/v3/products/categories&page=1&per_page=100&_envelope&_method=GET',
 						json: true,
-						apiVersion: '1.1',
+						path: '/wc/v3/products/categories&page=1&per_page=100&_envelope&_method=GET',
 					},
-				} )
+				}, action )
 			);
 		} );
 	} );
 
-	describe( '#handleProductCategoriesSuccess()', () => {
+	describe( '#onFetchSuccess()', () => {
 		test( 'should dispatch a success action with product category information when request completes', () => {
 			const siteId = '123';
-			const store = {
-				dispatch: spy(),
-			};
+			const dispatch = spy();
 
 			const cats = [
 				{
@@ -93,9 +90,9 @@ describe( 'handlers', () => {
 				siteId,
 				query: {},
 			};
-			handleProductCategoriesSuccess( store, action, response );
+			onFetchSuccess( action, response )( dispatch );
 
-			expect( store.dispatch ).calledWith( {
+			expect( dispatch ).calledWith( {
 				type: WOOCOMMERCE_PRODUCT_CATEGORIES_REQUEST_SUCCESS,
 				siteId,
 				data: cats,
@@ -104,78 +101,20 @@ describe( 'handlers', () => {
 				query: {},
 			} );
 		} );
-		test( 'should dispatch with an error if the envelope response is not 200', () => {
-			const siteId = '123';
-			const store = {
-				dispatch: spy(),
-			};
-
-			const response = {
-				data: {
-					body: {
-						message: 'No route was found matching the URL and request method',
-						code: 'rest_no_route',
-					},
-					status: 404,
-				},
-			};
-
-			const action = {
-				type: WOOCOMMERCE_PRODUCT_CATEGORIES_REQUEST,
-				siteId,
-				query: {},
-			};
-			handleProductCategoriesSuccess( store, action, response );
-
-			expect( store.dispatch ).to.have.been.calledWith(
-				match( {
-					type: WOOCOMMERCE_PRODUCT_CATEGORIES_REQUEST_FAILURE,
-					siteId,
-				} )
-			);
-		} );
-		test( 'should dispatch with an error if the response is not valid', () => {
-			const siteId = '123';
-			const store = {
-				dispatch: spy(),
-			};
-
-			const response = {
-				data: {
-					body: [ { bogus: 'test' } ],
-					status: 200,
-				},
-			};
-
-			const action = {
-				type: WOOCOMMERCE_PRODUCT_CATEGORIES_REQUEST,
-				siteId,
-			};
-			handleProductCategoriesSuccess( store, action, response );
-
-			expect( store.dispatch ).to.have.been.calledWith(
-				match( {
-					type: WOOCOMMERCE_PRODUCT_CATEGORIES_REQUEST_FAILURE,
-					siteId,
-				} )
-			);
-		} );
 	} );
 
-	describe( '#handleProductCategoriesError()', () => {
+	describe( '#onFetchError()', () => {
 		test( 'should dispatch error', () => {
 			const siteId = '123';
-			const store = {
-				dispatch: spy(),
-			};
+			const dispatch = spy();
 
 			const action = {
 				type: WOOCOMMERCE_PRODUCT_CATEGORIES_REQUEST,
 				siteId,
 			};
-			handleProductCategoriesError( store, action, 'error' );
+			onFetchError( action, 'error' )( dispatch );
 
-			expect( store.dispatch ).to.have.been.calledWith(
+			expect( dispatch ).to.have.been.calledWith(
 				match( {
 					type: WOOCOMMERCE_PRODUCT_CATEGORIES_REQUEST_FAILURE,
 					siteId,

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/extensions/woocommerce/state/data-layer/product-categories/test/index.js
: '>>>>> End Test Output'
git checkout 24f0f91bbd36dc626fac11714a900d5b4d9b5cf9 client/extensions/woocommerce/state/data-layer/product-categories/test/index.js

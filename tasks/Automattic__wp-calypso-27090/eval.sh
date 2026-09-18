#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff c73ce2eab8daebaeec5803c30427f2c91c8ef9c0
rm -f client/state/data-layer/wpcom/sites/stats/views/posts/test/index.js client/state/stats/recent-post-views/test/actions.js client/state/stats/recent-post-views/test/reducer.js client/state/stats/recent-post-views/test/selectors.js
git apply -v - <<'EOF_114329324912'
diff --git a/client/state/data-layer/wpcom/sites/stats/views/posts/test/index.js b/client/state/data-layer/wpcom/sites/stats/views/posts/test/index.js
new file mode 100644
index 00000000000000..38542508dd4093
--- /dev/null
+++ b/client/state/data-layer/wpcom/sites/stats/views/posts/test/index.js
@@ -0,0 +1,42 @@
+/** @format */
+/**
+ * Internal Dependencies
+ */
+import { fetch, onSuccess } from '../';
+import { http } from 'state/data-layer/wpcom-http/actions';
+import {
+	requestRecentPostViews,
+	receiveRecentPostViews,
+} from 'state/stats/recent-post-views/actions';
+
+describe( 'fetch', () => {
+	it( 'should dispatch an http request', () => {
+		const action = requestRecentPostViews( 1, [ 1, 2, 3 ], 30, '2018-01-01' );
+		expect( fetch( action ) ).toEqual(
+			http(
+				{
+					method: 'GET',
+					path: `/sites/1/stats/views/posts`,
+					apiVersion: '1.1',
+					query: {
+						post_ids: '1,2,3',
+						num: 30,
+						date: '2018-01-01',
+					},
+				},
+				action
+			)
+		);
+	} );
+} );
+
+describe( 'onSuccess', () => {
+	test( 'should return a receiveRecentPostViews action with the data', () => {
+		const data = {
+			date: '2018-01-01',
+			posts: [],
+		};
+		const output = onSuccess( { siteId: 1 }, data );
+		expect( output ).toEqual( receiveRecentPostViews( 1, data ) );
+	} );
+} );
diff --git a/client/state/stats/recent-post-views/test/actions.js b/client/state/stats/recent-post-views/test/actions.js
new file mode 100644
index 00000000000000..067a94949f545f
--- /dev/null
+++ b/client/state/stats/recent-post-views/test/actions.js
@@ -0,0 +1,58 @@
+/** @format */
+
+/**
+ * Internal dependencies
+ */
+import { requestRecentPostViews, receiveRecentPostViews } from '../actions';
+import {
+	STATS_RECENT_POST_VIEWS_REQUEST,
+	STATS_RECENT_POST_VIEWS_RECEIVE,
+} from 'state/action-types';
+
+describe( 'actions', () => {
+	const siteId = 37463864;
+	const date = '1969-07-20';
+
+	describe( '#receiveRecentPostViews', () => {
+		test( 'should create an action for requesting recent post views', () => {
+			const postIds = '99,98,97';
+			const num = 30;
+			const action = requestRecentPostViews( siteId, postIds, num, date );
+
+			expect( action ).toEqual( {
+				type: STATS_RECENT_POST_VIEWS_REQUEST,
+				siteId,
+				postIds,
+				num,
+				date,
+			} );
+		} );
+	} );
+
+	describe( '#receiveRecentPostViews()', () => {
+		test( 'should create an action for receiving recent post views', () => {
+			const posts = [
+				{
+					ID: 99,
+					views: 1,
+				},
+				{
+					ID: 2,
+					views: 10000001,
+				},
+				{
+					ID: 924756329847,
+					views: 22,
+				},
+			];
+			const action = receiveRecentPostViews( siteId, { date, posts } );
+
+			expect( action ).toEqual( {
+				type: STATS_RECENT_POST_VIEWS_RECEIVE,
+				siteId,
+				date,
+				posts,
+			} );
+		} );
+	} );
+} );
diff --git a/client/state/stats/recent-post-views/test/reducer.js b/client/state/stats/recent-post-views/test/reducer.js
new file mode 100644
index 00000000000000..16b6f4203a4938
--- /dev/null
+++ b/client/state/stats/recent-post-views/test/reducer.js
@@ -0,0 +1,91 @@
+/** @format */
+
+/**
+ * Internal dependencies
+ */
+import { items } from '../reducer';
+import { STATS_RECENT_POST_VIEWS_RECEIVE } from 'state/action-types';
+
+describe( 'reducer', () => {
+	const siteId = 15749347;
+	const viewsPostsResponse = {
+		date: '1969-07-20',
+		posts: [
+			{
+				ID: 99,
+				views: 1,
+			},
+			{
+				ID: 2,
+				views: 10000001,
+			},
+			{
+				ID: 924756329847,
+				views: 22,
+			},
+		],
+	};
+
+	describe( '#items()', () => {
+		test( 'should default to an empty object', () => {
+			const state = items( undefined, {} );
+
+			expect( state ).toEqual( {} );
+		} );
+
+		test( 'should index recent post views by ID for each site', () => {
+			const state = items( null, {
+				type: STATS_RECENT_POST_VIEWS_RECEIVE,
+				siteId,
+				posts: viewsPostsResponse.posts,
+			} );
+
+			expect( state ).toEqual( {
+				[ siteId ]: {
+					99: { views: 1 },
+					2: { views: 10000001 },
+					924756329847: { views: 22 },
+				},
+			} );
+		} );
+
+		test( 'should accumulate recent post views', () => {
+			const originalState = Object.freeze( {
+				[ siteId ]: { 73705554: { views: 9384 } },
+			} );
+			const updatedState = items( originalState, {
+				type: STATS_RECENT_POST_VIEWS_RECEIVE,
+				siteId,
+				posts: viewsPostsResponse.posts,
+			} );
+
+			expect( updatedState ).toEqual( {
+				[ siteId ]: {
+					...originalState[ siteId ],
+					99: { views: 1 },
+					2: { views: 10000001 },
+					924756329847: { views: 22 },
+				},
+			} );
+		} );
+
+		test( 'should override previous recent post views', () => {
+			const originalState = Object.freeze( {
+				[ siteId ]: { 99: { views: 253 } },
+			} );
+			const updatedState = items( originalState, {
+				type: STATS_RECENT_POST_VIEWS_RECEIVE,
+				siteId,
+				posts: viewsPostsResponse.posts,
+			} );
+
+			expect( updatedState ).toEqual( {
+				[ siteId ]: {
+					99: { views: 1 },
+					2: { views: 10000001 },
+					924756329847: { views: 22 },
+				},
+			} );
+		} );
+	} );
+} );
diff --git a/client/state/stats/recent-post-views/test/selectors.js b/client/state/stats/recent-post-views/test/selectors.js
new file mode 100644
index 00000000000000..2d574462ec7d19
--- /dev/null
+++ b/client/state/stats/recent-post-views/test/selectors.js
@@ -0,0 +1,36 @@
+/** @format */
+
+/**
+ * Internal dependencies
+ */
+import { getRecentViewsForPost } from '../selectors';
+
+describe( 'selectors', () => {
+	const siteId = 3855820;
+	const postId = 958;
+	const state = {
+		stats: {
+			recentPostViews: {
+				items: {
+					[ siteId ]: {
+						[ postId ]: { views: 8274 },
+					},
+				},
+			},
+		},
+	};
+
+	describe( '#getRecentViewsForPost()', () => {
+		test( 'should return recent views for a post by site and id', () => {
+			const recentViews = getRecentViewsForPost( state, siteId, postId );
+
+			expect( recentViews ).toEqual( 8274 );
+		} );
+
+		test( 'should default to null', () => {
+			const recentViews = getRecentViewsForPost( state, siteId, -1 );
+
+			expect( recentViews ).toBeNull();
+		} );
+	} );
+} );

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/data-layer/wpcom/sites/stats/views/posts/test/index.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/stats/recent-post-views/test/actions.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/stats/recent-post-views/test/reducer.js ; CFG=test/client/jest.config.json; [ -f $CFG ] || CFG=test/client/jest.config.js; ./node_modules/.bin/jest --verbose -c=$CFG client/state/stats/recent-post-views/test/selectors.js
: '>>>>> End Test Output'
rm -f client/state/data-layer/wpcom/sites/stats/views/posts/test/index.js client/state/stats/recent-post-views/test/actions.js client/state/stats/recent-post-views/test/reducer.js client/state/stats/recent-post-views/test/selectors.js

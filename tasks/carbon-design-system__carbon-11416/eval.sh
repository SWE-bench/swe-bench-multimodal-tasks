#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b53e3e9e02a18e4cf94b9f90e31caf4e979ac05b
mkdir -p node_modules/accessibility-checker/lib/engine 2>/dev/null || true
git checkout b53e3e9e02a18e4cf94b9f90e31caf4e979ac05b packages/react/src/components/DatePicker/DatePicker-test.js packages/react/src/components/DatePicker/next/DatePicker-test.js
git apply -v - <<'EOF_114329324912'
diff --git a/packages/react/src/components/DatePicker/DatePicker-test.js b/packages/react/src/components/DatePicker/DatePicker-test.js
index 3ad55af46543..4a9c36f89318 100644
--- a/packages/react/src/components/DatePicker/DatePicker-test.js
+++ b/packages/react/src/components/DatePicker/DatePicker-test.js
@@ -6,39 +6,44 @@
  */
 
 import React from 'react';
-import DatePicker from '../DatePicker';
-import DatePickerSkeleton from '../DatePicker/DatePicker.Skeleton';
-import { mount, shallow } from 'enzyme';
-import DatePickerInput from '../DatePickerInput/DatePickerInput';
+import DatePicker from './DatePicker';
+import { mount } from 'enzyme';
+import DatePickerInput from '../DatePickerInput';
 
 const prefix = 'cds';
 
+function getFlatpickrCalendar() {
+  return document.querySelector(`.${prefix}--date-picker__calendar`);
+}
+
 describe('DatePicker', () => {
   describe('Renders as expected', () => {
-    const wrapper = mount(
-      <DatePicker onChange={() => {}} className="extra-class">
-        <DatePickerInput
-          id="date-picker-input-id-start"
-          placeholder="mm/dd/yyyy"
-          labelText="Start date"
-        />
-        <DatePickerInput
-          id="date-picker-input-id-finish"
-          placeholder="mm/dd/yyyy"
-          labelText="End date"
-        />
-      </DatePicker>
-    );
-    const datepicker = wrapper.childAt(0);
+    let wrapper;
+    let datepicker;
 
-    it('has the expected classes', () => {
-      expect(datepicker.children().hasClass(`${prefix}--date-picker`)).toBe(
-        true
+    beforeEach(() => {
+      wrapper = mount(
+        <DatePicker
+          onChange={() => {}}
+          className="extra-class"
+          dateFormat="m/d/Y">
+          <DatePickerInput
+            id="date-picker-input-id-start"
+            placeholder="mm/dd/yyyy"
+            labelText="Start date"
+          />
+          <DatePickerInput
+            id="date-picker-input-id-finish"
+            placeholder="mm/dd/yyyy"
+            labelText="End date"
+          />
+        </DatePicker>
       );
+      datepicker = wrapper.childAt(0);
     });
 
     it('should add extra classes that are passed via className', () => {
-      expect(datepicker.children().hasClass('extra-class')).toBe(true);
+      expect(datepicker.hasClass('extra-class')).toBe(true);
     });
 
     it('should add the date picker type as expected', () => {
@@ -47,18 +52,6 @@ describe('DatePicker', () => {
       expect(wrapper.props().datePickerType).toEqual('simple');
     });
 
-    it('should specify short date picker as expected', () => {
-      expect(wrapper.props().short).toEqual(false);
-      wrapper.setProps({ short: true });
-      expect(wrapper.props().short).toEqual(true);
-    });
-
-    it('should specify light date picker as expected', () => {
-      expect(wrapper.props().light).toEqual(false);
-      wrapper.setProps({ light: true });
-      expect(wrapper.props().light).toEqual(true);
-    });
-
     it('should add the date format as expected', () => {
       expect(wrapper.props().dateFormat).toEqual('m/d/Y');
       wrapper.setProps({ dateFormat: 'd/m/Y' });
@@ -77,21 +70,18 @@ describe('DatePicker', () => {
   });
 
   describe('Simple date picker', () => {
-    const wrapper = mount(
-      <DatePicker datePickerType="simple" className="extra-class">
-        <DatePickerInput
-          placeholder="mm/dd/yyyy"
-          labelText="Date Picker label"
-          id="date-picker-single"
-        />
-      </DatePicker>
-    );
-    const datepicker = wrapper.childAt(0);
+    let wrapper;
 
-    it('has the simple date picker class', () => {
-      expect(
-        datepicker.children().hasClass(`${prefix}--date-picker--simple`)
-      ).toBe(true);
+    beforeEach(() => {
+      wrapper = mount(
+        <DatePicker datePickerType="simple" className="extra-class">
+          <DatePickerInput
+            placeholder="mm/dd/yyyy"
+            labelText="Date Picker label"
+            id="date-picker-single"
+          />
+        </DatePicker>
+      );
     });
 
     it('has the value as expected', () => {
@@ -101,121 +91,36 @@ describe('DatePicker', () => {
     });
 
     it('should not initialize a calendar', () => {
-      expect(wrapper.cal).toEqual(undefined);
+      expect(getFlatpickrCalendar()).not.toBeInTheDocument();
     });
   });
 
   describe('Single date picker', () => {
-    const wrapper = mount(
-      <DatePicker
-        onChange={() => {}}
-        datePickerType="single"
-        className="extra-class">
-        <DatePickerInput
-          placeholder="mm/dd/yyyy"
-          labelText="Date Picker label"
-          id="date-picker-single"
-        />
-      </DatePicker>
-    );
-    const datepicker = wrapper.childAt(0);
-
-    it('has the single date picker class', () => {
-      expect(
-        datepicker.children().hasClass(`${prefix}--date-picker--single`)
-      ).toBe(true);
-    });
-
-    it('should initialize a calendar', () => {
-      expect(wrapper.instance().cal).toBeDefined();
-    });
-
-    it('should update the classnames', () => {
-      expect(
-        wrapper
-          .instance()
-          .cal.calendarContainer.classList.contains(
-            `${prefix}--date-picker__calendar`
-          )
-      ).toBe(true);
-    });
-
-    it('has the value as expected', () => {
-      expect(wrapper.props().value).toEqual(undefined);
-      wrapper.setProps({ value: '11/08/2017' });
-      expect(wrapper.props().value).toEqual('11/08/2017');
-    });
-  });
-
-  describe('Single date picker with initial value', () => {
-    const wrapper = mount(
-      <DatePicker
-        datePickerType="single"
-        dateFormat="m/d/Y"
-        value={'02/26/2017'}
-        appendTo={document.body.firstChild}
-        onChange={() => {}}>
-        <DatePickerInput
-          key="label"
-          labelText="Controlled Date"
-          id="date-picker-input-id"
-        />
-      </DatePicker>
-    );
-
-    it('has the value as expected', () => {
-      // MOUNT
-      expect(wrapper.props().value).toEqual('02/26/2017');
-
-      // UPDATE
-      wrapper.setProps({ value: '02/17/2017' });
-      expect(wrapper.props().value).toEqual('02/17/2017');
-    });
-
-    it('sends appendTo to Flatpickr', () => {
-      expect(wrapper.instance().cal.config.appendTo).toBe(
-        document.body.firstChild
+    let wrapper;
+    beforeEach(() => {
+      wrapper = mount(
+        <DatePicker
+          onChange={() => {}}
+          datePickerType="single"
+          className="extra-class">
+          <DatePickerInput
+            placeholder="mm/dd/yyyy"
+            labelText="Date Picker label"
+            id="date-picker-single"
+          />
+        </DatePicker>
       );
     });
-  });
-
-  describe('Range date picker', () => {
-    const wrapper = mount(
-      <DatePicker
-        onChange={() => {}}
-        datePickerType="range"
-        className="extra-class">
-        <DatePickerInput
-          id="date-picker-input-id-start"
-          placeholder="mm/dd/yyyy"
-          labelText="Start date"
-        />
-        <DatePickerInput
-          id="date-picker-input-id-finish"
-          placeholder="mm/dd/yyyy"
-          labelText="End date"
-        />
-      </DatePicker>
-    );
-    const datepicker = wrapper.childAt(0);
-
-    it('has the range date picker class', () => {
-      expect(
-        datepicker.children().hasClass(`${prefix}--date-picker--range`)
-      ).toBe(true);
-    });
 
     it('should initialize a calendar', () => {
-      expect(wrapper.instance().cal).toBeDefined();
+      expect(getFlatpickrCalendar()).toBeInTheDocument();
     });
 
     it('should update the classnames', () => {
       expect(
-        wrapper
-          .instance()
-          .cal.calendarContainer.classList.contains(
-            `${prefix}--date-picker__calendar`
-          )
+        getFlatpickrCalendar().classList.contains(
+          `${prefix}--date-picker__calendar`
+        )
       ).toBe(true);
     });
 
@@ -227,42 +132,46 @@ describe('DatePicker', () => {
   });
 
   describe('Date picker with locale', () => {
-    const wrapper = mount(
-      <DatePicker
-        onChange={() => {}}
-        datePickerType="range"
-        className="extra-class"
-        locale="es">
-        <DatePickerInput
-          id="date-picker-input-id-start"
-          placeholder="mm/dd/yyyy"
-          labelText="Start date"
-        />
-        <DatePickerInput
-          id="date-picker-input-id-finish"
-          placeholder="mm/dd/yyyy"
-          labelText="End date"
-        />
-      </DatePicker>
-    );
+    let wrapper;
+    let wrapperNoLocale;
+    beforeEach(() => {
+      wrapper = mount(
+        <DatePicker
+          onChange={() => {}}
+          datePickerType="range"
+          className="extra-class"
+          locale="es">
+          <DatePickerInput
+            id="date-picker-input-id-start"
+            placeholder="mm/dd/yyyy"
+            labelText="Start date"
+          />
+          <DatePickerInput
+            id="date-picker-input-id-finish"
+            placeholder="mm/dd/yyyy"
+            labelText="End date"
+          />
+        </DatePicker>
+      );
 
-    const wrapperNoLocale = mount(
-      <DatePicker
-        onChange={() => {}}
-        datePickerType="range"
-        className="extra-class">
-        <DatePickerInput
-          id="date-picker-input-id-start"
-          placeholder="mm/dd/yyyy"
-          labelText="Start date"
-        />
-        <DatePickerInput
-          id="date-picker-input-id-finish"
-          placeholder="mm/dd/yyyy"
-          labelText="End date"
-        />
-      </DatePicker>
-    );
+      wrapperNoLocale = mount(
+        <DatePicker
+          onChange={() => {}}
+          datePickerType="range"
+          className="extra-class">
+          <DatePickerInput
+            id="date-picker-input-id-start"
+            placeholder="mm/dd/yyyy"
+            labelText="Start date"
+          />
+          <DatePickerInput
+            id="date-picker-input-id-finish"
+            placeholder="mm/dd/yyyy"
+            labelText="End date"
+          />
+        </DatePicker>
+      );
+    });
 
     it('has the range date picker locale', () => {
       const datepicker = wrapper.find('DatePicker');
@@ -271,29 +180,23 @@ describe('DatePicker', () => {
 
     it('has the range date picker without locale defined', () => {
       const datepicker = wrapperNoLocale.find('DatePicker');
-      expect(datepicker.props().locale).toBe('en');
+      expect(datepicker.props().locale).toBe(undefined);
     });
   });
 
-  describe('Date picker can be used with enzyme shallow', () => {
-    let spy;
+  describe('Date picker with minDate and maxDate', () => {
+    let mockConsoleError;
+    let wrapper;
 
     beforeEach(() => {
-      spy = {};
-      spy.console = jest.spyOn(console, 'error').mockImplementation(() => {});
-    });
-
-    afterEach(() => {
-      spy.console.mockRestore();
-    });
-
-    it('date picker should not throw exception when mounted or unmounted', () => {
-      const wrapper = shallow(
+      mockConsoleError = jest.spyOn(console, 'error');
+      wrapper = mount(
         <DatePicker
           onChange={() => {}}
           datePickerType="range"
           className="extra-class"
-          locale="es">
+          minDate="01/01/2018"
+          maxDate="01/30/2018">
           <DatePickerInput
             id="date-picker-input-id-start"
             placeholder="mm/dd/yyyy"
@@ -306,42 +209,12 @@ describe('DatePicker', () => {
           />
         </DatePicker>
       );
-      expect(wrapper.find('DatePicker')).toBeDefined();
-      wrapper.unmount();
-    });
-  });
-
-  describe('Date picker with minDate and maxDate', () => {
-    let mockConsoleError;
-
-    beforeEach(() => {
-      mockConsoleError = jest.spyOn(console, 'error');
     });
 
     afterEach(() => {
       mockConsoleError.mockRestore();
     });
 
-    const wrapper = mount(
-      <DatePicker
-        onChange={() => {}}
-        datePickerType="range"
-        className="extra-class"
-        minDate="01/01/2018"
-        maxDate="01/30/2018">
-        <DatePickerInput
-          id="date-picker-input-id-start"
-          placeholder="mm/dd/yyyy"
-          labelText="Start date"
-        />
-        <DatePickerInput
-          id="date-picker-input-id-finish"
-          placeholder="mm/dd/yyyy"
-          labelText="End date"
-        />
-      </DatePicker>
-    );
-
     it('has the range date picker with min and max dates', () => {
       const datepicker = wrapper.find('DatePicker');
       expect(datepicker.props().minDate).toBe('01/01/2018');
@@ -353,41 +226,3 @@ describe('DatePicker', () => {
     });
   });
 });
-
-describe('DatePickerSkeleton', () => {
-  describe('Renders as expected', () => {
-    const wrapper = shallow(<DatePickerSkeleton range />);
-
-    it('Has the expected classes', () => {
-      expect(wrapper.children().hasClass(`${prefix}--skeleton`)).toEqual(true);
-      expect(wrapper.children().hasClass(`${prefix}--date-picker`)).toEqual(
-        true
-      );
-      expect(
-        wrapper.children().hasClass(`${prefix}--date-picker--range`)
-      ).toEqual(true);
-    });
-  });
-});
-
-describe('Opening up calendar dropdown', () => {
-  const wrapper = mount(
-    <DatePicker datePickerType="range" className="extra-class">
-      <DatePickerInput labelText="Date Picker label" id="input-from" />
-      <DatePickerInput labelText="Date Picker label" id="input-to" />
-    </DatePicker>
-  );
-
-  it('has the range date picker with min and max dates', () => {
-    const datePicker = wrapper.instance();
-    const input = wrapper.find('input').at(0);
-
-    jest.spyOn(datePicker.cal, 'open');
-
-    input
-      .getDOMNode()
-      .dispatchEvent(new window.KeyboardEvent('keydown', { key: 'ArrowDown' }));
-
-    expect(datePicker.cal.open).toHaveBeenCalled();
-  });
-});
diff --git a/packages/react/src/components/DatePicker/next/DatePicker-test.js b/packages/react/src/components/DatePicker/next/DatePicker-test.js
deleted file mode 100644
index 0b56d1bcb0ef..000000000000
--- a/packages/react/src/components/DatePicker/next/DatePicker-test.js
+++ /dev/null
@@ -1,228 +0,0 @@
-/**
- * Copyright IBM Corp. 2016, 2018
- *
- * This source code is licensed under the Apache-2.0 license found in the
- * LICENSE file in the root directory of this source tree.
- */
-
-import React from 'react';
-import DatePicker from './DatePicker';
-import { mount } from 'enzyme';
-import DatePickerInput from '../../DatePickerInput/next/DatePickerInput';
-
-const prefix = 'cds';
-
-function getFlatpickrCalendar() {
-  return document.querySelector(`.${prefix}--date-picker__calendar`);
-}
-
-describe('DatePicker', () => {
-  describe('Renders as expected', () => {
-    let wrapper;
-    let datepicker;
-
-    beforeEach(() => {
-      wrapper = mount(
-        <DatePicker
-          onChange={() => {}}
-          className="extra-class"
-          dateFormat="m/d/Y">
-          <DatePickerInput
-            id="date-picker-input-id-start"
-            placeholder="mm/dd/yyyy"
-            labelText="Start date"
-          />
-          <DatePickerInput
-            id="date-picker-input-id-finish"
-            placeholder="mm/dd/yyyy"
-            labelText="End date"
-          />
-        </DatePicker>
-      );
-      datepicker = wrapper.childAt(0);
-    });
-
-    it('should add extra classes that are passed via className', () => {
-      expect(datepicker.hasClass('extra-class')).toBe(true);
-    });
-
-    it('should add the date picker type as expected', () => {
-      expect(wrapper.props().datePickerType).toEqual(undefined);
-      wrapper.setProps({ datePickerType: 'simple' });
-      expect(wrapper.props().datePickerType).toEqual('simple');
-    });
-
-    it('should add the date format as expected', () => {
-      expect(wrapper.props().dateFormat).toEqual('m/d/Y');
-      wrapper.setProps({ dateFormat: 'd/m/Y' });
-      expect(wrapper.props().dateFormat).toEqual('d/m/Y');
-    });
-
-    it('has the value as expected', () => {
-      expect(wrapper.props().value).toEqual(undefined);
-      wrapper.setProps({ value: '11/08/2017' });
-      expect(wrapper.props().value).toEqual('11/08/2017');
-    });
-
-    it('should render the children as expected', () => {
-      expect(wrapper.props().children.length).toEqual(2);
-    });
-  });
-
-  describe('Simple date picker', () => {
-    let wrapper;
-
-    beforeEach(() => {
-      wrapper = mount(
-        <DatePicker datePickerType="simple" className="extra-class">
-          <DatePickerInput
-            placeholder="mm/dd/yyyy"
-            labelText="Date Picker label"
-            id="date-picker-single"
-          />
-        </DatePicker>
-      );
-    });
-
-    it('has the value as expected', () => {
-      expect(wrapper.props().value).toEqual(undefined);
-      wrapper.setProps({ value: '11/08/2017' });
-      expect(wrapper.props().value).toEqual('11/08/2017');
-    });
-
-    it('should not initialize a calendar', () => {
-      expect(getFlatpickrCalendar()).not.toBeInTheDocument();
-    });
-  });
-
-  describe('Single date picker', () => {
-    let wrapper;
-    beforeEach(() => {
-      wrapper = mount(
-        <DatePicker
-          onChange={() => {}}
-          datePickerType="single"
-          className="extra-class">
-          <DatePickerInput
-            placeholder="mm/dd/yyyy"
-            labelText="Date Picker label"
-            id="date-picker-single"
-          />
-        </DatePicker>
-      );
-    });
-
-    it('should initialize a calendar', () => {
-      expect(getFlatpickrCalendar()).toBeInTheDocument();
-    });
-
-    it('should update the classnames', () => {
-      expect(
-        getFlatpickrCalendar().classList.contains(
-          `${prefix}--date-picker__calendar`
-        )
-      ).toBe(true);
-    });
-
-    it('has the value as expected', () => {
-      expect(wrapper.props().value).toEqual(undefined);
-      wrapper.setProps({ value: '11/08/2017' });
-      expect(wrapper.props().value).toEqual('11/08/2017');
-    });
-  });
-
-  describe('Date picker with locale', () => {
-    let wrapper;
-    let wrapperNoLocale;
-    beforeEach(() => {
-      wrapper = mount(
-        <DatePicker
-          onChange={() => {}}
-          datePickerType="range"
-          className="extra-class"
-          locale="es">
-          <DatePickerInput
-            id="date-picker-input-id-start"
-            placeholder="mm/dd/yyyy"
-            labelText="Start date"
-          />
-          <DatePickerInput
-            id="date-picker-input-id-finish"
-            placeholder="mm/dd/yyyy"
-            labelText="End date"
-          />
-        </DatePicker>
-      );
-
-      wrapperNoLocale = mount(
-        <DatePicker
-          onChange={() => {}}
-          datePickerType="range"
-          className="extra-class">
-          <DatePickerInput
-            id="date-picker-input-id-start"
-            placeholder="mm/dd/yyyy"
-            labelText="Start date"
-          />
-          <DatePickerInput
-            id="date-picker-input-id-finish"
-            placeholder="mm/dd/yyyy"
-            labelText="End date"
-          />
-        </DatePicker>
-      );
-    });
-
-    it('has the range date picker locale', () => {
-      const datepicker = wrapper.find('DatePicker');
-      expect(datepicker.props().locale).toBe('es');
-    });
-
-    it('has the range date picker without locale defined', () => {
-      const datepicker = wrapperNoLocale.find('DatePicker');
-      expect(datepicker.props().locale).toBe(undefined);
-    });
-  });
-
-  describe('Date picker with minDate and maxDate', () => {
-    let mockConsoleError;
-    let wrapper;
-
-    beforeEach(() => {
-      mockConsoleError = jest.spyOn(console, 'error');
-      wrapper = mount(
-        <DatePicker
-          onChange={() => {}}
-          datePickerType="range"
-          className="extra-class"
-          minDate="01/01/2018"
-          maxDate="01/30/2018">
-          <DatePickerInput
-            id="date-picker-input-id-start"
-            placeholder="mm/dd/yyyy"
-            labelText="Start date"
-          />
-          <DatePickerInput
-            id="date-picker-input-id-finish"
-            placeholder="mm/dd/yyyy"
-            labelText="End date"
-          />
-        </DatePicker>
-      );
-    });
-
-    afterEach(() => {
-      mockConsoleError.mockRestore();
-    });
-
-    it('has the range date picker with min and max dates', () => {
-      const datepicker = wrapper.find('DatePicker');
-      expect(datepicker.props().minDate).toBe('01/01/2018');
-      expect(datepicker.props().maxDate).toBe('01/30/2018');
-    });
-
-    it('should not have "console.error" being created', () => {
-      expect(mockConsoleError).not.toHaveBeenCalled();
-    });
-  });
-});

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
rm -rf -- .achecker.yml .aat.yml && cp /opt/achecker-offline/.achecker.yml .achecker.yml && cp /opt/achecker-offline/.achecker.yml .aat.yml
for checker_dir in node_modules/@ibma/aat node_modules/accessibility-checker config/jest-config-carbon/node_modules/@ibma/aat config/jest-config-carbon/node_modules/accessibility-checker; do if [ -d "$checker_dir" ]; then find "$checker_dir" -type f \( -name AATMetricsLogger.js -o -name ACMetricsLogger.js \) -exec sed -i -e 's#http:/[/]ibmac96.austin.ibm.com/cgi-bin/log-cio/log.py#http://127.0.0.1:18080/tools/api/pub/meter/v2#g' -e 's#https:/[/]able.ibm.com/tools#http://127.0.0.1:18080/tools#g' {} +; fi; done
export NO_PROXY="${NO_PROXY:+$NO_PROXY,}127.0.0.1,localhost" no_proxy="${no_proxy:+$no_proxy,}127.0.0.1,localhost"
node -e 'var fs=require("fs"),http=require("http"),path=require("path"),url=require("url");var root="/opt/achecker-offline",port=18080,engineBase="/archives/2020.10.07/js/";http.createServer(function(request,response){response.setHeader("Access-Control-Allow-Origin","*");var pathname=decodeURIComponent(url.parse(request.url).pathname);if(pathname==="/tools/api/pub/meter/v2"){response.statusCode=204;response.end();return;}var legacyBrowserEngine=false;if(pathname===engineBase+"awe-node.js"){pathname=engineBase+"ace-node.js";}else if(pathname===engineBase+"awe.js"){pathname=engineBase+"ace.js";legacyBrowserEngine=true;}var filename=path.resolve(root,"."+pathname);if(filename.indexOf(root+path.sep)!==0){response.statusCode=403;response.end("forbidden");return;}if(/\.json$/.test(filename)){response.setHeader("Content-Type","application/json");}else if(/\.js$/.test(filename)){response.setHeader("Content-Type","application/javascript");}if(legacyBrowserEngine){fs.readFile(filename,function(error,contents){if(error){response.statusCode=404;response.end("not found");return;}response.end(Buffer.concat([contents,Buffer.from("\n;window.IBMAwe=ace;\n")]));});return;}var stream=fs.createReadStream(filename);stream.on("error",function(){if(!response.headersSent){response.statusCode=404;}response.end("not found");});stream.pipe(response);}).listen(port,"127.0.0.1");' > /tmp/achecker-offline-server.log 2>&1 &
ACHECKER_OFFLINE_PID=$!
trap 'kill $ACHECKER_OFFLINE_PID 2>/dev/null || true' EXIT
ACHECKER_OFFLINE_READY=0
for _ in {1..50}; do if curl --noproxy '*' -fsS http://127.0.0.1:18080/archives.json > /dev/null 2>&1; then ACHECKER_OFFLINE_READY=1; break; fi; sleep 0.1; done
[ "$ACHECKER_OFFLINE_READY" -eq 1 ] || { cat /tmp/achecker-offline-server.log; exit 1; }
: '>>>>> Start Test Output'
yarn test --maxWorkers=4 packages/react/src/components/DatePicker ; yarn test --maxWorkers=4 packages/react/src/components/DatePicker/DatePicker-test.js
: '>>>>> End Test Output'
git checkout b53e3e9e02a18e4cf94b9f90e31caf4e979ac05b packages/react/src/components/DatePicker/DatePicker-test.js packages/react/src/components/DatePicker/next/DatePicker-test.js

/**
 * Bundled by jsDelivr using Rollup v2.79.2 and Terser v5.48.0.
 * Original file: /npm/@zag-js/anatomy@1.41.0/dist/index.mjs
 *
 * Do NOT use SRI with dynamically generated files! More information: https://www.jsdelivr.com/using-sri-with-dynamic-files
 */
var e=(r,o=[])=>({parts:(...t)=>{if(a(o))return e(r,t);throw new Error("createAnatomy().parts(...) should only be called once. Did you mean to use .extendWith(...) ?")},extendWith:(...t)=>e(r,[...o,...t]),omit:(...t)=>e(r,o.filter(e=>!t.includes(e))),rename:t=>e(t,o),keys:()=>o,build:()=>[...new Set(o)].reduce((e,a)=>Object.assign(e,{[a]:{selector:[`&[data-scope="${t(r)}"][data-part="${t(a)}"]`,`& [data-scope="${t(r)}"][data-part="${t(a)}"]`].join(", "),attrs:{"data-scope":t(r),"data-part":t(a)}}}),{})}),t=e=>e.replace(/([A-Z])([A-Z])/g,"$1-$2").replace(/([a-z])([A-Z])/g,"$1-$2").replace(/[\s_]+/g,"-").toLowerCase(),a=e=>0===e.length;export{e as createAnatomy};export default null;
//# sourceMappingURL=/sm/25b8ae577112edc2bb2bb8c6f4831bdf2a905db6f4a3b2f05d943ccae5dbb298.map
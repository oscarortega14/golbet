/**
 * Bundled by jsDelivr using Rollup v2.79.2 and Terser v5.39.0.
 * Original file: /npm/@zag-js/anatomy@1.41.1/dist/index.mjs
 *
 * Do NOT use SRI with dynamically generated files! More information: https://www.jsdelivr.com/using-sri-with-dynamic-files
 */
var e=(r,o=[])=>({parts:(...t)=>{if(a(o))return e(r,t);throw new Error("createAnatomy().parts(...) should only be called once. Did you mean to use .extendWith(...) ?")},extendWith:(...t)=>e(r,[...o,...t]),omit:(...t)=>e(r,o.filter((e=>!t.includes(e)))),rename:t=>e(t,o),keys:()=>o,build:()=>[...new Set(o)].reduce(((e,a)=>Object.assign(e,{[a]:{selector:[`&[data-scope="${t(r)}"][data-part="${t(a)}"]`,`& [data-scope="${t(r)}"][data-part="${t(a)}"]`].join(", "),attrs:{"data-scope":t(r),"data-part":t(a)}}})),{})}),t=e=>e.replace(/([A-Z])([A-Z])/g,"$1-$2").replace(/([a-z])([A-Z])/g,"$1-$2").replace(/[\s_]+/g,"-").toLowerCase(),a=e=>0===e.length;export{e as createAnatomy};export default null;
//# sourceMappingURL=/sm/005652af100ea3fe8bb6aff54beb1596b3d891c11a93373fc7f7633eb020a336.map
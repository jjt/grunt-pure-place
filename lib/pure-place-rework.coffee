placeholderFn = (style) ->
  style.rules.forEach (rule, ruleIndex, arr) ->
    if rule.declarations?
      rule.declarations.forEach (dec, decIndex) ->
        if dec.type == "comment"
          delete style.rules[ruleIndex].declarations[decIndex]
    if rule.type == "comment"
      delete style.rules[ruleIndex]
      return
    if rule.media?
      return placeholderFn(rule)
    if rule.selectors isnt undefined
      rule.selectors.forEach (selector, selectorIndex) ->
        newSel = selector.replace(/\.pure/g, "%pure")
        style.rules[ruleIndex].selectors[selectorIndex] = newSel

pureClassesFn = (style) ->
  style.rules.forEach (rule, ruleIndex, arr) ->
    if rule.media?
      return pureClassesFn(rule)
    if rule.selectors isnt undefined
      rule.selectors.forEach (selector, selectorIndex) ->
        newSel = selector.replace(/\.pure/g, '.#{$pure-classes-prefix}')
        style.rules[ruleIndex].selectors[selectorIndex] = newSel

rework = require "rework"
module.exports =
  getPlaceholderCSS: (srcCode, toString) ->
    rework(srcCode).use(placeholderFn).toString toString
  getPureClassesCSS: (srcCode, toString) ->
    rework(srcCode).use(pureClassesFn).toString toString
    

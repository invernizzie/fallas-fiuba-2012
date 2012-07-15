#_ = require 'underscore' unless _?
# For some utility functions
# See http://documentcloud.github.com/underscore

# Represents a generic frame which can determine
# wether a given object can be represented by the frame
class Frame
  constructor: (properties) ->
    @rules = []
    _.extend this, properties
  
  # A frame needs to be configured with rules
  # regarding their slots in order to be evaluated
  addRule: (requiredSlots, callback) ->
    if typeof callback == 'function'
      @rules.push
        slots: requiredSlots
        procedure: callback
      return this

  evaluate: (instance) ->
    isDefinedSlot = (slot) ->
      typeof instance?[slot] not in ['undefined', 'function']
    
    # A frame matches if all rules are true
    _.all @rules, (rule) ->
      # An object needs to have all required slots...
      _.all(rule.slots, isDefinedSlot) and
          # ...and pass all rules in order to match
          rule.procedure instance || {}

class CompositeFrame
  constructor: (properties) ->
    _.extend this, properties
  
  evaluate: (matchedFrames) ->
    _.all @requiredFrames, (frame) ->
      _.contains _.pluck(matchedFrames, 'name'), frame

class Project
  constructor: (properties) ->
    _.extend this, properties
  
  budgetExceeded: ->
    @executedBudget > @totalBudget
    
  overdue: ->
    @elapsedTime > @estimatedTime
  
evaluateFrames = (simpleFrames, compositeFrames, instance) ->
  simpleMatched = (frame for frame in simpleFrames when frame.evaluate instance)
  compositeMatched = (frame for frame in compositeFrames when frame.evaluate simpleMatched)
  return simpleFrames: simpleMatched, compositeFrames: compositeMatched


# To export for the browser
_window = this
exportName = (name, value) ->
  return unless _.isString(name) and not _.isEmpty name
  if module? # Export as node module
    module.exports[name] = value
  _window[name] = value

exportName 'Project', Project
exportName 'Frame', Frame
exportName 'CompositeFrame', CompositeFrame
exportName 'evaluateFrames', evaluateFrames


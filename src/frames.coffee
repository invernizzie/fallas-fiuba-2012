_ = require 'underscore' unless _?
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


# Export as node module
module.exports.Project = Project
module.exports.Frame = Frame
module.exports.CompositeFrame = CompositeFrame
module.exports.evaluate = evaluateFrames
# Export for the browser
_window = this
# Doesn't fail like window.Project = ... on node.js
_window.Project = Project
_window.Frame = Frame
_window.CompositeFrame = CompositeFrame
_window.evaluate = evaluateFrames

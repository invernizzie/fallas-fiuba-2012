_ = require 'underscore'
# For some utility functions
# See http://documentcloud.github.com/underscore

# Represents a generic frame which can determine
# wether a given object can be represented by the frame
class Frame
  constructor: ->
    @rules = []
  
  # A frame needs to be configured with rules
  # regarding their slots in order to be evaluated
  addRule: (requiredSlots, callback) ->
    if typeof cb == 'function'
      @rules.push
        slots: requiredSlots
        procedure: callback

  evaluate: (instance) ->
    isDefinedSlot = (slot) ->
      typeof instance?.slot not in ['undefined', 'function']
    
    # A frame matches if all rules are true
    _.all @rules, (rule) ->
	    # An object needs to have all required slots...
	    _.all(rule.slots, isDefinedSlot) and
	        # ...and pass all rules in order to match
    	    rule.procedure instance || {}

budgetExceeded = new Frame
budgetExceeded.addRule ['totalBudget', 'executedBudged'],
    (slots) ->
      return slots.presupuestoTotal < slots.presupuestoEjecutado

project =
  executedBudged: 11
  totalBudget:     10

console.log budgetExceeded.evaluate project

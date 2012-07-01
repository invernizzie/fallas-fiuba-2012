_ = require 'underscore'
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
      #
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

frames = []
createSingleRuleFrame = (name, requiredSlots, ruleProcedure) ->
  frames.push(
    (new Frame name: name).addRule requiredSlots, ruleProcedure
  )
  
createSingleRuleFrame 'Presupuesto superado',
    ['totalBudget', 'executedBudget'],
    (proj) -> proj.budgetExceeded()

createSingleRuleFrame 'Costos subestimados',
    [
      'totalBudget'
      'executedBudget'
      'commitedFunctionality'
      'deliveredFunctionality'
    ],
    (proj) ->
      spendingRatio = proj.executedBudget / proj.totalBudget
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      spendingRatio > deliveryRatio

createSingleRuleFrame 'Calendario atrasado',
    [
      'elapsedTime'
      'estimatedTime'
      'commitedFunctionality'
      'deliveredFunctionality'
    ],
    (proj) ->
      calendarRatio = proj.elapsedTime / proj.estimatedTime
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      calendarRatio > deliveryRatio

createSingleRuleFrame 'Esfuerzo subestimado',
    [
      'investedEffort'
      'estimatedEffort'
      'commitedFunctionality'
      'deliveredFunctionality'
    ],
    (proj) ->
      effortRatio = proj.investedEffort / proj.estimatedEffort
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      effortRatio > deliveryRatio

createSingleRuleFrame 'Gestion de cambios deficiente',
    [
      'commitedFunctionality'
      'deliveredFunctionality'
    ],
    (proj) ->
      proj.deliveredFunctionality > 1.1 * proj.commitedFunctionality

createSingleRuleFrame 'Calendario excedente',
    [
      'elapsedTime'
      'estimatedTime'
      'commitedFunctionality'
      'deliveredFunctionality'
    ],
    (proj) ->
      allDelivered = proj.deliveredFunctionality >= proj.commitedFunctionality
      early = proj.estimatedTime > 1.1 * proj.elapsedTime
      allDelivered and early

createSingleRuleFrame 'Esfuerzo sobreestimado',
    [
      'investedEffort'
      'estimatedEffort'
      'commitedFunctionality'
      'deliveredFunctionality'
    ],
    (proj) ->
      allDelivered = proj.deliveredFunctionality >= proj.commitedFunctionality
      overestimated = proj.estimatedEffort > 1.1 * proj.investedEffort
      allDelivered and overestimated

class Project
  constructor: (properties) ->
    _.extend this, properties
  
  budgetExceeded: ->
    @executedBudget > @totalBudget
    
  overdue: ->
    @elapsedTime > @estimatedTime

project = new Project
    executedBudget: 11
    totalBudget:    10
    
    deliveredFunctionality: 6
    commitedFunctionality:  5
    
    elapsedTime:    5
    estimatedTime: 20
    
    investedEffort:    3
    estimatedEffort: 10


for frame in frames
  if frame.evaluate project
    console.log "El marco '#{frame.name}' coincide"


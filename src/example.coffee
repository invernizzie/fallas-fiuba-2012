frames = require './frames'
_ = require 'underscore' unless _?

simpleFrames = []
createSingleRuleFrame = (name, requiredSlots, ruleProcedure) ->
  simpleFrames.push(
    (new frames.Frame name: name).addRule requiredSlots, ruleProcedure
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

compositeFrames = []
compositeFrames.push new frames.CompositeFrame
  name: 'Proyecto al horno'
  requiredFrames: ['Presupuesto superado', 'Gestion de cambios deficiente']

project = new frames.Project
    executedBudget: 11
    totalBudget:    10
    
    deliveredFunctionality: 6
    commitedFunctionality:  5
    
    elapsedTime:    5
    estimatedTime: 20
    
    investedEffort:   3
    estimatedEffort: 10

matches = frames.evaluate simpleFrames, compositeFrames, project

for frame in matches.compositeFrames
  console.log "El marco '#{frame.name}' coincide"
if matches.compositeFrames?.length < 1
  for frame in matches.simpleFrames
    console.log "El marco '#{frame.name}' coincide"


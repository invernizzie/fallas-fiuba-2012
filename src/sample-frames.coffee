simpleFrames = []
createSingleRuleFrame = (name, severity, requiredSlots, ruleProcedure) ->
  simpleFrames.push(
    (new Frame
        name:     name
        severity: severity
    ).addRule requiredSlots, ruleProcedure
  )

SEVERIDAD =
  GRAVE: 'Grave'
  MEDIA: 'Media'

ACUERDO =
  FIXED_PRICE: 'fp'
  CPFF:        'cpff'
  TIME_MAT:    'tm'
  MANPOWER:    'mp'

createSingleRuleFrame 'Presupuesto superado', SEVERIDAD.GRAVE,
    ['totalBudget', 'executedBudget', 'projectType'],
    (proj) ->
      proj.budgetExceeded() and proj.projectType in [ACUERDO.FIXED_PRICE, ACUERDO.CPFF]

createSingleRuleFrame 'Presupuesto superado', SEVERIDAD.MEDIA,
    ['totalBudget', 'executedBudget', 'projectType'],
    (proj) ->
      proj.budgetExceeded() and proj.projectType not in [ACUERDO.FIXED_PRICE, ACUERDO.CPFF]

createSingleRuleFrame 'Costos subestimados', SEVERIDAD.GRAVE,
    [
      'totalBudget'
      'executedBudget'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      spendingRatio = proj.executedBudget / proj.totalBudget
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      spendingRatio > deliveryRatio and proj.projectType in [ACUERDO.FIXED_PRICE, ACUERDO.TIME_MAT]

createSingleRuleFrame 'Costos subestimados', SEVERIDAD.MEDIA,
    [
      'totalBudget'
      'executedBudget'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      spendingRatio = proj.executedBudget / proj.totalBudget
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      spendingRatio > deliveryRatio and proj.projectType is ACUERDO.CPFF

createSingleRuleFrame 'Calendario atrasado', SEVERIDAD.GRAVE,
    [
      'elapsedTime'
      'estimatedTime'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      calendarRatio = proj.elapsedTime / proj.estimatedTime
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      calendarRatio > deliveryRatio and proj.projectType is ACUERDO.CPFF

createSingleRuleFrame 'Calendario atrasado', SEVERIDAD.MEDIA,
    [
      'elapsedTime'
      'estimatedTime'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      calendarRatio = proj.elapsedTime / proj.estimatedTime
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      calendarRatio > deliveryRatio and proj.projectType in [ACUERDO.MANPOWER, ACUERDO.TIME_MAT]

createSingleRuleFrame 'Esfuerzo subestimado', SEVERIDAD.GRAVE,
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

createSingleRuleFrame 'Gestion de cambios deficiente', SEVERIDAD.GRAVE,
    [
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      proj.deliveredFunctionality > 1.1 * proj.commitedFunctionality and
          proj.projectType in [ACUERDO.FIXED_PRICE, ACUERDO.CPFF]

createSingleRuleFrame 'Gestion de cambios deficiente', SEVERIDAD.MEDIA,
    [
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      proj.deliveredFunctionality > 1.1 * proj.commitedFunctionality and
          proj.projectType is ACUERDO.TIME_MAT

createSingleRuleFrame 'Calendario excedente', SEVERIDAD.MEDIA,
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

createSingleRuleFrame 'Esfuerzo sobreestimado', SEVERIDAD.ALTO,
    [
      'investedEffort'
      'estimatedEffort'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      allDelivered = proj.deliveredFunctionality >= proj.commitedFunctionality
      overestimated = proj.estimatedEffort > 1.1 * proj.investedEffort
      allDelivered and overestimated and proj.projectType is ACUERDO.MANPOWER

createSingleRuleFrame 'Esfuerzo sobreestimado', SEVERIDAD.MEDIA,
    [
      'investedEffort'
      'estimatedEffort'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      allDelivered = proj.deliveredFunctionality >= proj.commitedFunctionality
      overestimated = proj.estimatedEffort > 1.1 * proj.investedEffort
      allDelivered and overestimated and proj.projectType is ACUERDO.FIXED_PRICE

compositeFrames = []
compositeFrames.push new CompositeFrame
  name: 'Proyecto al horno'
  requiredFrames: ['Presupuesto superado', 'Gestion de cambios deficiente']

# To export for the browser
_window = this
exportName = (name, value) ->
  return unless _.isString(name) and not _.isEmpty name
  if module? # Export as node module
    module.exports[name] = value
  _window[name] = value

exportName 'simpleFrames', simpleFrames
exportName 'compositeFrames', compositeFrames
